module Percheron
  class Image

    extend Forwardable

    def_delegators :image, :insert_local, :remove

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def id
      image.id ? image.id[0...12] : nil
    end

    def exists?
      id.nil? ? false : true
    end

    private

      def image
        @image ||= begin
          begin
            Connection.perform(Docker::Image, :get, name)
          rescue Percheron::Errors::ConnectionException
            NullImage.new
          end
        end
      end

  end
end
