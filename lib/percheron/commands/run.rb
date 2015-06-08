module Percheron
  module Commands
    class Run < Abstract

      parameter('STACK_NAME', 'stack name', required: true)
      parameter('UNIT_NAME', 'unit name', required: true)
      option('--interactive', :flag, 'Interactive mode', default: false)
      option('--command', 'COMMAND', 'command', required: true)

      def execute
        super
        puts stack.run!(unit_name, interactive: interactive?, command: command)
      rescue Errors::DockerClientInvalid => e
        signal_usage_error(e.message)
      end
    end
  end
end
