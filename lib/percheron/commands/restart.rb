module Percheron
  module Commands
    class Restart < Abstract

      default_parameters!

      def execute
        opts = { container_names: container_names }
        Percheron::Stack.new(config, stack_name).restart!(opts)
      end
    end
  end
end
