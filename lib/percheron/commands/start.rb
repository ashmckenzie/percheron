module Percheron
  module Commands
    class Start < Abstract

      default_parameters!

      def execute
        super
        stack.start!(container_names: container_names)
      end
    end
  end
end
