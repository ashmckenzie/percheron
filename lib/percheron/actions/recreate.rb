module Percheron
  module Actions
    class Recreate

      include Base

      def initialize(unit, start: false, force: false)
        @unit = unit
        @start = start
        @force = force
      end

      def execute!
        results = []
        if recreate? || force?
          results << recreate!
          results << start!
        else
          inform!
        end
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :start, :force
        alias_method :start?, :start
        alias_method :force?, :force

        def recreate?
          !unit.versions_match? || !unit.dockerfile_md5s_match?
        end

        def inform!
          return nil unless unit.dockerfile_md5s_match?
          $logger.info "Unit '#{unit.display_name}' - No Dockerfile changes or version bump"
        end

        def recreate!
          $logger.debug "Unit '#{unit.display_name}' exists but will be recreated"
          Purge.new(unit).execute!
          Create.new(unit).execute!
        end

        def start!
          Start.new(unit).execute! if start?
        end

    end
  end
end
