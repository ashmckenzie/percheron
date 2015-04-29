module Percheron
  module Actions
    class Shell
      include Base

      DEFAULT_COMMAND = '/bin/sh'
      DOCKER_CLIENT = 'docker'

      def initialize(container, command: DEFAULT_COMMAND)
        @container = container
        @command = command
      end

      def execute!
        exec! if valid?
      end

      private

        attr_reader :container

        def valid?
          Validators::DockerClient.new.valid?
        end

        def command
          "sh -c '%s'" % @command
        end

        def exec!
          cmd = '%s exec -ti %s %s' % [ DOCKER_CLIENT, container.full_name, command ]
          $logger.debug "Executing '#{cmd}' on '#{container.name}' container"
          system(cmd)
        end
    end
  end
end
