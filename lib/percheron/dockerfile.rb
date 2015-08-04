module Percheron
  class Dockerfile

    extend Forwardable

    def_delegators :file_name, :dirname, :basename

    attr_reader :file_name

    def initialize(file_name)
      @file_name = Pathname.new(file_name)
    end

    def exists?
      file_name.exist?
    end

    def md5s_match?
      md5sum == stored_md5sum
    end

    private

      def md5sum
        exists? ? Digest::MD5.file(file_name).hexdigest : nil
      end

      def stored_md5sum
        $metastore.get(metastore_key) || md5sum
      end
  end
end
