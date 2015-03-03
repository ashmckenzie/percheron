module Percheron
  module CLI
    class ListCommand < AbstractCommand

      parameter 'STACK_NAME', 'stack name', required: false

      def execute
        stacks = if stack_name
          Stack.get(config, stack_name)
        else
          Stack.all(config)
        end

        stacks.each do |stack_name, stack|
          puts
          puts Percheron::Formatters::Stack::Table.new(stack).generate
        end
      end
    end
  end
end
