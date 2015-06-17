module Percheron
  class Unit

    extend Forwardable
    extend ConfigDelegator

    def_delegators :unit_config, :name, :pseudo_name, :docker_image
    def_config_item_with_default :unit_config, [], :env, :volumes, :volumes_from, :start_args,
                                 :dependant_unit_names, :pre_build_scripts, :post_start_scripts
    def_config_item_with_default :unit_config, %w(127.0.0.1 8.8.8.8), :dns
    def_config_item_with_default :unit_config, true, :startable

    def initialize(config, stack, unit_name)
      @config = config
      @stack = stack
      @unit_name = unit_name
      @unit_config = stack.unit_configs[unit_name] || Hashie::Mash.new({}) # FIXME
      self
    end

    def dependant_units
      dependant_unit_names.each_with_object({}) do |unit_name, all|
        all[unit_name] = stack.units[unit_name]
      end
    end

    def startable_dependant_units
      dependant_units.select { |_, unit| unit.startable? }
    end

    def metastore_key
      @metastore_key ||= '%s.units.%s' % [ stack.metastore_key, name ]
    end

    def id
      exists? ? info.id[0...12] : nil
    end

    def hostname
      unit_config.fetch('hostname', name)
    end

    def image_id
      image.id ? image.id[0...12] : nil
    end

    def image_name
      '%s:%s' % [ image_repo, image_version.to_s ] if image_repo && image_version
    end

    def image_repo
      if !buildable?
        unit_config.docker_image.split(':')[0]
      elsif pseudo?
        pseudo_full_name
      else
        full_name
      end
    end

    def image_version
      if buildable?
        unit_config.version
      elsif !unit_config.docker_image.nil?
        unit_config.docker_image.split(':')[1] || 'latest'
      else
        fail Errors::UnitInvalid, 'Cannot determine image version'
      end
    end

    def full_name
      '%s_%s' % [ stack.name, name ]
    end

    def pseudo_full_name
      '%s_%s' % [ stack.name, pseudo_name ]
    end

    def image
      Connection.perform(Docker::Image, :get, image_name)
    rescue Errors::ConnectionException
      NullImage.new
    end

    def version
      @version ||= Semantic::Version.new(unit_config.version)
    end

    def built_version
      @built_version ||= Semantic::Version.new(built_image_version)
    end

    def ports
      unit_config.fetch('ports', []).each_with_object([]) do |port, all|
        if port.is_a?(String)
          pub, int = port.split(':')
          all << { 'internal' => int.to_s, 'public' => pub.to_s }
        elsif port.is_a?(Hash)
          all << { 'internal' => port['internal'].to_s, 'public' => port['public'].to_s }
        end
      end
    end

    def links
      startable_dependant_units.map do |_, unit|
        '%s:%s' % [ unit.full_name, unit.name ]
      end
    end

    def container
      Connection.perform(Docker::Container, :get, full_name)
    rescue Errors::ConnectionException
      NullUnit.new
    end

    def labels
      { version: version.to_s, created_by: "Percheron #{Percheron::VERSION}" }
    end

    def ip
      exists? ? info.NetworkSettings.IPAddress : nil
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

    def image_exists?
      image.id.nil? ? false : true
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
