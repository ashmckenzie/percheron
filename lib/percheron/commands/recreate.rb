module Percheron
  module Commands
    class Recreate < Abstract

      default_create_parameters!

      def execute
        super
        stack.recreate!(container_names: container_names, start: start?)
      end
    end
  end
end
