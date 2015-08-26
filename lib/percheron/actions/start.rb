module Percheron
  module Actions
    class Start
      include Base

      def initialize(unit, needed_units: [], create: true, cmd: false)
        @unit = unit
        @needed_units = needed_units
        @create = create
        @cmd = cmd
      end

      def execute!
        return nil if unit.running?
        results = [ create! ]
        results << start! if unit.startable?
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :needed_units, :create, :cmd
        alias_method :create?, :create

        def create!
          return nil unless create?
          Create.new(unit, cmd: cmd).execute!
        end

        def start!
          return nil if unit_running?
          if needed_unit_names_not_running.empty?
            $logger.info "Starting '#{unit.display_name}' unit"
            unit.container.start!
          else
            $logger.error "Cannot start '%s' unit, %s not running" %
              [ unit.display_name, needed_unit_names_not_running ]
          end
        end

        def unit_running?
          !unit.startable? || unit.running?
        end

        def needed_unit_names_not_running
          @needed_unit_names_not_running ||= begin
            unit.startable_needed_units.each_with_object([]) do |unit_tuple, all|
              _, unit = unit_tuple
              all << unit.name unless unit.running?
            end
          end
        end
    end
  end
end
