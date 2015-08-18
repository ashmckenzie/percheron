module Percheron
  module Commands
    class Restart < Abstract

      default_parameters!

      def execute
        super
        runit { stack.restart!(unit_names: unit_names) }
      end
    end
  end
end
