module Percheron
  module Actions
    class Exec

      include Base

      def initialize(unit, dependant_units, scripts, description)
        @unit = unit
        @dependant_units = dependant_units
        @scripts = scripts
        @description = description
      end

      def execute!
        $logger.debug "Executing #{description} #{scripts.inspect} on '#{unit.name}' unit"
        results = exec!
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :dependant_units, :scripts, :description

        def exec!
          results = []
          started_dependant_units = start_units!(dependant_units)
          results << execute_scripts_on_running_unit!
          results << stop_units!(started_dependant_units)
          results
        end

        def execute_scripts_on_running_unit!
          unit_running = unit.running?
          Start.new(unit, exec_scripts: false).execute! unless unit_running
          execute_scripts!
          commit_and_tag_new_image!
          Stop.new(unit).execute!  unless unit_running
        end

        def commit_and_tag_new_image!
          new_image = unit.container.commit
          new_image.tag(repo: unit.image_repo, tag: unit.version.to_s, force: true)
        end

        def execute_scripts!
          scripts.each do |script|
            in_working_directory(base_dir) do
              file = Pathname.new(File.expand_path(script, base_dir))
              execute_command!('/bin/sh /tmp/%s 2>&1' % file.basename)
            end
          end
        end

        def execute_command!(command)
          $logger.info "Executing #{description} '#{command}' for '#{unit.name}' unit"
          unit.container.exec(command.split(' ')) do |stream, out|
            $logger.debug '%s: %s' % [ stream, out.strip ]
          end
        end

        def stop_units!(units)
          exec_on_units!(units) do |unit|
            Stop.new(unit).execute! if unit.running?
          end
        end

        def start_units!(units, scripts: true)
          exec_on_units!(units) do |unit|
            next if unit.running?
            units = unit.startable_dependant_units.values
            Start.new(unit, dependant_units: units, exec_scripts: scripts).execute!
          end
        end

        def exec_on_units!(units)
          units.each_with_object([]) do |unit, all|
            all << unit if yield(unit)
          end.compact
        end

    end
  end
end
