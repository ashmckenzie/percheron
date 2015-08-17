module Percheron
  module Commands
    class Logs < Abstract

      parameter('STACK_NAME', 'stack name', required: true)
      parameter('UNIT_NAME', 'unit name', required: true)
      option([ '-f', '-t', '--follow', '--tail' ], :flag, 'Follow the logs', default: false)

      def execute
        super
        stack.logs!(unit_name, follow: follow?)
      end
    end
  end
end
