module Percheron
  class Container

    extend Forwardable
    extend ConfigDelegator

    def_delegators :container_config, :name

    def_config_item_with_default :container_config, false, :auto_recreate
    def_config_item_with_default :container_config, [], :env, :ports, :volumes, :dependant_container_names, :pre_build_scripts, :post_create_scripts, :post_start_scripts

    alias_method :auto_recreate?, :auto_recreate

    def initialize(config, stack, container_name)
      @config = config
      @stack = stack
      @container_name = container_name
      valid?
      self
    end

    def id
      exists? ? info.id[0...12] : 'N/A'
    end

    def image_name
      '%s:%s' % [ name, version.to_s ]
    end

    def image
      Docker::Image.get(image_name)
    rescue Docker::Error::NotFoundError
      nil
    end

    def version
      Semantic::Version.new(container_config.version)
    end

    def built_version
      Semantic::Version.new(exists? ? built_image_version : '0.0.0')
    end

    def dockerfile
      container_config.dockerfile ? Pathname.new(File.expand_path(container_config.dockerfile, config.file_base_path)): nil
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

    def docker_container
      Docker::Container.get(name)
    rescue Docker::Error::NotFoundError, Excon::Errors::SocketError
      NullContainer.new
    end

    def dependant_containers
      dependant_container_names.inject({}) do |all, container_name|
        all[container_name] = stack.filter_containers[container_name]
        all
      end
    end

    def metastore_key
      @metastore_key ||= 'stacks.%s.containers.%s' % [ stack.name, name ]
    end

    def current_dockerfile_md5
      Digest::MD5.file(dockerfile).hexdigest
    end

    def dockerfile_md5
      $metastore.get("#{metastore_key}.dockerfile_md5")
    end

    def running?
      exists? && info.State.Running
    end

    def exists?
      !info.empty?
    end

    def image_exists?
      !!image
    end

    def dependant_containers?
      !dependant_container_names.empty?
    end

    def valid?
      Validators::Container.new(self).valid?
    end

    private

      attr_reader :config, :stack, :container_name

      def built_image_version
        info.Config.Image.split(':')[1]
      end

      def info
        Hashie::Mash.new(docker_container.info)
      end

      def container_config
        @container_config ||= stack.container_configs[container_name] || Hashie::Mash.new({})
      end

  end
end
