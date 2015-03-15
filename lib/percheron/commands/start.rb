module Percheron
  module Commands
    class Start < Abstract

      default_parameters!

      def execute
        super
        opts = { container_names: container_names }
        stack.start!(opts)
      end
    end
  end
end
