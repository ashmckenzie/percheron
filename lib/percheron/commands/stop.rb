module Percheron
  module Commands
    class Stop < Abstract

      default_parameters!

      def execute
        super
        stack.stop!(container_names: container_names)
      end
    end
  end
end
