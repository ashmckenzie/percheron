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
        files.each { |file| insert_file!(file) }
      end

      def insert_file!(file)
        file = Pathname.new(File.expand_path(file, base_dir))
        new_image = container.image.insert_local('localPath' => file.to_s, 'outputPath' => "/tmp/#{file.basename}")
        new_image.tag(repo: container.name, tag: container.version.to_s, force: true)
      end

      def stop_containers!(containers)
        exec_on_containers!(containers) do |container|
          if container.running?
            $logger.debug "Stopping '#{container.name}' container"
            Stop.new(container).execute!
          end
        end
      end

      def start_containers!(containers, exec_scripts: true)
        exec_on_containers!(containers) do |container|
          unless container.running?
            $logger.debug "Starting '#{container.name}' container"
            Start.new(container, dependant_containers: container.dependant_containers.values, exec_scripts: exec_scripts).execute!
          end
        end
      end

      def exec_on_containers!(containers)
        containers.each_with_object([]) do |container, all|
          all << container if yield(container)
        end.compact
      end
    end
  end
end
