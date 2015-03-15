module Percheron
  module Commands
    class Restart < Abstract

      default_parameters!

      def execute
        opts = { container_names: container_names }
        stack.restart!(opts)
      end
    end
  end
end
