module Percheron
  module Actions
    class Build

      include Base

      def initialize(unit, nocache: false, exec_scripts: true)
        @unit = unit
        @nocache = nocache
        @exec_scripts = exec_scripts
      end

      def execute!
        results = []
        results << build! if unit.buildable?
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :nocache, :exec_scripts
        alias_method :exec_scripts?, :exec_scripts

        def options
          {
            'dockerfile'  => unit.dockerfile.basename.to_s,
            't'           => unit.image_name,
            'forcerm'     => true,
            'nocache'     => nocache
          }
        end

        def build!
          in_working_directory(base_dir) do
            execute_pre_build_scripts!
            $logger.info "Building '#{unit.image_name}' image"
            Connection.perform(Docker::Image, :build_from_dir, base_dir, options) do |out|
              $logger.debug '%s' % [ out.strip ]
            end
          end
        end

        def execute_pre_build_scripts!
          return nil if !exec_scripts? && unit.pre_build_scripts.empty?
          ExecLocal.new(unit, unit.pre_build_scripts, 'PRE build').execute!
        end
    end
  end
end
