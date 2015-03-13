module Percheron
  module Actions
    module Base

      def base_dir
        container.dockerfile.dirname.to_s
      end

      def in_working_directory(new_dir)
        old_dir = Dir.pwd
        Dir.chdir(new_dir)
        yield
      ensure
        Dir.chdir(old_dir)
      end

      def now_timestamp
        Time.now.strftime('%Y%m%d%H%M%S')
      end

      def insert_files!(files)
        files.each do |file|
          file = Pathname.new(File.expand_path(file, base_dir))
          container.image.insert_local('localPath' => file.to_s, 'outputPath' => "/tmp/#{file.basename}").tap do |new_image|
            new_image.tag(repo: container.name, tag: container.version.to_s, force: true)
          end
        end
      end

      def stop_containers!(containers)
        exec_on_containers!(containers) do |container|
          Stop.new(container).execute! if container.running?
        end
      end

      def start_containers!(containers)
        exec_on_containers!(containers) do |container|
          Start.new(container, container.dependant_containers.values).execute! unless container.running?
        end
      end

      def exec_on_containers!(containers)
        containers.inject([]) do |all, container|
          all << container if yield(container)
          all
        end.compact
      end
    end
  end
end
