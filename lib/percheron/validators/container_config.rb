module Percheron
  module Validators
    class ContainerConfig

      def initialize(container_config)
        @container_config = container_config
      end

      def valid?
        message = rules.return { |rule| send(rule) }

        if message
          raise Errors::ContainerConfigInvalid.new(message)
        else
          true
        end
      end

      private

        attr_reader :container_config

        def rules
          [
            :validate_name,
            :validate_version,
            :validate_dockerfile
          ]
        end

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
