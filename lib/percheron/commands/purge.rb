module Percheron
  module Commands
    class Purge < Abstract

      parameter('STACK_NAME', 'stack name', required: false)

      def execute
        Percheron::Stack.new(config, stack_name).purge!
      end
    end
  end
end
