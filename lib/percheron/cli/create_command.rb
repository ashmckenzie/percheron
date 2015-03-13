module Percheron
  module CLI
    class CreateCommand < AbstractCommand

      default_parameters!

      def execute
        opts = { container_names: container_names }
        Percheron::Stack.new(config, stack_name).create!(opts)
      end
    end
  end
end
