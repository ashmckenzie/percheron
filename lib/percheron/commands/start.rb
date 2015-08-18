module Percheron
  module Commands
    class Start < Abstract

      default_parameters!

      def execute
        super
        runit { stack.start!(unit_names: unit_names) }
      end
    end
  end
end
