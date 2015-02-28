module Percheron
  module Errors
    class ConfigFileInvalid < StandardError; end
    class StackInvalid < StandardError; end
    class ContainerInvalid < StandardError; end
    class ContainerDoesNotExist < StandardError; end
    class ContainerNotRunning < StandardError; end
  end
end
