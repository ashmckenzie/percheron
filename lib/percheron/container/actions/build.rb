require 'open3'

module Percheron
  module Container
    module Actions
      class Build

        def initialize(container, nocache: false)
          @container = container
          @nocache = nocache
        end

        def execute!
          in_working_directory(base_dir) do
            execute_pre_build_scripts!
            $logger.debug "Building '#{container.image}'"
            Docker::Image.build_from_dir(base_dir, build_opts) do |out|
              $logger.debug '%s' % [ out.strip ]
            end
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

          def base_dir
            container.dockerfile.dirname.to_s
          end

          def in_working_directory(new_dir)
            old_dir = Dir.pwd
            Dir.chdir(new_dir)
            yield
            Dir.chdir(old_dir)
          end

          def execute_pre_build_scripts!
            container.pre_build_scripts.each do |script|
              in_working_directory(base_dir) do
                command = '/bin/bash -x %s 2>&1' % Pathname.new(File.expand_path(script))
                $logger.debug "Executing '#{command}' for '#{container.name}' container"
                Open3.popen2e(command) do |stdin, stdout_err, wait_thr|
                  while line = stdout_err.gets
                    $logger.debug line.strip
                  end
                end
              end
            end
          end

      end
    end
  end
end
