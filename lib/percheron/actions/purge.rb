module Percheron
  module Actions
    class Purge

      include Base

      def initialize(container, delete_image: true)
        @container = container
        @delete_image = delete_image
      end

      def execute!
        results = []
        results << stop!
        results << delete_container!
        results << delete_image!
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :delete_image

        def stop!
          Stop.new(container).execute!
        end

        def delete_image?
          delete_image && container.image_exists? && container.buildable?
        end

        def delete_container!
          return nil unless container.exists?
          $logger.info "Deleting '#{container.name}' container"
          container.docker_container.remove
        rescue Docker::Error::ConflictError => e
          $logger.error "Unable to delete '%s' container - %s" % [ container.name, e.inspect ]
        end

        def delete_image!
          return nil unless delete_image?
          $logger.info "Deleting '#{container.image_name}' image"
          container.image.remove
        rescue Docker::Error::ConflictError => e
          $logger.error "Unable to delete '%s' image - %s" % [ container.image_name, e.inspect ]
        end

    end
  end
end
