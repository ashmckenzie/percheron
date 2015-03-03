module Percheron
  module CLI
    class RestartCommand < AbstractCommand

      parameter 'STACK_NAME', 'stack name'

      def execute
        Percheron::Stack.new(config, stack_name).restart!
      end
    end
  end
end
