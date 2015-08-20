module Percheron
  module Actions
    class Create
      include Base

      def initialize(unit, build: true, start: false, force: false, cmd: false)
        @unit = unit
        @build = build
        @start = start
        @force = force
        @cmd = (cmd || unit.start_args)
      end

      def execute!
        results = []
        results << build_or_pull_image!
        results << create!
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :build, :start, :force, :cmd
        alias_method :build?, :build
        alias_method :start?, :start
        alias_method :force?, :force

        def create?
          unit.startable? && (!unit.exists? || force)
        end

        def base_options
          {
            'name'          => unit.full_name,
            'Image'         => unit.image_name,
            'Hostname'      => unit.hostname,
            'Env'           => unit.env,
            'ExposedPorts'  => unit.exposed_ports,
            'Cmd'           => cmd,
            'Labels'        => unit.labels
          }
        end

        def host_config_options
          {
            'HostConfig' => {
              'PortBindings'  => port_bindings,
              'Links'         => unit.links,
              'Binds'         => unit.volumes,
              'RestartPolicy' => unit.restart_policy,
              'Privileged'    => unit.privileged
            }
          }
        end

        def host_config_dns_options
          unit.dns.empty? ? {} : { 'HostConfig' => { 'Dns' => unit.dns } }
        end

        def options
          @options ||= begin
            base_options.merge(host_config_options).merge(host_config_dns_options)
          end
        end

        def port_bindings
          unit.ports.each_with_object({}) do |p, all|
            destination, source = p.split(':')
            all[source] = [ { 'HostPort' => destination } ]
          end
        end

        def build_or_pull_image!
          unit.buildable? ? build_image! : pull_image!
        end

        def create!
          if create?
            create_unit!
            update_dockerfile_md5!
            start_and_insert_scripts! if start?
          else
            $logger.warn("Unit '#{unit.display_name}' already exists (--force to overwrite)")
          end
        rescue Errors::DockerContainerCannotDelete => e
          $logger.error "Unable to delete '%s' unit - %s" % [ unit.name, e.inspect ]
        end

        def build_image!
          Build.new(unit).execute! if build?
        end

        def pull_image!
          return nil if unit.image_exists?
          $logger.info "Pulling '#{unit.image_name}' image"
          Connection.perform(Docker::Image, :create, fromImage: unit.image_name) do |out|
            $logger.info JSON.parse(out)
          end
        end

        def delete_unit!
          $logger.info "Deleting '#{unit.display_name}' unit"
          unit.container.remove(force: force?)
        rescue Docker::Error::ConflictError => e
          raise(Errors::DockerContainerCannotDelete.new, e)
        end

        def create_unit!
          delete_unit! if force?
          $logger.info "Creating '#{unit.display_name}' unit"
          Connection.perform(Docker::Container, :create, options)
        end

        def start_and_insert_scripts!
          insert_post_start_scripts!
          Start.new(unit, create: false).execute!
        end

        def update_dockerfile_md5!
          unit.update_dockerfile_md5!
        end

        def insert_post_start_scripts!
          unit.post_start_scripts.each { |file| insert_file!(file) }
        end

        def insert_file!(file)
          file = Pathname.new(File.expand_path(file, base_dir))
          opts = { 'localPath' => file.to_s, 'outputPath' => "/tmp/#{file.basename}" }
          new_image = unit.image.insert_local(opts)
          new_image.tag(repo: unit.image_repo, tag: unit.version.to_s, force: true)
        end
    end
  end
end
