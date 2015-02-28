module Percheron
  module Container
    module Actions
      class Build

        def initialize(container, nocache: false)
          @container = container
          @nocache = nocache
        end

        def execute!
          base_dir = container.dockerfile.dirname.to_s
          $logger.debug "Building '#{container.image}'"
          Docker::Image.build_from_dir(base_dir, build_opts) do |out|
            $logger.debug '%s' % [ out.strip ]
          end
        end

        private

          attr_reader :container, :nocache

          def build_opts
            {
              'dockerfile'  => container.dockerfile.basename.to_s,
              't'           => container.image,
              'forcerm'     => true,
              'nocache'     => nocache
            }
          end

      end
    end
  end
end
