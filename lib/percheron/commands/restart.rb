module Percheron
  module Commands
    class Restart < Abstract

      default_parameters!

      def execute
        super
        stack.restart!(container_names: container_names)
      end
    end
  end
end
