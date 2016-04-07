require 'highline/import'

module Percheron
  class Stacks
    def initialize(config, stack_names)
      @config = config
      @stack_names = stack_names
      self
    end

    def valid?
      true
    end

    def stop!(unit_names: [])
      stacks.values.reverse.map(&:stop!)
    end

    def start!(unit_names: [])
      stacks.values.map(&:start!)
    end

    private

      attr_reader :config, :stack_names

      def stacks
        @stacks ||= Stack.get(config, stack_names)
      end
  end
end
