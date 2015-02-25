require 'forwardable'
require 'pathname'

module Percheron
  class ContainerConfig

    extend Forwardable
    extend ConfigDelegator

    def_delegators :docker_container, :start!, :stop!
    def_delegators :config, :name, :version

    def_config_item_with_default :config, [], :env, :ports, :volumes, :dependant_container_names

    def initialize(config)
      @config = Hashie::Mash.new(config)
      valid?
    end

    def id
      info.id[0...12]
    end

    def image
      '%s:%s' % [ name, version ]
    end

    def dockerfile
      config.dockerfile ? Pathname.new(config.dockerfile).expand_path : nil
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

      attr_reader :config

      def docker_container
        Docker::Container.get(name)
      end

      def info
        Hashie::Mash.new(docker_container.info)
      end

  end
end
