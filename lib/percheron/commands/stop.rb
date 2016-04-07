module Percheron
  module Commands
    class Stop < Abstract
      new_default_parameters!

      def execute
        super
        runit { stack.stop!(unit_names: unit_names) }
      end
    end
  end
end
