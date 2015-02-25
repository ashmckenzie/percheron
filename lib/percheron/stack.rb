module Percheron
  class Stack

    extend Forwardable

    def_delegators :stack_config, :name

    def initialize(stack_config)
      @stack_config = stack_config
      valid?
    end

    def valid?
      Validators::Stack.new(self).valid?
    end

    private

      attr_reader :stack_config
  end
end
