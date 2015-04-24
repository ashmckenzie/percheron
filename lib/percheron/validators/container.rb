module Percheron
  module Validators
    class Container

      def initialize(container)
        @container = container
      end

      def valid?
        message = rules.return { |rule| send(rule) }
        message ? fail(Errors::ContainerInvalid, formatted_message(message)) : true
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

        # rubocop:disable Style/GuardClause
        def validate_name
          if container.name.nil? || !container.name.to_s.match(/[\w]{3,}/)
            'Name is invalid'
          end
        end

        def validate_dockerfile_and_image_name
          if container.dockerfile.nil? && container.docker_image.nil?
            'Dockerfile OR image name not provided'
          end
        end

        def validate_dockerfile
          if !container.dockerfile.nil? && !File.exist?(container.dockerfile)
            'Dockerfile is invalid'
          end
        end

        def validate_image
          if !container.docker_image.nil? && !container.docker_image.match(/^.+:.+$/)
            'Docker image is invalid'
          end
        end
        # rubocop:enable Style/GuardClause

        def validate_version
          container.version ? nil : fail(ArgumentError)
        rescue ArgumentError
          'Version is invalid'
        end

    end
  end
end
