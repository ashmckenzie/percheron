module Percheron
  module Commands
    class Abstract < Clamp::Command

      DEFAULT_CONFIG_FILE = '.percheron.yml'

      option [ '-c', '--config_file' ], 'CONFIG', 'Configuration file', default: DEFAULT_CONFIG_FILE

      option '--version', :flag, 'show version' do
        puts Percheron::VERSION
        exit(0)
      end

      def self.default_parameters!
        parameter('STACK_NAME', 'stack name', required: false)
        parameter('CONTAINER_NAMES', 'container names', required: false, default: []) do |container_names|
          container_names.split(/,/)
        end
      end

      def stack
        Percheron::Stack.new(config, stack_name)
      end

      def default_config_file
        ENV.fetch('PERCHERON_CONFIG', DEFAULT_CONFIG_FILE)
      end

      def config
        @config ||= Percheron::Config.new(config_file)
      rescue Errors::ConfigFileInvalid => e
        $logger.error e.message
        exit(1)
      end
    end
  end
end
