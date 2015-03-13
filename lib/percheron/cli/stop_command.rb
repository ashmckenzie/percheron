module Percheron
  module CLI
    class StopCommand < AbstractCommand

      default_parameters!

      def execute
        opts = { container_names: container_names }
        Percheron::Stack.new(config, stack_name).stop!(opts)
      end
    end
  end
end
