module Percheron
  module Actions
    class Start
      include Base

      def initialize(unit, needed_units: [], create: true, cmd: false, exec_scripts: true)
        @unit = unit
        @needed_units = needed_units
        @create = create
        @cmd = cmd
        @exec_scripts = exec_scripts
      end

      def execute!
        return nil if unit.running?
        results = [ create! ]
        if unit.startable?
          results << start!
          results << execute_post_start_scripts!
        end
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :needed_units, :create, :cmd, :exec_scripts
        alias_method :create?, :create

        def exec_scripts?
          !unit.post_start_scripts.empty? && exec_scripts
        end

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

        def execute_post_start_scripts!
          scripts = unit.post_start_scripts
          Exec.new(unit, needed_units, scripts, 'POST start').execute! if exec_scripts?
        end

    end
  end
end
