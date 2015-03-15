module Percheron
  module Actions
    class Start

      include Base

      def initialize(container, dependant_containers: [], exec_scripts: true)
        @container = container
        @dependant_containers = dependant_containers
        @exec_scripts = exec_scripts
      end

      def execute!
        results = []
        results << create! unless container.exists?
        unless container.running?
          results << start!
          results << execute_post_start_scripts! if exec_scripts?
        end
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :dependant_containers, :exec_scripts

        def exec_scripts?
          !container.post_start_scripts.empty? && exec_scripts
        end

        def create!
          $logger.info "Creating '#{container.name}' container as it doesn't exist"
          Create.new(container).execute!
        end

        def start!
          $logger.info "Starting '#{container.name}' container"
          container.docker_container.start!
        end

        def execute_post_start_scripts!
          Exec.new(container, dependant_containers, container.post_start_scripts, 'POST start').execute!
        end

    end
  end
end
