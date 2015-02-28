module Percheron
  module Container
    module Actions
      class Start

        def initialize(container)
          @container = container
        end

        def execute!
          if container.exists?
            $logger.debug "Starting '#{container.name}'"
            container.docker_container.start!(start_opts)
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

      end
    end
  end
end
