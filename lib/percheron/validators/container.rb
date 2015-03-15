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
            :validate_version,
            :validate_dockerfile
          ]
        end

        def validate_name
          'Container name is invalid' if container.name.nil? || !container.name.to_s.match(/[\w\d]{3,}/)
        end

        def validate_version
          container.version
          nil
        rescue ArgumentError
          'Container version is invalid'
        end

        def validate_dockerfile
          'Container Dockerfile is invalid' if container.dockerfile.nil? || !File.exist?(container.dockerfile)
        end
    end
  end
end
