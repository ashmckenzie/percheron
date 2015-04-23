module Percheron
  module Actions
    class Logs
      include Base

      def initialize(container, follow: false)
        @container = container
        @follow = follow
      end

      def execute!
        $logger.debug "Showing logs on '#{container.name}' container"
        display_logs!
      end

      private

        attr_reader :container, :follow
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
            container.docker_container.streaming_logs(opts) do |stream, chunk|
              puts "#{stream}: #{chunk}"
            end
          else
            puts container.docker_container.logs(options)
          end
        rescue Interrupt
          nil
        end
    end
  end
end
