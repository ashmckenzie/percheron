module Percheron
  module Commands
    class Purge < Abstract

      default_parameters!
      option([ '-f', '--force' ], :flag, 'Force unit/image removal', default: false)

      def execute
        super
        stack.purge!(unit_names: unit_names, force: force?)
      end
    end
  end
end
