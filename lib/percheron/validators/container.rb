module Percheron
  module Validators
    class Container

      def initialize(container)
        @container = container
      end

      def valid?
        message = rules.return { |rule| send(rule) }

        if message
          fail Errors::ContainerInvalid, formatted_message(message)
        else
          true
        end
      end

      private

        attr_reader :container

        def formatted_message(message)
          if container.name
            "Container config for '%s' is invalid: %s" % [ container.name, message ]
          else
            "Container config is invalid: #{message}"
          end
        end

        def rules
          [
            :validate_name,
            :validate_dockerfile_and_image_name,
            :validate_dockerfile,
            :validate_image,
            :validate_version
          ]
        end

        def validate_name
          'Container name is invalid' if container.name.nil? || !container.name.to_s.match(/[\w]{3,}/)
        end

        def validate_dockerfile_and_image_name
          'Container Dockerfile OR image name not provided' if container.dockerfile.nil? && container.docker_image.nil?
        end

        def validate_dockerfile
          'Container Dockerfile is invalid' if !container.dockerfile.nil? && !File.exist?(container.dockerfile)
        end

        def validate_image
          'Container Docker image is invalid' if !container.docker_image.nil? && !container.docker_image.match(/^.+:.+$/)
        end

        def validate_version
          container.version ? nil : fail(ArgumentError)
        rescue ArgumentError
          'Container version is invalid'
        end

    end
  end
end
