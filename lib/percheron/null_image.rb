module Percheron
  NullImage = Naught.build do
    def kind_of?(klass)
      self.class == klass
    end
  end
end