module Percheron
  module CLI
    class RestartCommand < AbstractCommand

      default_parameters!

      def execute
        opts = { container_names: container_names }
        Percheron::Stack.new(config, stack_name).restart!(opts)
      end
    end
  end
end
