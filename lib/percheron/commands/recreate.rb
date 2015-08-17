module Percheron
  module Commands
    class Recreate < Abstract

      default_create_parameters!
      option([ '-f', '--force' ], :flag, 'Force recreation', default: false)

      def execute
        super
        stack.recreate!(unit_names: unit_names, start: start?, force: force?)
      end
    end
  end
end
