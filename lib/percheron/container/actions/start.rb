module Percheron
  module Container
    module Actions
      class Start

        include Base

        def initialize(container)
          @container = container
        end

        def execute!
          if container.exists?
            start!
            execute_post_start_scripts!
          else
            raise Errors::ContainerDoesNotExist.new
          end
        end

        private

          attr_reader :container

          def start_opts
            opts = container.ports.inject({}) do |all, p|
              destination, source = p.split(':')
              all[source] = [ { 'HostPort' => destination } ]
              all
            end

            {
              'PortBindings'  => opts,
              'Links'         => container.links,
              'Binds'         => container.volumes
            }
          end

          def start!
            $logger.debug "Starting '#{container.name}'"
            container.docker_container.start!(start_opts)
          end

          def execute_post_start_scripts!
            container.post_start_scripts.each do |script|
              in_working_directory(base_dir) do
                file = Pathname.new(File.expand_path(script, base_dir))
                command = '/bin/bash -x /tmp/%s 2>&1' % file.basename
                $logger.debug "Executing POST create '#{command}' for '#{container.name}' container"
                container.docker_container.exec(command.split(' '))
              end
            end
          end

      end
    end
  end
end
