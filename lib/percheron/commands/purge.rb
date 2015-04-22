module Percheron
  module Commands
    class Purge < Abstract

      default_parameters!

      def execute
        super
        stack.purge!(container_names: container_names)
      end
    end
  end
end
