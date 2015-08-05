module Percheron
  module Validators
    class Config

      def initialize(config_file)
        @config_file = config_file
      end

      def valid?
        message = rules.return { |rule| send(rule) }
        message ? fail(Errors::ConfigFileInvalid, formatted_message(message)) : true
      end

      private

        attr_reader :config_file

        def formatted_message(message)
          "Config is invalid: #{message}"
        end

        def rules
          [
            :validate_config_file_defined,
            :validate_config_file_existence,
            :validate_config_file_not_empty
          ]
        end

        def config_file_contents
          @config_file_contents ||= Hashie::Mash.new(YAML.load_file(config_file))
        end

        def validate_config_file_defined
          'Is not defined' if config_file.nil?
        end

        def validate_config_file_existence
          'Does not exist' unless config_file.exist?
        end

        def validate_config_file_not_empty
          'Is empty' if config_file_contents.empty?
        end

    end
  end
end
