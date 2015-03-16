module Percheron
  module Actions
    class Recreate

      include Base

      def initialize(container, force_recreate: false, delete: false)
        @container = container
        @force_recreate = force_recreate
        @delete = delete
      end

      def execute!
        results = []
        if recreate?
          results << recreate!
        else
          inform!
        end
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :force_recreate, :delete

        alias_method :force_recreate?, :force_recreate
        alias_method :delete?, :delete

        def temporary_name
          '%s_wip' % container.name
        end

        def stored_dockerfile_md5
          container.dockerfile_md5 || container.current_dockerfile_md5
        end

        def temporary_container_exists?
          Docker::Container.get(temporary_name).nil? ? false : true
        rescue Docker::Error::NotFoundError
          false
        end

        def recreate?
          force_recreate? || (!dockerfile_md5s_match? && versions_mismatch? && container.auto_recreate?)
        end

        def versions_mismatch?
          container.version > container.built_version
        end

        def dockerfile_md5s_match?
          stored_dockerfile_md5 == container.current_dockerfile_md5
        end

        def inform!
          if dockerfile_md5s_match?
            $logger.info "Container '#{container.name}' does not need to be recreated"
          else
            $logger.warn "Container '#{container.name}' MD5's do not match, consider recreating (bump the version!)"
          end
        end

        def recreate!
          $logger.debug "Container '#{container.name}' exists and will be recreated"

          if temporary_container_exists?
            $logger.debug "Not recreating '#{container.name}' container because temporary container '#{temporary_name}' already exists"
          else
            delete_container_and_image! if delete? && container.exists?
            create_container!
            rename_container!
          end
        end

        def delete_container_and_image!
          delete_container!
          delete_image!
        end

        def delete_container!
          $logger.info "Deleting '#{container.name}' container"
          stop_containers!([ container ])
          container.docker_container.remove
        end

        def delete_image!
          $logger.info "Deleting '#{container.image_name}' image"
          container.image.remove
        end

        def create_container!
          opts = { create: { 'name' => temporary_name } }
          Create.new(container, recreate: true).execute!(opts)
        end

        def rename_container!
          Rename.new(container, temporary_name, container.name).execute!
        end

    end
  end
end
