require 'open3'

module Percheron
  module Actions
    class ExecLocal

      include Base

      def initialize(container, scripts, description)
        @container = container
        @scripts = scripts
        @description = description
      end

      def execute!
        $logger.debug "Executing #{description} scripts '#{scripts.inspect}' locally"
        execute_scripts!
      end

      private

        attr_reader :container, :scripts, :description

        def execute_scripts!
          scripts.each do |script|
            in_working_directory(base_dir) do
              execute_command!('/bin/bash -x %s 2>&1' % Pathname.new(File.expand_path(script)))
            end
          end
        end

        def execute_command!(command)
          $logger.info "Executing #{description} '#{command}' locally"
          Open3.popen2e(command) do |stdin, stdout_stderr, wait_thr|
            while line = stdout_stderr.gets
              $logger.debug line.strip
            end
          end
        end

    end
  end
end
