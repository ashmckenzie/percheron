module Percheron
  module Commands
    class Create < Abstract

      default_parameters!

      option('--start', :flag, 'Start container', default: false)

      def execute
        super
        stack.create!(container_names: container_names, start: start?)
      end
    end
  end
end
