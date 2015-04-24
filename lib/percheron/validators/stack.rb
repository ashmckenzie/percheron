module Percheron
  module Validators
    class Stack

      def initialize(stack)
        @stack = stack
      end

      def valid?
        message = rules.return { |rule| send(rule) }
        message ? fail(Errors::StackInvalid, formatted_message(message)) : true
      end

      private

        attr_reader :stack

        def formatted_message(message)
          "Stack is invalid: #{message}"
        end

        def rules
          [ :validate_name ]
        end

        def validate_name
          return nil if !stack.name.nil? && stack.name.to_s.match(/\w{3,}/)
          'Name is invalid'
        end

    end
  end
end
