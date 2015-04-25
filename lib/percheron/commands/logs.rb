module Percheron
  module Commands
    class Logs < Abstract

      parameter('STACK_NAME', 'stack name', required: true)
      parameter('CONTAINER_NAME', 'container name', required: true)
      option('--follow', :flag, 'follow the logs', default: false)

      def execute
        super
        stack.logs!(container_name, follow: follow?)
      end
    end
  end
end
