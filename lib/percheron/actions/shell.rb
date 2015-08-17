module Percheron
  module Actions
    class Shell
      include Base

      DEFAULT_COMMAND = '/bin/sh'
      DOCKER_CLIENT = 'docker'

      def initialize(unit, raw_command: DEFAULT_COMMAND)
        @unit = unit
        @raw_command = raw_command
      end

      def execute!
        exec! if valid?
      end

      private

        attr_reader :unit, :raw_command

        def valid?
          Validators::DockerClient.new.valid?
        end

        def command
          "sh -c '%s'" % [ raw_command ]
        end

        def exec!
          cmd = '%s exec -ti %s %s' % [ DOCKER_CLIENT, unit.full_name, command ]
          $logger.debug %(Executing "#{cmd}" on '#{unit.display_name}' unit)
          system(cmd)
        end
    end
  end
end
