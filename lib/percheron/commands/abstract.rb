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
        parameter('STACK_NAMES', 'stack names', required: true) { |s| s.split(/[, ]/) }
        parameter('UNIT_NAMES', 'unit names', default: [], required: false) { |n| n.split(/[, ]/) }
      end

      def self.default_create_parameters!
        default_parameters!
        option('--start', :flag, 'Start unit', default: false)
      end

      def default_config_file
        ENV.fetch('PERCHERON_CONFIG', Config::DEFAULT_CONFIG_FILE)
      end

      def execute
        validate_one_stack_only_if_units_defined!
        stack.valid?
      rescue => e
        puts "%s\n\n%s\n\n" % [ e.inspect, e.backtrace.join("\n") ]
        signal_usage_error(e.message)
      end

      def stack
        return [ NullStackProxy.new ] if stack_names.empty?
        Percheron::StackProxy.new(config, stack_names)
      end

      def config
        @config ||= begin
          Percheron::Config.new(config_file).tap do |c|
            Percheron::Connection.load!(c)
          end
        end
      rescue Errors::ConfigFileInvalid => e
        $logger.error e.inspect
        exit(1)
      end

      private

        def validate_one_stack_only_if_units_defined!
          # fail(Errors::MultipleStacksAndUnitsDefined,
          #   'Units cannot be specified if multiple stacks defined')
        end
    end
  end
end
