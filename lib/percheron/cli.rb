require 'clamp'

module Percheron
  class CLI < Clamp::Command

    class AbstractCommand < Clamp::Command
      option [ '-s', '--stack' ], 'STACK', 'Stack to perform action on'
      option [ '-c', '--config_file' ], 'CONFIG', 'Configuration file', default: '.percheron.yml'

      option '--version', :flag, 'show version' do
        puts Percheron::VERSION
        exit(0)
      end

      def config
        @config ||= Percheron::Config.new(config_file)
      rescue Errors::ConfigFileInvalid => e
        $logger.error "An error occurred - #{e.message}"
      end
    end

    class ListCommand < AbstractCommand

      def execute
        p config.stacks
      end
    end

    class MainCommand < AbstractCommand
      subcommand 'list', 'List stacks and containers', ListCommand
    end
  end
end
