module Percheron
  module Actions
    class Start

      include Base

      def initialize(container, dependant_containers=[])
        @container = container
        @dependant_containers = dependant_containers
      end

      def execute!
        create! unless container.exists?
        unless container.running?
          start!
          execute_post_start_scripts! unless container.post_start_scripts.empty?
        end
        container
      end

      private

        attr_reader :container, :dependant_containers

        def create!
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
