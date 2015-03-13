module Percheron
  module Actions
    class Create

      include Base

      def initialize(container, recreate: false)
        @container = container
        @recreate = recreate
      end

      def execute!(opts={})
        if recreate? || !container.exists?
          create!(opts)
          container
        else
          $logger.debug "Container '#{container.name}' already exists"
        end
      end

      private

        attr_reader :container, :recreate

        def base_options
          {
            'name'          => container.name,
            'Image'         => container.image_name,
            'Hostname'      => container.name,
            'Env'           => container.env,
            'ExposedPorts'  => container.exposed_ports,
            'HostConfig'    => {
              'PortBindings'  => port_bindings,
              'Links'         => container.links,
              'Binds'         => container.volumes
            }
          }
        end

        def host_config_options
          {
            'HostConfig'    => {
              'PortBindings'  => port_bindings,
              'Links'         => container.links,
              'Binds'         => container.volumes
            }
          }
        end

        def port_bindings
          container.ports.inject({}) do |all, p|
            destination, source = p.split(':')
            all[source] = [ { 'HostPort' => destination } ]
            all
          end
        end

        def recreate?
          recreate
        end

        def create!(opts)
          $logger.debug "Container '#{container.name}' does not exist, creating"
          build_image!
          insert_scripts!
          create_container!(opts.fetch(:create, {}))
          execute_post_create_scripts!
          set_dockerfile_md5!
        end

        def build_image!
          unless container.image_exists?
            $logger.info "Creating '#{container.image_name}' image"
            Build.new(container).execute!
          end
        end

        def set_dockerfile_md5!
          $logger.info "Setting MD5 for '#{container.name}' container to #{container.current_dockerfile_md5}"
          $metastore.set("#{container.metastore_key}.dockerfile_md5", container.current_dockerfile_md5)
        end

        def create_container!(opts)
          options = base_options.merge(host_config_options).merge(opts)

          $logger.info "Creating '%s' container" % options['name']
          Docker::Container.create(options)
        end

        def insert_scripts!
          insert_post_create_scripts!
          insert_post_start_scripts!
        end

        def insert_post_create_scripts!
          insert_files!(container.post_create_scripts)
        end

        def insert_post_start_scripts!
          insert_files!(container.post_start_scripts)
        end

        def execute_post_create_scripts!
          Exec.new(container, container.dependant_containers.values, container.post_create_scripts, 'POST create').execute!
        end

    end
  end
end
