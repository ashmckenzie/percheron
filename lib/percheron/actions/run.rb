module Percheron
  module Actions
    class Run
      include Base

      DOCKER_CLIENT = 'docker'

      def initialize(unit, command: nil, interactive: false)
        @unit = unit
        @command = command
        @interactive = interactive
      end

      def execute!
        run! if valid?
      end

      private

        attr_reader :unit, :interactive
        alias_method :interactive?, :interactive

        def valid?
          Validators::DockerClient.new.valid?
        end

        def command
          "sh -c '%s'" % @command
        end

        def options
          o = %w(-t)
          o << '-i' if interactive?
          o.join(' ')
        end

        def run!
          cmd = '%s exec %s %s %s' % [ DOCKER_CLIENT, options, unit.full_name, command ]
          $logger.debug %(Executing "#{cmd}" on '#{unit.display_name}' unit)
          call!(cmd)
        end

        def call!(cmd)
          interactive? ? system(cmd) : `#{cmd}`
        end
    end
  end
end
