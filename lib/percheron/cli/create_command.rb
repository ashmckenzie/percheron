module Percheron
  module CLI
    class CreateCommand < AbstractCommand

      parameter 'STACK_NAME', 'stack name'

      def execute
        Percheron::Stack.new(config, stack_name).create!
      end
    end
  end
end
