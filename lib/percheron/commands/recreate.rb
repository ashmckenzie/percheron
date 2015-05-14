module Percheron
  module Commands
    class Recreate < Abstract

      default_create_parameters!

      def execute
        super
        stack.recreate!(unit_names: unit_names, start: start?)
      end
    end
  end
end
