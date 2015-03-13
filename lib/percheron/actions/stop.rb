module Percheron
  module Actions
    class Stop

      include Base

      def initialize(container)
        @container = container
      end

      def execute!
        stop! if container.running?
        container
      end

      private

        attr_reader :container

        def stop!
          $logger.info "Stopping '#{container.name}' container"
          container.docker_container.stop!
        end

    end
  end
end
