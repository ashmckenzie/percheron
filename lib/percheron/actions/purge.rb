module Percheron
  module Actions
    class Purge
      include Base

      def initialize(unit, force: false)
        @unit = unit
        @force = force
      end

      def execute!
        results = []
        results << stop!
        results << delete_unit!
        results << delete_image!
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :force

        def stop!
          Stop.new(unit).execute!
        end

        def delete_unit?
          unit.exists?
        end

        def delete_image?
          unit.image_exists? && unit.buildable?
        end

        def opts
          { force: force }
        end

        def delete_unit!
          return nil unless delete_unit?
          $logger.info "Deleting '#{unit.display_name}' unit"
          unit.container.remove(opts)
        rescue Docker::Error::ConflictError => e
          $logger.error "Unable to delete '%s' unit - %s" % [ unit.name, e.inspect ]
        end

        def delete_image!
          return nil unless delete_image?
          $logger.info "Deleting '#{unit.image_name}' image"
          unit.image.remove(opts)
        rescue Docker::Error::ConflictError => e
          $logger.error "Unable to delete '%s' image - %s" % [ unit.image_name, e.inspect ]
        end
    end
  end
end
