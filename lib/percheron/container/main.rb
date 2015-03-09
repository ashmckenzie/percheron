module Percheron
  module Container
    class Main

      extend Forwardable
      extend ConfigDelegator

      def_delegators :container_config, :name

      def_config_item_with_default :container_config, false, :auto_recreate
      def_config_item_with_default :container_config, [], :env, :ports, :volumes, :dependant_container_names, :pre_build_scripts

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

      def image
        Docker::Image.get(image_name)
      rescue Docker::Error::NotFoundError
        nil
      end

      def image_name
        '%s:%s' % [ name, version.to_s ]
      end

      def version
        Semantic::Version.new(container_config.version)
      end

      def built_version
        exists? ? Semantic::Version.new(built_image_version) : nil
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
        Container::Null.new
      end

      def stop!
        Container::Actions::Stop.new(self).execute!
      rescue Errors::ContainerNotRunning
        $logger.debug "Container '#{name}' is not running"
      end

      def start!
        start_dependant_containers!
        create!
        recreate!
        Container::Actions::Start.new(self).execute!
      end

      def restart!
        stop!
        start!
      end

      def create!
        unless exists?
          $logger.debug "Container '#{name}' does not exist, creating"
          Container::Actions::Create.new(self).execute!
          set_dockerfile_md5!
        else
          $logger.debug "Not creating '#{name}' container as it already exists"
        end
      end

      def recreate!(force_recreate: false, force_auto_recreate: false)
        if exists?
          if recreate?(force_recreate: force_recreate, force_auto_recreate: force_auto_recreate)
            $logger.warn "Container '#{name}' exists and will be recreated"
            Container::Actions::Recreate.new(self).execute!
            set_dockerfile_md5!
          else
            if recreatable?
              $logger.warn "Container '#{name}' MD5's do not match, consider recreating"
            else
              $logger.debug "Container '#{name}' does not need to be recreated"
            end
          end
        else
          $logger.warn "Not recreating '#{name}' container as it does not exist"
        end
      end

      def recreatable?
        !dockerfile_md5s_match?
      end

      def recreate?(force_recreate: false, force_auto_recreate: false)
        (force_recreate || (recreatable? && versions_mismatch?)) && (force_auto_recreate || auto_recreate?)
      end

      def running?
        exists? && info.State.Running
      end

      def exists?
        !info.empty?
      end

      def valid?
        Validators::Container.new(self).valid?
      end

      private

        attr_reader :config, :stack, :container_name

        def dockerfile_md5s_match?
          stored_dockerfile_md5 == current_dockerfile_md5
        end

        def versions_mismatch?
          version > built_version
        end

        def built_image_version
          info.Config.Image.split(':')[1]
        end

        def stored_dockerfile_md5
          dockerfile_md5 || current_dockerfile_md5
        end

        def metastore_key
          @metastore_key ||= 'stacks.%s.containers.%s' % [ stack.name, name ]
        end

        def dockerfile_md5
          $metastore.get("#{metastore_key}.dockerfile_md5")
        end

        def set_dockerfile_md5!
          $logger.debug "Setting MD5 for '#{name}' container to #{current_dockerfile_md5}"
          $metastore.set("#{metastore_key}.dockerfile_md5", current_dockerfile_md5)
        end

        def current_dockerfile_md5
          Digest::MD5.file(dockerfile).hexdigest
        end

        def info
          Hashie::Mash.new(docker_container.info)
        end

        def container_config
          @container_config ||= stack.container_configs[container_name] || Hashie::Mash.new({})
        end

        def dependant_containers
          dependant_container_names.map { |container_name| stack.containers[container_name] }
        end

        def start_dependant_containers!
          dependant_containers.each do |container|
            next if container.running?
            $logger.debug "Container '#{container.name}' being started as it's a dependancy"
            container.start!
          end
        end

    end
  end
end
