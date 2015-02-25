module Percheron
  module Errors
    class ConfigFileInvalid < StandardError; end
    class StackInvalid < StandardError; end
    class ContainerConfigInvalid < StandardError; end
  end
end
