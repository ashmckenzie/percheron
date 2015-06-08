module Percheron
  module Validators
    class DockerClient

      def valid?
        message = rules.return { |rule| send(rule) }
        message ? fail(Errors::DockerClientInvalid, formatted_message(message)) : true
      end

      private

        def formatted_message(message)
          "Docker client is invalid: #{message}"
        end

        def rules
          [
            :validate_existence,
            :validate_version
          ]
        end

        def validate_existence
          return nil if docker_client_exists?
          'Is not in your PATH'
        end

        def validate_version
          return nil if docker_client_exists? &&
                        Semantic::Version.new(current_version) >= minimum_version
          "Version is insufficient, need #{minimum_version}"
        end

        def paths
          ENV['PATH'].split(File::PATH_SEPARATOR)
        end

        def docker_client_exists?
          paths.each do |path|
            exe = File.join(path, Actions::Run::DOCKER_CLIENT)
            return true if File.executable?(exe) && !File.directory?(exe)
          end
          false
        end

        def minimum_version
          @minimum_version ||= Semantic::Version.new('1.6.0')
        end

        def current_version
          `#{Actions::Run::DOCKER_CLIENT} --version`.chomp.match(/version (.+),/)[1]
        end

    end
  end
end
