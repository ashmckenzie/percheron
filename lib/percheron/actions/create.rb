module Percheron
  module Actions
    class Create

      include Base

      def initialize(container, start: false, cmd: false, exec_scripts: true)
        @container = container
        @start = start
        @exec_scripts = exec_scripts
        @cmd = cmd
        @container_image_existed = container.image_exists?
      end

      def execute!
        results = []
        if container.exists?
          $logger.debug "Container '#{container.name}' already exists"
        else
          results << create!
        end
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :start, :exec_scripts, :container_image_existed
        alias_method :start?, :start
        alias_method :exec_scripts?, :exec_scripts
        alias_method :container_image_existed?, :container_image_existed

        def cmd
          @cmd ||= (@cmd || container.start_args)
        end

        def base_options
          {
            'name'          => container.full_name,
            'Image'         => container.image_name,
            'Hostname'      => container.hostname,
            'Env'           => container.env,
            'ExposedPorts'  => container.exposed_ports,
            'Cmd'           => cmd,
            'Labels'        => container.labels
          }
        end

        def host_config_options
          {
            'HostConfig'    => {
              'PortBindings'  => port_bindings,
              'Links'         => container.links,
              'Binds'         => container.volumes,
              'Dns'           => container.dns
            }
          }
        end

        def options
          @options ||= base_options.merge(host_config_options)
        end

        def port_bindings
          container.ports.each_with_object({}) do |p, all|
            destination, source = p.split(':')
            all[source] = [ { 'HostPort' => destination } ]
          end
        end

        def create!
          container.buildable? ? build_image! : pull_image!
          return unless container.startable?
          insert_scripts!
          create_container!
          update_dockerfile_md5!
          start!
        end

        def build_image!
          Build.new(container).execute! unless container.image_exists?
        end

        # FIXME: move this
        def pull_image!
          return nil if container.image_exists?
          $logger.info "Pulling '#{container.image_name}' image"
          Docker::Image.create(fromImage: container.image_name) do |out|
            $logger.debug JSON.parse(out)
          end
        end

        def create_container!
          $logger.info "Creating '#{container.name}' container"
          Docker::Container.create(options)
        end

        def start!
          return nil if !container.startable? || !start?
          Start.new(container).execute!
        end

        def update_dockerfile_md5!
          container.update_dockerfile_md5!
        end

        def insert_scripts!
          return nil if container_image_existed?
          insert_files!(container.post_start_scripts)
        end

        def insert_files!(files)
          files.each { |file| insert_file!(file) }
        end

        def insert_file!(file)
          file = Pathname.new(File.expand_path(file, base_dir))
          opts = { 'localPath' => file.to_s, 'outputPath' => "/tmp/#{file.basename}" }
          new_image = container.image.insert_local(opts)
          new_image.tag(repo: container.image_repo, tag: container.version.to_s, force: true)
        end
    end
  end
end
