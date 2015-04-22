module Percheron
  class Container

    extend Forwardable
    extend ConfigDelegator

    def_delegators :container_config, :name, :pseudo_name, :docker_image
    def_config_item_with_default :container_config, [], :env, :ports, :volumes, :dependant_container_names, :pre_build_scripts, :post_start_scripts, :start_args
    def_config_item_with_default :container_config, %w(127.0.0.1 8.8.8.8), :dns
    def_config_item_with_default :container_config, true, :startable

    attr_reader :config_file_base_path

    def initialize(stack, container_name, config_file_base_path)
      @stack = stack
      @container_name = container_name
      @config_file_base_path = config_file_base_path
      self
    end

    def dependant_containers
      dependant_container_names.each_with_object({}) { |container_name, all| all[container_name] = stack.containers[container_name] }
    end

    def startable_dependant_containers
      dependant_containers.select { |_, container| container.startable? }
    end

    def metastore_key
      @metastore_key ||= 'stacks.%s.containers.%s' % [ stack.name, name ]
    end

    def container_config
      @container_config ||= stack.container_configs[container_name] || Hashie::Mash.new({})
    end

    def id
      exists? ? info.id[0...12] : nil
    end

    def hostname
      container_config.fetch('hostname', name)
    end

    def image_name
      '%s:%s' % [ image_repo, image_version.to_s ] if image_repo && image_version
    end

    def image_repo  # FIXME
      if pseudo?
        pseudo_full_name
      elsif !buildable?
        container_config.docker_image.split(':')[0]
      else
        full_name
      end
    end

    def image_version
      if buildable?
        version
      elsif !container_config.docker_image.nil?
        container_config.docker_image.split(':')[1]
      else
        fail Errors::ContainerInvalid, 'Cannot determine image version'
      end
    end

    def full_name
      '%s_%s' % [ stack.name, name ]
    end

    def pseudo_full_name
      '%s_%s' % [ stack.name, pseudo_name ]
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
      Semantic::Version.new(built_image_version)
    end

    def dockerfile
      container_config.dockerfile ? Pathname.new(File.expand_path(container_config.dockerfile, config_file_base_path)) : nil
    end

    def exposed_ports
      ports.each_with_object({}) { |p, all| all[p.split(':')[1]] = {} }
    end

    def links
      startable_dependant_containers.map { |_, container| '%s:%s' % [ container.full_name, container.name ] }
    end

    def docker_container
      Docker::Container.get(full_name)
    rescue Docker::Error::NotFoundError, Excon::Errors::SocketError
      NullContainer.new
    end

    def labels
      { version: version.to_s, created_by: "Percheron #{Percheron::VERSION}" }
    end

    def update_dockerfile_md5!
      md5 = current_dockerfile_md5
      $logger.info "Setting MD5 for '#{name}' container to #{md5}"
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
      image.nil? ? false : true
    end

    def buildable?
      !dockerfile.nil? && container_config.docker_image.nil?
    end

    def valid?
      Validators::Container.new(self).valid?
    end

    alias_method :startable?, :startable

    private

      attr_reader :stack, :container_name

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
        Hashie::Mash.new(docker_container.info)
      end

      def pseudo?
        !pseudo_name.nil?
      end
  end
end
