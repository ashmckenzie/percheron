module Percheron
  module Commands
    class Build < Abstract

      default_parameters!

      def execute
        super
        stack.build!(container_names: container_names)
      end
    end
  end
end
