module Percheron
  class DockerConnection

    def initialize(config)
      @config = config
    end

    def setup!
      Docker.logger = $logger if ENV['DOCKER_DEBUG'] == 'true'
      Docker.url = config.docker.host

      Docker.options = {
        chunk_size:       1,
        connect_timeout:  config.docker.timeout,
        client_cert:      File.join(cert_path, 'cert.pem'),
        client_key:       File.join(cert_path, 'key.pem'),
        ssl_ca_file:      File.join(cert_path, 'ca.pem'),
        scheme:          'https'
      }
    end

    private

      attr_reader :config

      def cert_path
        @cert_path ||= File.expand_path(ENV['DOCKER_CERT_PATH'])
      end
  end
end
