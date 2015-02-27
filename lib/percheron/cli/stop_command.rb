module Percheron
  module CLI
    class StopCommand < AbstractCommand

      parameter 'STACK_NAME', 'stack name'

      def execute
        Percheron::DockerConnection.new(config).setup!  # FIXME
        Percheron::Stack.new(config, stack_name).stop!
      end
    end
  end
end
