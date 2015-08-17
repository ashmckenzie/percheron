module Percheron
  module Commands
    class Shell < Abstract

      parameter('STACK_NAME', 'stack name', required: true)
      parameter('UNIT_NAME', 'unit name', required: true)
      option('--command', 'COMMAND', 'command', default: Percheron::Actions::Shell::DEFAULT_COMMAND)

      def execute
        super
        stack.shell!(unit_name, raw_command: command)
      rescue Errors::DockerClientInvalid => e
        signal_usage_error(e.message)
      end
    end
  end
end
