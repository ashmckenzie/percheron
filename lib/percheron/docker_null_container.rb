module Percheron
  DockerNullContainer = Naught.build do |config|
    config.mimic Container

    def info
      {}
    end
  end
end
