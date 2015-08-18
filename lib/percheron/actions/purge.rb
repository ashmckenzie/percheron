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
          msg = "Deleting '#{unit.display_name}' unit"
          failure_msg = "Unable to delete '%s' unit" % [ unit.name ]
          delete!(msg, failure_msg) { unit.container.remove(opts) }
        end

        def delete_image!
          msg = "Deleting '#{unit.image_name}' image"
          failure_msg = "Unable to delete '%s' image" % [ unit.image_name ]
          delete!(msg, failure_msg) { unit.image.remove(opts) }
        end

        def delete!(msg, failure_msg)
          $logger.info(msg)
          yield
        rescue Docker::Error::ConflictError => e
          $logger.error('%s - %s' % [ failure_msg, e.inspect ])
        end
    end
  end
end
