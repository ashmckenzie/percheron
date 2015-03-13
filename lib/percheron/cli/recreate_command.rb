module Percheron
  module CLI
    class RecreateCommand < AbstractCommand

      default_parameters!

      option "--force", :flag, 'Force recreation', default: false
      option "--delete", :flag, 'Delete container + image before recreation', default: false

      def execute
        opts = {
          container_names: container_names,
          force_recreate: force?,
          delete: delete?
        }

        Percheron::Stack.new(config, stack_name).recreate!(opts)
      end
    end
  end
end
