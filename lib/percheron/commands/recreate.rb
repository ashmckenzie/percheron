module Percheron
  module Commands
    class Recreate < Abstract

      default_parameters!

      option '--force', :flag, 'Force recreation', default: false
      option '--delete', :flag, 'Delete container + image before recreation', default: false

      def execute
        super

        opts = {
          container_names: container_names,
          force_recreate: force?,
          delete: delete?
        }

        stack.recreate!(opts)
      end
    end
  end
end
