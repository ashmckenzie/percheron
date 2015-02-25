module Percheron
  module Validators
    class ContainerConfig

      def initialize(container_config)
        @container_config = container_config
      end

      def valid?
        messages = []
        messages << validate_name
        messages << validate_version
        messages << validate_dockerfile
        messages.compact!

        unless messages.empty?
          raise Errors::ContainerConfigInvalid.new(messages)
        else
          true
        end
      end

      private

        attr_reader :container_config

        def validate_name
          'Name is invalid' if container_config.name.nil? || !container_config.name.match(/[\w\d]{3,}/)
        end

        def validate_version
          'Version is invalid' if container_config.version.nil? || !container_config.version.match(/[\w\d]{1,}/)
        end

        def validate_dockerfile
          'Dockerfile is invalid' if container_config.dockerfile.nil? || !File.exist?(container_config.dockerfile)
        end
    end
  end
end
