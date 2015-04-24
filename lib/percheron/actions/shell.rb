module Percheron
  module Actions
    class Shell
      include Base

      DEFAULT_SHELL = '/bin/sh'
      DOCKER_CLIENT = 'docker'
      DOCKER_CLIENT_MINIMUM_VERSION = Semantic::Version.new('1.6.0')

      def initialize(container, shell: DEFAULT_SHELL)
        @container = container
        @shell = shell
      end

      def execute!
        validate_docker_client_available!
        $logger.debug "Executing #{shell} on '#{container.name}' container"
        exec!
      end

      private

        attr_reader :container, :shell

        def validate_docker_client_available!
          unless docker_client_exists?
            fail Errors::DockerClientNotInstalled, 'Docker client not installed'
          end

          fail Errors::DockerClientInsufficientVersion, "Docker client version insufficient, need \
#{DOCKER_CLIENT_MINIMUM_VERSION}" unless docker_client_version_valid?
        end

        def docker_client_exists?
          ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
            exe = File.join(path, DOCKER_CLIENT)
            return true if File.executable?(exe) && !File.directory?(exe)
          end
          false
        end

        def docker_client_version_valid?
          version = `#{DOCKER_CLIENT} --version`.chomp.match(/version (?<version>.+),/)[:version]
          Semantic::Version.new(version) >= DOCKER_CLIENT_MINIMUM_VERSION
        end

        def exec!
          system('%s exec -ti %s %s' % [ DOCKER_CLIENT, container.full_name, shell ])
        end
    end
  end
end
