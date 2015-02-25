module Percheron
  module Validators
    class Stack

      def initialize(stack)
        @stack = stack
      end

      def valid?
        messages = []
        messages << validate_name
        messages.compact!

        unless messages.empty?
          raise Errors::StackInvalid.new(messages)
        else
          true
        end
      end

      private

        attr_reader :stack

        def validate_name
          'Name is invalid' if stack.name.nil? || !stack.name.match(/[\w\d]{3,}/)
        end

    end
  end
end
