module Percheron
  module Commands
    class Recreate < Abstract

      default_parameters!

      option '--start', :flag, 'Start container', default: false

      def execute
        super
        stack.recreate!(container_names: container_names, start: start?)
      end
    end
  end
end
