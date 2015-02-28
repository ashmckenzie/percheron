module Percheron
  module Container
    Null = Naught.build do |config|
      config.mimic Container

      def info
        {}
      end

      def kind_of?(klass)
        self.class == klass
      end
    end
  end
end
