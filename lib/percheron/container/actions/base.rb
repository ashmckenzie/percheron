module Percheron
  module Container
    module Actions
      module Base

        private

          def base_dir
            container.dockerfile.dirname.to_s
          end

          def in_working_directory(new_dir)
            old_dir = Dir.pwd
            Dir.chdir(new_dir)
            yield
            Dir.chdir(old_dir)
          end
      end
    end
  end
end
