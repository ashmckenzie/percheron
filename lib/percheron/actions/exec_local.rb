require 'open3'

module Percheron
  module Actions
    class ExecLocal
      include Base

      def initialize(unit, scripts, description)
        @unit = unit
        @scripts = scripts
        @description = description
      end

      def execute!
        results = []
        results << execute_scripts!
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :scripts, :description

        def execute_scripts!
          $logger.debug "Executing #{description} scripts '#{scripts.inspect}' locally"
          scripts.each do |script|
            in_working_directory(base_dir) do
              execute_command!('%s 2>&1' % [ Pathname.new(File.expand_path(script)) ])
            end
          end
        end

        def execute_command!(command)
          $logger.info "Executing #{description} script '#{command}' locally"
          Open3.popen2e(command) do |_, stdout_stderr, _|
            while (line = stdout_stderr.gets)
              $logger.debug line.strip
            end
          end
        end

    end
  end
end
