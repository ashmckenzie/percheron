module Percheron
  module Actions
    class Logs
      include Base

      def initialize(unit, follow: false)
        @unit = unit
        @follow = follow
      end

      def execute!
        $logger.debug "Showing logs on '#{unit.name}' unit"
        display_logs!
      end

      private

        attr_reader :unit, :follow
        alias_method :follow?, :follow

        def options
          {
            stdout:     true,
            stderr:     true,
            timestamps: true,
            tail:       100
          }
        end

        def display_logs!
          if follow?
            opts = options.merge(follow: true)
            unit.container.streaming_logs(opts) do |stream, chunk|
              puts "#{stream}: #{chunk}"
            end
          else
            puts unit.container.logs(options)
          end
        rescue Interrupt
          nil
        end
    end
  end
end
