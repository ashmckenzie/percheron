module Percheron
  module Errors
    class ConfigFileInvalid < StandardError; end
    class StackInvalid < StandardError; end
    class UnitInvalid < StandardError; end
    class UnitDoesNotExist < StandardError; end
    class DockerHostNotDefined < StandardError; end
    class DockerClientInvalid < StandardError; end
    class DockerContainerCannotDelete < StandardError; end
  end
end
