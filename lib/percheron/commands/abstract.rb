module Percheron
  module Commands
    class Abstract < Clamp::Command

      option [ '-c', '--config' ], 'CONFIG', 'Config file', default: Config::DEFAULT_CONFIG_FILE

      option '--version', :flag, 'show version' do
        puts Percheron::VERSION
        exit(0)
      end

      def self.default_parameters!
        parameter('STACK_NAME', 'stack name', required: true)
        parameter('CONTAINER_NAMES', 'container names', default: []) do |container_names|
          container_names.split(/,/)
        end
      end

      def execute
        stack.valid?
      rescue => e
        signal_usage_error(e.message)
      end

      def stack
        return NullStack.new if stack_name.nil?
        Percheron::Stack.new(config, stack_name)
      end

      def default_config_file
        ENV.fetch('PERCHERON_CONFIG', Config::DEFAULT_CONFIG_FILE)
      end

      def config
        @config ||= Percheron::Config.load!(config_file)
      rescue Errors::ConfigFileInvalid => e
        $logger.error e.message
        exit(1)
      end
    end
  end
end
