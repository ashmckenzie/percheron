module Percheron
  module Container
    module Actions
      class Create

        include Base

        def initialize(container)
          @container = container
        end

        def execute!
          build!
          insert_post_start_scripts!
          create!
        end

        private

          attr_reader :container

          def create_opts
            {
              'name'          => container.name,
              'Image'         => container.image_name,
              'Hostname'      => container.name,
              'Env'           => container.env,
              'ExposedPorts'  => container.exposed_ports,
              'VolumesFrom'   => container.volumes
            }
          end

          def build!
            unless container.image
              $logger.debug "Creating '#{container.image_name}' image"
              Container::Actions::Build.new(container).execute!
            end
          end

          def create!
            $logger.debug "Creating '#{container.name}' container"
            Docker::Container.create(create_opts)
          end

          def insert_post_start_scripts!
            container.post_start_scripts.each do |script|
              file = Pathname.new(File.expand_path(script, base_dir))
              new_image = container.image.insert_local('localPath' => file.to_s, 'outputPath' => "/tmp/#{file.basename}")
              new_image.tag(repo: container.name, tag: container.version.to_s, force: true)
            end
          end

      end
    end
  end
end
