module Percheron
  module Commands
    class Restart < Abstract

      default_parameters!

      def execute
        super
        opts = { container_names: container_names }
        stack.restart!(opts)
      end
    end
  end
end
