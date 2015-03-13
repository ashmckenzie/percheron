module Percheron
  module Commands
    class Stop < Abstract

      default_parameters!

      def execute
        opts = { container_names: container_names }
        Percheron::Stack.new(config, stack_name).stop!(opts)
      end
    end
  end
end
