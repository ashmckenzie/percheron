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

      end
    end
  end
end
