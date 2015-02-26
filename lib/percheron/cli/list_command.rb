module Percheron
  module CLI
    class ListCommand < AbstractCommand

      def execute
        Stack.all(config).each do |stack_name, stack|
          ap stack
          stack.container_configs.each do |container_name, container_config|
            ap container_config
          end
        end
      end
    end
  end
end
