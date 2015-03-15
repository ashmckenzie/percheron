module Percheron
  module Commands
    class List < Abstract

      parameter('STACK_NAME', 'stack name', required: false)

      def execute
        super
        Stack.get(config, stack_name).each do |_, stack|
          puts
          puts Percheron::Formatters::Stack::Table.new(stack).generate
        end
      end
    end
  end
end
