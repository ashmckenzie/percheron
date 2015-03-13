module Percheron
  module Actions
    class Build

      include Base

      def initialize(container, nocache: false)
        @container = container
        @nocache = nocache
      end

      def execute!
        build!
        container
      end

      private

        attr_reader :container, :nocache

        def build_opts
          {
            'dockerfile'  => container.dockerfile.basename.to_s,
            't'           => container.image_name,
            'forcerm'     => true,
            'nocache'     => nocache
          }
        end

        def build!
          in_working_directory(base_dir) do
            execute_pre_build_scripts!

            $logger.info "Building '#{container.image_name}'"
            Docker::Image.build_from_dir(base_dir, build_opts) do |out|
              $logger.debug '%s' % [ out.strip ]
            end
          end
        end

        def execute_pre_build_scripts!
          ExecLocal.new(container, container.pre_build_scripts, 'PRE build').execute!
        end

    end
  end
end
