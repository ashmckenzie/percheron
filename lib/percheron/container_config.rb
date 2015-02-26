module Percheron
  class ContainerConfig

    extend Forwardable
    extend ConfigDelegator

    def_delegators :docker_container, :start!, :stop!
    def_delegators :container_config, :name, :version

    def_config_item_with_default :container_config, [], :env, :ports, :volumes, :dependant_container_names

    def initialize(config, container_config)
      @config = config
      @container_config = Hashie::Mash.new(container_config)
      valid?
    end

    def id
      info.id[0...12]
    end

    def image
      '%s:%s' % [ name, version ]
    end

    def dockerfile
      container_config.dockerfile ? Pathname.new(File.expand_path(container_config.dockerfile, config.file_base_path)): nil
    end

    def running?
      current_info = info
      current_info && current_info.State.Running
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

      attr_reader :config, :container_config

      def docker_container
        Docker::Container.get(name)
      end

      def info
        Hashie::Mash.new(docker_container.info)
      end

  end
end
