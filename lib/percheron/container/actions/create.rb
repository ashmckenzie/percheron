module Percheron
  module Container
    module Actions
      class Create

        include Base

        def initialize(container)
          @container = container
        end

        def execute!
          build!
          create!
        end

        private

          attr_reader :container

          def create_opts
            {
              'name'          => container.name,
              'Image'         => container.image_name,
              'Hostname'      => container.name,
              'Env'           => container.env,
              'ExposedPorts'  => container.exposed_ports,
              'VolumesFrom'   => container.volumes
            }
          end

          def build!
            unless container.image
              $logger.debug "Creating '#{container.image_name}' image"
              Container::Actions::Build.new(container).execute!
            end
          end

          def create!
            $logger.debug "Creating '#{container.name}' container"
            Docker::Container.create(create_opts)
          end

      end
    end
  end
end
