module Percheron
  module Commands
    class Graph < Abstract

      parameter('STACK_NAME', 'stack name', required: false)

      def execute
        super
         Percheron::Graph.new(config, Stack.all(config), stack_name).save!(file_name)
      end

      private

        def file_name
          'percheron_%s.png' % [ stack.name || 'all' ]
        end
    end
  end
end
