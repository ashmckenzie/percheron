require 'fileutils'

module Percheron
  class Metadata

    def get(key)
      key.split('/').inject(contents, :[])
    end

    def set(key, value)
      current_contents = contents
      set_key_and_value(current_contents, key.split('/'), value)
      save!(current_contents)
    end

    private

      def set_key_and_value(hash, key, value)
        current_key = key.shift
        hash[current_key] = {} unless hash[current_key]

        if key.empty?
          hash[current_key] = value
          hash
        else
          set_key_and_value(hash[current_key], key, value)
        end
      end

      def contents
        c = file.exist? ? YAML.load_file(file.to_s) : {}
        Hashie::Mash.new(c)
      end

      def file
        @file ||= Pathname.new(File.join(ENV['HOME'], '.percheron', 'metadata.yml'))
      end

      def save!(new_contents)
        FileUtils.mkdir_p(file.dirname)
        File.open(file.to_s, 'w') { |f| f.write(new_contents.to_yaml) }
      end

  end
end
