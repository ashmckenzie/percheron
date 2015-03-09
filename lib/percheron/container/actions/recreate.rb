module Percheron
  module Container
    module Actions
      class Recreate

        include Base

        def initialize(container)
          @container = container
        end

        def execute!
          unless temporary_container_exists?
            create_image!
            create_container!
            rename!
          else
            $logger.warn "Not recreating '#{container.name}' container as '#{temporary_name}' because '#{temporary_name}' already exists"
          end
        end

        private

          attr_reader :container

          def create_opts
            {
              'name'          => temporary_name,
              'Image'         => container.image_name,
              'Hostname'      => container.name,
              'Env'           => container.env,
              'ExposedPorts'  => container.exposed_ports,
              'VolumesFrom'   => container.volumes
            }
          end

          def temporary_name
            '%s_wip' % container.name
          end

          # FIXME: brittle
          def temporary_container_exists?
            temporary_container.info.empty?
          rescue Docker::Error::NotFoundError
            false
          end

          def create_image!
            unless container.image
              $logger.debug "Creating '#{container.image_name}' image"
              Container::Actions::Build.new(container).execute!
            end
          end

          def create_container!
            $logger.debug "Recreating '#{container.name}' container as '#{temporary_name}'"
            Docker::Container.create(create_opts)
          end

          def rename!
            save_current_running_state!
            stop_current! if container.running?
            rename_current_to_old!
            rename_wip_to_current!
            start_new! if container_was_running?
          end

          def rename_current_new_name
            '%s_%s' % [ container.name, now_timestamp ]
          end

          def now_timestamp
            Time.now.strftime('%Y%m%d%H%M%S')
          end

          def temporary_container
            Docker::Container.get(temporary_name)
          end

          def save_current_running_state!
            @container_was_running = container.running?
          end

          def stop_current!
            Container::Actions::Stop.new(container).execute!
          end

          def rename_current_to_old!
            $logger.debug "Renaming '#{container.name}' container to '#{rename_current_new_name}'"
            container.docker_container.rename(rename_current_new_name)
          end

          def rename_wip_to_current!
            # FIXME: brittle
            $logger.debug "Renaming '#{temporary_name}' container to '#{container.name}'"
            Docker::Container.get(temporary_name).rename(container.name)
          end

          def start_new!
            container.start!
          end

          def container_was_running?
            @container_was_running
          end

      end
    end
  end
end
