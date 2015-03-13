module Percheron
  module CLI
    class ListCommand < AbstractCommand

      parameter('STACK_NAME', 'stack name', required: false)

      def execute
        Stack.get(config, stack_name).each do |stack_name, stack|
          puts
          puts Percheron::Formatters::Stack::Table.new(stack).generate
        end
      end
    end
  end
end
