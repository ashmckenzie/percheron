module Percheron
  module Actions
    class Shell
      include Base

      DEFAULT_COMMAND = '/bin/sh'
      DOCKER_CLIENT = 'docker'

      def initialize(unit, command: DEFAULT_COMMAND)
        @unit = unit
        @command = command
      end

      def execute!
        exec! if valid?
      end

      private

        attr_reader :unit

        def valid?
          Validators::DockerClient.new.valid?
        end

        def command
          "sh -c '%s'" % @command
        end

        def exec!
          cmd = '%s exec -ti %s %s' % [ DOCKER_CLIENT, unit.full_name, command ]
          $logger.debug %(Executing "#{cmd}" on '#{unit.name}' unit)
          system(cmd)
        end
    end
  end
end
