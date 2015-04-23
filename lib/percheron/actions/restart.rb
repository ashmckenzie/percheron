module Percheron
  module Actions
    class Restart

      include Base

      def initialize(container)
        @container = container
      end

      def execute!
        results = []
        results << stop!
        results << start!
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container

        def stop!
          Stop.new(container).execute!
        end

        def start!
          opts = { dependant_containers: container.startable_dependant_containers.values }
          Start.new(container, opts).execute!
        end

    end
  end
end
