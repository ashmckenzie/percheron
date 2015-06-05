module Percheron
  module Actions
    class Stop

      include Base

      def initialize(unit)
        @unit = unit
      end

      def execute!
        results = []
        results << stop! if unit.running?
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit

        def stop!
          $logger.info "Stopping '#{unit.display_name}' unit"
          unit.container.stop!
        end

    end
  end
end
