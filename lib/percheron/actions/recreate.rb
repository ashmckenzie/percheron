module Percheron
  module Actions
    class Recreate

      include Base

      def initialize(unit, start: false)
        @unit = unit
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
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :start
        alias_method :start?, :start

        def recreate?
          !unit.versions_match? || !unit.dockerfile_md5s_match?
        end

        def inform!
          return nil unless unit.dockerfile_md5s_match?
          $logger.info "Unit '#{unit.name}' - No Dockerfile changes or version bump"
        end

        def recreate!
          $logger.debug "Unit '#{unit.name}' exists but will be recreated"
          Purge.new(unit).execute!
          Create.new(unit).execute!
        end

        def start!
          Start.new(unit).execute! if start?
        end

    end
  end
end
