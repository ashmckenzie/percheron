module Percheron
  module Commands
    class Purge < Abstract

      default_parameters!

      def execute
        super
        opts = { container_names: container_names }
        stack.purge!(opts)
      end
    end
  end
end
