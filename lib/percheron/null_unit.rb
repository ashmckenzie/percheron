module Percheron
  NullUnit = Naught.build do |config|
    config.mimic Unit

    def info
      {}
    end

    def kind_of?(klass)
      self.class == klass
    end
  end
end
