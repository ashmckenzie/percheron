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
        $logger.debug "Executing #{description} scripts #{scripts.inspect} on '#{container.name}' container"
        results = exec!
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :dependant_containers, :scripts, :description

        def exec!
          results = []
          started_dependant_containers = start_containers!(dependant_containers)
          results << execute_scripts_on_running_container!
          results << stop_containers!(started_dependant_containers)
          results
        end

        def execute_scripts_on_running_container!
          container_running = container.running?
          Start.new(container, exec_scripts: false).execute! unless container_running
          execute_scripts!
          commit_and_tag_new_image!
          Stop.new(container).execute!  unless container_running
        end

        # FIXME
        def commit_and_tag_new_image!
          new_image = container.docker_container.commit
          new_image.tag(repo: container.image_repo, tag: container.version.to_s, force: true)
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
          $logger.info "Executing #{description} script '#{command}' for '#{container.name}' container"
          container.docker_container.exec(command.split(' ')) do |stream, out|
            $logger.debug '%s: %s' % [ stream, out.strip ]
          end
        end

        def stop_containers!(containers)
          exec_on_containers!(containers) do |container|
            Stop.new(container).execute! if container.running?
          end
        end

        def start_containers!(containers, exec_scripts: true)
          exec_on_containers!(containers) do |container|
            Start.new(container, dependant_containers: container.startable_dependant_containers.values, exec_scripts: exec_scripts).execute! unless container.running?
          end
        end

        def exec_on_containers!(containers)
          containers.each_with_object([]) do |container, all|
            all << container if yield(container)
          end.compact
        end

    end
  end
end
