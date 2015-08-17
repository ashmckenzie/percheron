module Percheron
  module Actions
    class Start
      include Base

      def initialize(unit, dependant_units: [], cmd: false, exec_scripts: true)
        @unit = unit
        @dependant_units = dependant_units
        @cmd = cmd
        @exec_scripts = exec_scripts
      end

      def execute!
        results = []
        results << create!
        unless unit.running?
          results << start!
          results << execute_post_start_scripts!
        end
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :dependant_units, :cmd, :exec_scripts

        def exec_scripts?
          !unit.post_start_scripts.empty? && exec_scripts
        end

        def create!
          return nil if unit.exists?
          Create.new(unit, cmd: cmd).execute!
        end

        def start!
          return nil if !unit.startable? || unit.running?
          $logger.info "Starting '#{unit.display_name}' unit"
          unit.container.start!
        end

        def execute_post_start_scripts!
          scripts = unit.post_start_scripts
          Exec.new(unit, dependant_units, scripts, 'POST start').execute! if exec_scripts?
        end

    end
  end
end
