module Percheron
  class Dockerfile

    extend Forwardable

    def_delegators :file_name, :dirname, :basename, :expand_path, :read

    attr_reader :file_name

    def initialize(file_name, metastore_key)
      # require 'pry-byebug' ; binding.pry
      @file_name = Pathname.new(file_name).expand_path
      @metastore_key = metastore_key
    end

    def exists?
      file_name.exist?
    end

    def md5s_match?
      md5sum == stored_md5sum
    end

    def md5sum
      exists? ? Digest::MD5.file(file_name).hexdigest : nil
    end

    private

      attr_reader :metastore_key

      def stored_md5sum
        $metastore.get(metastore_key) || md5sum
      end
  end
end
