module Percheron
  module Commands
    class Create < Abstract

      default_parameters!

      def execute
        super
        opts = { container_names: container_names }
        stack.create!(opts)
      end
    end
  end
end
