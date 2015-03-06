module Percheron
  module CLI
    class RecreateCommand < AbstractCommand

      parameter 'STACK_NAME', 'stack name'

      option "--force", :flag, 'Force recreation', default: false

      def execute
        Percheron::Stack.new(config, stack_name).recreate!(force_recreate: force?, force_auto_recreate: true)
      end
    end
  end
end
