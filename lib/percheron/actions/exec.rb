module Percheron
  module Actions
    class Exec

      include Base

      def initialize(container, dependant_containers, scripts, description)
        @container = container
        @dependant_containers = dependant_containers
        @scripts = scripts
        @description = description
      end

      def execute!
        results = []
        $logger.debug "Executing #{description} scripts '#{scripts.inspect}' on '#{container.name}'"
        started_dependant_containers = start_containers!(dependant_containers)
        results << execute_scripts_on_running_container!
        results << stop_containers!(started_dependant_containers)
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :dependant_containers, :scripts, :description

        def execute_scripts_on_running_container!
          container_running = container.running?
          Start.new(container, exec_scripts: false).execute! unless container_running
          execute_scripts!
          Stop.new(container).execute!  unless container_running
        end

        def execute_scripts!
          scripts.each do |script|
            in_working_directory(base_dir) do
              file = Pathname.new(File.expand_path(script, base_dir))
              execute_command!('/bin/bash -x /tmp/%s 2>&1' % file.basename)
            end
          end
        end

        def execute_command!(command)
          $logger.info "Executing #{description} '#{command}' for '#{container.name}' container"
          container.docker_container.exec(command.split(' ')) do |device, out|
            $logger.debug '%s: %s' % [ device, out.strip ]
          end
        end

    end
  end
end
