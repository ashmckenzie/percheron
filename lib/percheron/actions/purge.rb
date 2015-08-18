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
        results << delete_unit!  if delete_unit?
        results << delete_image! if delete_image?
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
          delete!('unit', unit.display_name) { unit.container.remove(opts) }
        end

        def delete_image!
          delete!('image', unit.image_name) { unit.image.remove(opts) }
        end

        def delete!(type, value)
          $logger.info("Deleting '%s' %s" % [ value, type ])
          yield
        rescue Docker::Error::ConflictError => e
          $logger.error("Unable to delete '%s' %s - %s" % [ value, type, e.inspect ])
        end
    end
  end
end
