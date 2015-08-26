require 'percheron/unit/image_helper'

module Percheron
  class Unit

    extend Forwardable
    extend ConfigDelegator
    include Unit::ImageHelper

    def_delegators :unit_config, :name, :pseudo_name, :docker_image
    def_config_item_with_default :unit_config, [], :env, :ports, :volumes, :pre_build_scripts, :dns,
                                 :start_args
    def_config_item_with_default :unit_config, true, :startable

    def initialize(config, stack, unit_name)
      @config = config
      @stack = stack
      @unit_name = unit_name
      @unit_config = stack.unit_configs[unit_name] || Hashie::Mash.new({}) # FIXME
      self
    end

    def needed_unit_names
      unit_config.fetch('needed_unit_names', unit_config.fetch('dependant_unit_names', []))
    end

    # FIXME
    def needed_units(stacks=nil)
      stacks = { stack.name => stack } unless stacks
      needed_unit_names.each_with_object({}) do |unit_name_tuple, all|
        match = unit_name_tuple.match(/^(?<one>[^:]+):*(?<two>[^:]*)$/)

        if match[:two].empty?
          unit_name = match[:one]
          stack_name = stack.name
        else
          stack_name = match[:one]
          unit_name = match[:two]
        end

        key = "%s:%s" % [ stack_name, unit_name ]
        all[key] = stacks[stack_name].units[unit_name]
      end
    end

    def startable_needed_units
      needed_units.select { |_, unit| unit.startable? }
    end

    def metastore_key
      @metastore_key ||= '%s.units.%s' % [ stack.metastore_key, name ]
    end

    def id
      exists? ? info.id[0...12] : nil
    end

    def hostname
      unit_config.fetch('hostname', full_name)
    end

    def restart_policy
      @restart_policy ||= begin
        name = unit_config.fetch('restart_policy', 'always')
        max_retry_count = unit_config.fetch('restart_policy_retry_count', 0)
        { 'Name' => name, 'MaximumRetryCount' => max_retry_count }
      end
    end

    def privileged
      unit_config.fetch('privileged', false)
    end

    def full_name
      '%s_%s' % [ stack.name, name ]
    end

    def display_name
      '%s:%s' % [ stack.name, name ]
    end

    def pseudo_full_name
      '%s_%s' % [ stack.name, pseudo_name ]
    end

    def image
      Connection.perform(Docker::Image, :get, image_name)
    rescue Docker::Error::NotFoundError
      nil
    end

    def version
      @version ||= Semantic::Version.new(unit_config.version)
    end

    def built_version
      @built_version ||= Semantic::Version.new(built_image_version)
    end

    def exposed_ports
      ports.each_with_object({}) { |p, all| all[p.split(':')[1]] = {} }
    end

    def links
      startable_needed_units.map { |_, unit| '%s:%s' % [ unit.full_name, unit.full_name ] }
    end

    def container
      Connection.perform(Docker::Container, :get, full_name)
    rescue Docker::Error::NotFoundError, Excon::Errors::SocketError
      NullUnit.new
    end

    def labels
      { version: version.to_s, created_by: "Percheron #{Percheron::VERSION}" }
    end

    def ip
      exists? ? info.NetworkSettings.IPAddress : 'n/a'
    end

    def dockerfile
      return nil unless unit_config.dockerfile
      Pathname.new(File.expand_path(unit_config.dockerfile, config.file_base_path))
    end

    def update_dockerfile_md5!
      md5 = current_dockerfile_md5
      $logger.debug "Setting MD5 for '#{name}' unit to #{md5}"
      $metastore.set("#{metastore_key}.dockerfile_md5", md5)
    end

    def dockerfile_md5s_match?
      dockerfile_md5 == current_dockerfile_md5
    end

    def versions_match?
      version == built_version
    end

    def running?
      exists? && info.State.Running
    end

    def exists?
      !info.empty?
    end

    def buildable?
      !dockerfile.nil? && unit_config.docker_image.nil?
    end

    def valid?
      Validators::Unit.new(self).valid?
    end

    def pseudo?
      !pseudo_name.nil?
    end

    alias_method :startable?, :startable

    private

      attr_reader :config, :stack, :unit_config, :unit_name

      def current_dockerfile_md5
        dockerfile ? Digest::MD5.file(dockerfile).hexdigest : Digest::MD5.hexdigest(image_name)
      end

      def dockerfile_md5
        $metastore.get("#{metastore_key}.dockerfile_md5") || current_dockerfile_md5
      end

      def built_image_version
        (exists? && info.Config.Labels) ? info.Config.Labels.version : '0.0.0'
      end

      def info
        Hashie::Mash.new(container.info)
      end
  end
end
