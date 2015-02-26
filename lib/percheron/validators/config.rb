module Percheron
  module Validators
    class Config

      def initialize(config_file)
        @config_file = config_file
      end

      def valid?
        message = rules.return { |rule| send(rule) }

        if message
          raise Errors::ConfigFileInvalid.new(message)
        else
          true
        end
      end

      private

        attr_reader :config_file

        def rules
          [
            :validate_config_file_existence,
            :validate_config_file_not_empty,
            :validate_config_file_contents
          ]
        end

        def config_file_contents
          @config_file_contents ||= Hashie::Mash.new(YAML.load_file(config_file))
        end

        def validate_config_file_existence
          'Config file does not exist' unless config_file.exist?
        end

        def validate_config_file_not_empty
          'Config file is empty' if config_file_contents.empty?
        end

        def validate_config_file_contents
          'Config file is invalid' unless config_file_contents.docker
        end
    end
  end
end
