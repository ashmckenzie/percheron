module Percheron
  module Actions
    class Start

      include Base

      def initialize(container, dependant_containers: [], cmd: false, exec_scripts: true)
        @container = container
        @dependant_containers = dependant_containers
        @cmd = cmd
        @exec_scripts = exec_scripts
      end

      def execute!
        results = []
        results << create!
        unless container.running?
          results << start!
          results << execute_post_start_scripts!
        end
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :dependant_containers, :cmd, :exec_scripts

        def exec_scripts?
          !container.post_start_scripts.empty? && exec_scripts
        end

        def create!
          return nil if container.exists?
          Create.new(container, cmd: cmd, exec_scripts: exec_scripts).execute!
        end

        def start!
          return nil if !container.startable? || container.running?
          $logger.info "Starting '#{container.name}' container"
          container.docker_container.start!
        end

        def execute_post_start_scripts!
          Exec.new(container, dependant_containers, container.post_start_scripts, 'POST start').execute! if exec_scripts?
        end

    end
  end
end
