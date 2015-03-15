module Percheron
  module Commands
    class Stop < Abstract

      default_parameters!

      def execute
        opts = { container_names: container_names }
        stack.stop!(opts)
      end
    end
  end
end
