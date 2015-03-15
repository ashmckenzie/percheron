module Percheron
  module Actions
    class Rename

      include Base

      def initialize(container, temporary_name, new_name)
        @container = container
        @temporary_name = temporary_name
        @new_name = new_name
      end

      def execute!
        results = []
        results << rename!
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :temporary_name, :new_name

        def rename_current_new_name
          @rename_current_new_name ||= '%s_%s' % [ container.name, now_timestamp ]
        end

        def old_container
          Docker::Container.get(rename_current_new_name)
        end

        def temporary_container
          Docker::Container.get(temporary_name)
        end

        def rename!
          container_running = container.running?
          stop_containers!([ container ])   if container_running
          rename_containers!
          start_containers!([ container ])  if container_running
          remove_old!
        end

        def rename_containers!
          rename_container_current_to_old! if container.exists?
          rename_container_temporary_to_new!
        end

        def rename_container_current_to_old!
          $logger.info "Renaming '#{container.name}' container to '#{rename_current_new_name}'"
          container.docker_container.rename(rename_current_new_name)
        end

        def rename_container_temporary_to_new!
          $logger.info "Renaming '#{temporary_name}' container to '#{new_name}'"
          temporary_container.rename(new_name)
        end

        def remove_old!
          $logger.info "Removing '#{rename_current_new_name}' container"
          old_container.remove
        end

    end
  end
end
