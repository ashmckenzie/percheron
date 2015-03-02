module Percheron
  module CLI
    class AbstractCommand < Clamp::Command

      DEFAULT_CONFIG_FILE = '.percheron.yml'

      option [ '-c', '--config_file' ], 'CONFIG', 'Configuration file', default: DEFAULT_CONFIG_FILE

      option '--version', :flag, 'show version' do
        puts Percheron::VERSION
        exit(0)
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
