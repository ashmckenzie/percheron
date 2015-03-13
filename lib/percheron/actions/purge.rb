module Percheron
  module Actions
    class Purge

      include Base

      def initialize(container)
        @container = container
      end

      def execute!
        stop!
        delete_container! if container.exists?
        delete_image!     if container.image_exists?
        container
      end

      private

        attr_reader :container

        def stop!
          Stop.new(container).execute!
        end

        def delete_container!
          $logger.info "Deleting '#{container.name}' container"
          container.docker_container.remove
        end

        def delete_image!
          $logger.info "Deleting '#{container.image_name}' image"
          container.image.remove
        end

    end
  end
end
