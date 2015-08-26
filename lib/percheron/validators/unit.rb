module Percheron
  module Validators
    class Unit

      def initialize(unit)
        @unit = unit
      end

      def valid?
        message = rules.return { |rule| send(rule) }
        message ? fail(Errors::UnitInvalid, formatted_message(message)) : true
      end

      private

        attr_reader :unit

        def formatted_message(message)
          if unit.name
            "Unit config for '%s' is invalid: %s" % [ unit.name, message ]
          else
            "Unit config is invalid: #{message}"
          end
        end

        def rules
          [
            :validate_name,
            :validate_dockerfile_and_image_name,
            :validate_dockerfile,
            :validate_docker_image_and_start_args,
            :validate_image,
            :validate_version
          ]
        end

        # rubocop:disable Style/GuardClause
        def validate_name
          if unit.name.nil? || !unit.name.to_s.match(/[\w]{3,}/)
            'Name is invalid'
          end
        end

        def validate_dockerfile_and_image_name
          if unit.dockerfile.nil? && unit.docker_image.nil?
            'Dockerfile OR image name not provided'
          end
        end

        def validate_dockerfile
          if !unit.dockerfile.nil? && !File.exist?(unit.dockerfile)
            'Dockerfile is invalid'
          end
        end

        def validate_docker_image_and_start_args
          # raise('FIXME')
        end

        def validate_image
          if !unit.docker_image.nil? && !unit.docker_image.match(/^.+:.+$/)
            'Docker image is invalid'
          end
        end
        # rubocop:enable Style/GuardClause

        def validate_version
          unit.version ? nil : fail(ArgumentError)
        rescue ArgumentError
          'Version is invalid'
        end

    end
  end
end
