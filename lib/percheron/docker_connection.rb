module Percheron
  class DockerConnection

    def initialize(config)
      @config = config
    end

    def setup!
      Docker.logger = $logger if ENV['DOCKER_DEBUG'] == 'true'
      Docker.url = config.docker.host

      opts = {
        chunk_size:       1,
        connect_timeout:  config.docker.timeout,
        scheme:          'https'
      }

      if cert_path
        opts.merge!({
          client_cert:  File.join(cert_path, 'cert.pem'),
          client_key:   File.join(cert_path, 'key.pem'),
          ssl_ca_file:  File.join(cert_path, 'ca.pem')
        })
      end

      Docker.options = opts
    end

    private

      attr_reader :config

      def cert_path
        @cert_path ||= begin
          if ENV['DOCKER_CERT_PATH']
            File.expand_path(ENV['DOCKER_CERT_PATH'])
          else
            nil
          end
        end
      end
  end
end
