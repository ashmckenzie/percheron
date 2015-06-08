module Percheron
  module Errors
    class ConfigFileInvalid < StandardError; end
    class StackInvalid < StandardError; end
    class UnitInvalid < StandardError; end
    class UnitDoesNotExist < StandardError; end
    class DockerClientInvalid < StandardError; end
    class MultipleStacksAndUnitsDefined < StandardError; end
  end
end
