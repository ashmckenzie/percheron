module Percheron
  module Commands
    class Graph < Abstract

      parameter('STACK_NAMES', 'stack names', default: [], required: false) { |s| s.split(/[, ]/) }
      option([ '-o', '--output' ], 'OUTPUT', 'Output file')

      def execute
        super
        stack.graph!(output)
      end

      def default_output
        'percheron_stack.png'
      end

    end
  end
end
