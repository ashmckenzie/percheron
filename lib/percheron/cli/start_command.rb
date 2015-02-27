module Percheron
  module CLI
    class StartCommand < AbstractCommand

      parameter 'STACK_NAME', 'stack name'

      def execute
        Percheron::DockerConnection.new(config).setup!  # FIXME
        Percheron::Stack.new(config, stack_name).start!
      end
    end
  end
end
