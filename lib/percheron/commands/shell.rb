module Percheron
  module Commands
    class Shell < Abstract

      parameter('STACK_NAME', 'stack name', required: true)
      parameter('CONTAINER_NAME', 'container name', required: true)
      option('--command', 'COMMAND', 'command', default: Percheron::Actions::Shell::DEFAULT_COMMAND)

      def execute
        super
        stack.shell!(container_name, command: command)
      rescue Errors::DockerClientInvalid => e
        signal_usage_error(e.message)
      end
    end
  end
end
