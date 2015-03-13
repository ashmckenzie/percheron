module Percheron
  module Validators
    class Container

      def initialize(container)
        @container = container
      end

      def valid?
        message = rules.return { |rule| send(rule) }

        if message
          raise Errors::ContainerInvalid.new(formatted_message(message))
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
            "Container config is invalid: %s" % [ message ]
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
          'Name is invalid' if container.name.nil? || !container.name.to_s.match(/[\w\d]{3,}/)
        end

        def validate_version
          container.version
          nil
        rescue ArgumentError
          'Version is invalid'
        end

        def validate_dockerfile
          'Dockerfile is invalid' if container.dockerfile.nil? || !File.exist?(container.dockerfile)
        end
    end
  end
end
