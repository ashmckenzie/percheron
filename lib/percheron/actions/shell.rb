module Percheron
  module Actions
    class Shell
      include Base

      DEFAULT_SHELL = '/bin/sh'
      DOCKER_CLIENT = 'docker'

      def initialize(container, shell: DEFAULT_SHELL)
        @container = container
        @shell = shell
      end

      def execute!
        Validators::DockerClient.new.validate_docker_client_available!
        $logger.debug "Executing #{shell} on '#{container.name}' container"
        exec!
      end

      private

        attr_reader :container, :shell

        def exec!
          system('%s exec -ti %s %s' % [ DOCKER_CLIENT, container.full_name, shell ])
        end
    end
  end
end
