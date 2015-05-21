module Percheron
  module Actions
    class Create

      include Base

      def initialize(unit, start: false, cmd: false, exec_scripts: true)
        @unit = unit
        @start = start
        @exec_scripts = exec_scripts
        @cmd = cmd
        @unit_image_existed = unit.image_exists?
      end

      def execute!
        results = []
        if unit.exists?
          $logger.debug "Unit '#{unit.name}' already exists"
        else
          results << create!
        end
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :start, :exec_scripts, :unit_image_existed
        alias_method :start?, :start
        alias_method :exec_scripts?, :exec_scripts
        alias_method :unit_image_existed?, :unit_image_existed

        def cmd
          @cmd ||= (@cmd || unit.start_args)
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
            'HostConfig'    => {
              'PortBindings'  => port_bindings,
              'Links'         => unit.links,
              'Binds'         => unit.volumes,
              'Dns'           => unit.dns,
              'VolumesFrom'   => unit.volumes_from
            }
          }
        end

        def options
          @options ||= base_options.merge(host_config_options)
        end

        def port_bindings
          unit.ports.each_with_object({}) do |p, all|
            destination, source = p.split(':')
            all[source] = [ { 'HostPort' => destination } ]
          end
        end

        def create!
          unit.buildable? ? build_image! : pull_image!
          return unless unit.startable?
          insert_scripts!
          create_unit!
          update_dockerfile_md5!
          start!
        end

        def build_image!
          Build.new(unit).execute! unless unit.image_exists?
        end

        # FIXME: move this
        def pull_image!
          return nil if unit.image_exists?
          $logger.info "Pulling '#{unit.image_name}' image"
          Connection.perform(Docker::Image, :create, fromImage: unit.image_name) do |out|
            $logger.debug JSON.parse(out)
          end
        end

        def create_unit!
          $logger.info "Creating '#{unit.name}' unit"
          Connection.perform(Docker::Container, :create, options)
        end

        def start!
          return nil if !unit.startable? || !start?
          Start.new(unit).execute!
        end

        def update_dockerfile_md5!
          unit.update_dockerfile_md5!
        end

        def insert_scripts!
          return nil if unit_image_existed?
          insert_files!(unit.post_start_scripts)
        end

        def insert_files!(files)
          files.each { |file| insert_file!(file) }
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
