module Percheron
  module Commands
    class Init < Abstract

      DEFAULT_FILE_NAME = '.percheron.yml'

      def execute
        if File.exist?(DEFAULT_FILE_NAME)
          $logger.error 'A %s already exists!' % [ DEFAULT_FILE_NAME ]
        else
          File.open(DEFAULT_FILE_NAME, 'w') { |f| f.write(content.to_yaml.to_s) }
        end
      end

      private

        def content
          {
            'stacks' => [
              'name' => 'starter',
              'units' => [ 'name' => 'alpine', 'version' => '1.0.0',
                           'docker_image' => 'alpine:latest', 'start_args' => %w(watch uptime) ]
            ]
          }
        end
    end
  end
end
