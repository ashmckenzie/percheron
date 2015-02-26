module Percheron
  class Stack

    extend Forwardable

    def_delegators :stack_config, :name, :description

    def initialize(config, stack_config)
      @config = config
      @stack_config = stack_config
      valid?
    end

    def self.all(config)
      config.settings.stacks.inject({}) do |all, stack_config|
        stack = new(config, stack_config)
        all[stack.name] = stack unless all[stack.name]
        all
      end
    end

    def valid?
      Validators::Stack.new(self).valid?
    end

    def container_configs
      stack_config.container_configs.inject({}) do |all, container_config|
        container_config = ContainerConfig.new(config, container_config)
        all[container_config.name] = container_config unless all[container_config.name]
        all
      end
    end

    private

      attr_reader :config, :stack_config
  end
end
