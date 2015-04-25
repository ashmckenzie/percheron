module Percheron
  module Commands
    class Purge < Abstract

      default_parameters!
      option([ '-f', '--force' ], :flag, 'Force container/image removal', default: false)

      def execute
        super
        stack.purge!(container_names: container_names, force: force?)
      end
    end
  end
end
