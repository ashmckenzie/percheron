module Percheron
  module Actions
    class Recreate

      include Base

      def initialize(container, start: false)
        @container = container
        @start = start
      end

      def execute!
        results = []
        if recreate?
          results << recreate!
          results << start!
        else
          inform!
        end
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :start
        alias_method :start?, :start

        def recreate?
          !container.versions_match? || !container.dockerfile_md5s_match?
        end

        def inform!
          return nil unless container.dockerfile_md5s_match?
          $logger.info "Container '#{container.name}' - No Dockerfile changes or version bump"
        end

        def recreate!
          $logger.debug "Container '#{container.name}' exists but will be recreated"
          Purge.new(container).execute!
          Create.new(container).execute!
        end

        def start!
          Start.new(container).execute! if start?
        end

    end
  end
end
