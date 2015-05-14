module Percheron
  module Commands
    class Create < Abstract

      default_create_parameters!

      def execute
        super
        stack.create!(unit_names: unit_names, start: start?)
      end
    end
  end
end
