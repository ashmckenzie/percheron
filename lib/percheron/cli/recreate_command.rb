module Percheron
  module CLI
    class RecreateCommand < AbstractCommand

      parameter 'STACK_NAME', 'stack name'

      def execute
        Percheron::Stack.new(config, stack_name).recreate!(bypass_auto_recreate: true)
      end
    end
  end
end
