module Docker
  NullContainer = Naught.build do |config|
    config.mimic Container
  end
end
