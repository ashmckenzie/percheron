module Percheron
  module Commands
    class Start < Abstract

      default_parameters!

      def execute
        opts = { container_names: container_names }
        Percheron::Stack.new(config, stack_name).start!(opts)
      end
    end
  end
end
