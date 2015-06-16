module Percheron
  NullImage = Naught.build do |config|
    def kind_of?(klass)
      self.class == klass
    end
  end
end
