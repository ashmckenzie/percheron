module Percheron
  module Actions
    class Build

      include Base

      def initialize(container, nocache: false, exec_scripts: true)
        @container = container
        @nocache = nocache
        @exec_scripts = exec_scripts
      end

      def execute!
        results = []
        results << build! if container.buildable?
        results.compact.empty? ? nil : container
      end

      private

        attr_reader :container, :nocache, :exec_scripts
        alias_method :exec_scripts?, :exec_scripts

        def options
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
            $logger.info "Building '#{container.image_name}' image"
            Docker::Image.build_from_dir(base_dir, options) { |out| $logger.debug '%s' % [ out.strip ] }
          end
        end

        def execute_pre_build_scripts!
          ExecLocal.new(container, container.pre_build_scripts, 'PRE build').execute! if exec_scripts? && !container.pre_build_scripts.empty?
        end

    end
  end
end
