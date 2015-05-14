module Percheron
  module Actions
    module Base
      def base_dir
        unit.dockerfile.dirname.to_s
      end

      def in_working_directory(new_dir)
        old_dir = Dir.pwd
        Dir.chdir(new_dir)
        yield
      ensure
        Dir.chdir(old_dir)
      end
    end
  end
end
