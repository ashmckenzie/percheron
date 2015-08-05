module Percheron
  module Commands
    class Abstract < Clamp::Command

      option([ '-c', '--config_file' ], 'CONFIG', 'Config file',
             default: Config::DEFAULT_CONFIG_FILE)

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

      def self.default_create_parameters!
        default_parameters!
        option('--start', :flag, 'Start unit', default: false)
      end

      def default_config_file
        ENV.fetch('PERCHERON_CONFIG', Config::DEFAULT_CONFIG_FILE)
      end

      def execute
        stack.valid?
      rescue => e
        puts "%s\n\n%s\n\n" % [ e.inspect, e.backtrace.join("\n") ]
        signal_usage_error(e.message)
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
      rescue Errors::ConfigFileInvalid => e
        $logger.error e.inspect
        exit(1)
      end
    end
  end
end
