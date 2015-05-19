module Percheron
  module Commands
    class Graph < Abstract

      parameter('STACK_NAME', 'stack name', required: true)
      option([ '-o', '--output' ], 'OUTPUT', 'Output file')

      def execute
        super
        stack.graph!(output || default_output)
      end

      def default_output
        'percheron_%s.png' % stack.name
      end
    end
  end
end
