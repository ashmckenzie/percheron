module Percheron
  module Actions
    class Restart
      include Base

      def initialize(unit)
        @unit = unit
      end

      def execute!
        results = []
        results << stop!
        results << start!
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit

        def stop!
          Stop.new(unit).execute!
        end

        def start!
          opts = { needed_units: unit.startable_needed_units.values, create: false }
          Start.new(unit, opts).execute!
        end

    end
  end
end
