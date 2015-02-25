module Percheron
  module Validators
    class Config

      def initialize(config_file)
        @config_file = config_file
      end

      def valid?
        messages = []
        messages << validate_config_file_existence
        messages.compact!

        unless messages.empty?
          raise Errors::ConfigFileInvalid.new(messages)
        else
          true
        end
      end

      private

        attr_reader :config_file

        def validate_config_file_existence
          'Config file does not exist' unless config_file.exist?
        end
    end
  end
end
