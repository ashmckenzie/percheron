module Percheron
  module CLI
    class ListCommand < AbstractCommand

      def execute
        Stack.all(config).each do |stack_name, stack|
          puts Percheron::Formatters::Stack::Table.new(stack).generate
        end
      end
    end
  end
end
