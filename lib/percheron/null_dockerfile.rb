module Percheron
  NullDockerfile = Naught.build do |config|
    config.mimic Dockerfile
  end
end
