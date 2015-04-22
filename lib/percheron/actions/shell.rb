module Percheron
  module Actions
    class Shell
      include Base

      DEFAULT_SHELL = '/bin/sh'

      def initialize(container, shell: DEFAULT_SHELL)
        @container = container
        @shell = shell
      end

      def execute!
        $logger.debug "Executing a bash shell on '#{container.name}' container"
        exec!
      end

      private

        attr_reader :container, :shell

        def exec!
          system('docker exec -ti %s %s' % [ container.full_name, shell ])
        end
    end
  end
end
