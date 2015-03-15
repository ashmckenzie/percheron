module Percheron
  module Validators
    class Stack

      def initialize(stack)
        @stack = stack
      end

      def valid?
        message = rules.return { |rule| send(rule) }

        if message
          fail Errors::StackInvalid, message
        else
          true
        end
      end

      private

        attr_reader :stack

        def rules
          [ :validate_name ]
        end

        def validate_name
          'Stack name is invalid' if stack.name.nil? || !stack.name.to_s.match(/[\w\d]{3,}/)
        end

    end
  end
end
