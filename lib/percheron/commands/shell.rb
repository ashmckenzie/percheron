module Percheron
  module Commands
    class Shell < Abstract

      parameter('STACK_NAME', 'stack name', required: true)
      parameter('CONTAINER_NAME', 'container name', required: true)

      option('--shell', 'SHELL', 'Shell to use', default: Percheron::Actions::Shell::DEFAULT_SHELL)

      def execute
        super
        stack.shell!(container_name, shell: shell)
      rescue Errors::DockerClientNotInstalled, Errors::DockerClientInsufficientVersion => e
        signal_usage_error(e.message)
      end
    end
  end
end
