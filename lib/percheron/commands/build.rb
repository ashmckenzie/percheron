module Percheron
  module Commands
    class Build < Abstract

      default_parameters!

      def execute
        super
        stack.build!(unit_names: unit_names)
      end
    end
  end
end
