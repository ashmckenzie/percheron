module Percheron
  module Commands
    class Abstract < Clamp::Command

      option([ '-c', '--config_file' ], 'CONFIG', 'Config file', default:
              ENV.fetch('PERCHERON_CONFIG', Config::DEFAULT_CONFIG_FILE))

      option('--version', :flag, 'show version') do
        puts Percheron::VERSION
        exit(0)
      end

      def self.default_parameters!
        parameter('STACK_NAME', 'stack name', required: true)
        parameter('UNIT_NAMES', 'unit names', default: [], required: false) do |names|
          names.split(/,/)
        end
      end

      def runit
        yield
      rescue Docker::Error::UnexpectedResponseError => e
        $logger.error('')
        $logger.error('An exception occurred :(')
        $logger.error('')
        $logger.error(e.inspect)
      end

      def execute
        stack.valid?
      rescue Errno::ENOENT, Errors::ConfigFileInvalid, Errors::DockerHostNotDefined,
             Errors::StackInvalid => e
        error!(e)
      rescue => e
        puts "%s\n\n%s\n\n" % [ e.inspect, e.backtrace.join("\n") ]
        error!(e)
      end

      def stack
        return NullStack.new if stack_name.nil?
        Percheron::Stack.new(config, stack_name)
      end

      def config
        @config ||= begin
          Percheron::Config.load!(config_file).tap do |c|
            Percheron::Connection.load!(c)
          end
        end
      rescue Errors::DockerHostNotDefined => e
        error!(e)
      end

      def error!(e, exit_code: 1)
        signal_usage_error(e.message)
        exit(exit_code)
      end
    end
  end
end
