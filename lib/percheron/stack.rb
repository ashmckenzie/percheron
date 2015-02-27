module Percheron
  class Stack

    extend Forwardable

    def_delegators :stack_config, :name, :description

    def initialize(config, stack_name)
      @config = config
      @stack_name = stack_name
      valid?
    end

    def self.all(config)
      all = {}
      config.stacks.each do |stack_name, _|
        stack = new(config, stack_name)
        all[stack.name] = stack
      end
      all
    end

    def container_configs
      stack_config.containers.inject({}) do |all, container|
        all[container.name] = container unless all[container.name]
        all
      end
    end

    def containers
      containers = {}
      stack_config.containers.each do |container|
        container = Container.new(config, self, container.name)
        containers[container.name] = container
      end
      containers
    end

    def start!
      exec_on_containers { |container| container.start! }
      end
    end

    def valid?
      Validators::Stack.new(self).valid?
    end

    private

      attr_reader :config, :stack_name

      def stack_config
        @stack_config ||= config.stacks[stack_name] || Hashie::Mash.new({})
      end

      def exec_on_containers
        containers.each do |container_name, container|
          yield(container)
        end
      end
  end
end
