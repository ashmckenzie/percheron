module Percheron
  module Container
    module Actions
      class Stop

        def initialize(container)
          @container = container
        end

        def execute!
          if container.running?
            $logger.debug "Stopping '#{container.name}'"
            container.docker_container.stop!
          else
            $logger.debug "Not stopping '#{container.name}' container as it's not running"
            raise Errors::ContainerNotRunning.new
          end
        end

        private

          attr_reader :container

      end
    end
  end
end
