module Percheron
  module Commands
    class List < Abstract

      parameter('STACK_NAME', 'stack name', required: false)

      def execute
        super
        Stack.get(config, stack_name).each do |_, stack|
          begin
            stack.valid?
            puts("\n", Percheron::Formatters::Stack::Table.new(stack).generate)
          rescue Percheron::Errors::StackInvalid => e
            signal_usage_error(e.message)
          end
        end
      end
    end
  end
end
