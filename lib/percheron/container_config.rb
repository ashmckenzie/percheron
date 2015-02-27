require 'docker/null_container'

module Percheron
  class ContainerConfig

    extend Forwardable
    extend ConfigDelegator

    def_delegators :docker_container, :start!, :stop!
    def_delegators :container_config, :name, :version

    def_config_item_with_default :container_config, [], :env, :ports, :volumes, :dependant_container_names

    def initialize(config, stack, container_config_name)
      @config = config
      @stack = stack
      @container_config_name = container_config_name
      valid?
    end

    def id
      exists? ? info.id[0...12] : 'N/A'
    end

    def image
      '%s:%s' % [ name, version ]
    end

    def dockerfile
      container_config.dockerfile ? Pathname.new(File.expand_path(container_config.dockerfile, config.file_base_path)): nil
    end

    def running?
      exists? && info.State.Running
    end

    def exposed_ports
      ports.inject({}) do |all, p|
        all[p.split(':')[1]] = {}
        all
      end
    end

    def links
      dependant_container_names.map do |container_name|
        '%s:%s' % [ container_name, container_name ]
      end
    end

    def valid?
      Validators::ContainerConfig.new(self).valid?
    end

    private

      attr_reader :config, :stack, :container_config_name

      def exists?
        !info.empty?
      end

      def docker_container
        Docker::Container.get(name)
      rescue Docker::Error::NotFoundError, Excon::Errors::SocketError
        Docker::NullContainer.new
      end

      def info
        Hashie::Mash.new(docker_container.info)
      end

      def container_config
        @container_config ||= stack.container_configs_configs[container_config_name] || Hashie::Mash.new({})
      end

  end
end
