module Percheron
  class Container

    extend Forwardable
    extend ConfigDelegator

    def_delegators :container, :name, :version

    def_config_item_with_default :container, [], :env, :ports, :volumes, :dependant_container_names

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
      '%s:%s' % [ name, version ]
    end

    def dockerfile
      container.dockerfile ? Pathname.new(File.expand_path(container.dockerfile, config.file_base_path)): nil
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

    def start!
      if exists?
        docker_container.start!
      else
        new_container = create!
        new_container.start!(start_opts)
      end
    end

    def stop!
      docker_container.stop! if running?
    end

    def running?
      exists? && info.State.Running
    end

    def valid?
      Validators::Container.new(self).valid?
    end

    private

      attr_reader :config, :stack, :container_name

      def create!
        build! unless image_exists?
        Docker::Container.create(create_opts)
      end

      def create_opts
        {
          'name'          => name,
          'Image'         => image,
          'Hostname'      => name,
          'Env'           => env,
          'ExposedPorts'  => exposed_ports,
          'VolumesFrom'   => volumes
        }
      end

      def start_opts
        opts = ports.inject({}) do |all, p|
          destination, source = p.split(':')
          all[source] = [ { 'HostPort' => destination } ]
          all
        end

        {
          'PortBindings'  => opts,
          'Links'         => links,
          'Binds'         => volumes
        }
      end

      def build!(nocache: false)
        base_dir = dockerfile.dirname.to_s
        Docker::Image.build_from_dir(base_dir, build_opts(nocache: nocache)) do |out|
          $logger.debug 'Container#build! out=[%s]' % [ out.strip ]
        end
      end

      def build_opts(nocache: false)
        {
          'dockerfile'  => dockerfile.basename.to_s,
          't'           => image,
          'forcerm'     => true,
          'nocache'     => nocache
        }
      end

      def exists?
        !info.empty?
      end

      def image_exists?
        Docker::Image.exist?(image)
      end

      def docker_container
        Docker::Container.get(name)
      rescue Docker::Error::NotFoundError, Excon::Errors::SocketError
        DockerNullContainer.new
      end

      def info
        Hashie::Mash.new(docker_container.info)
      end

      def container
        @container ||= stack.container_configs[container_name] || Hashie::Mash.new({})
      end

  end
end
