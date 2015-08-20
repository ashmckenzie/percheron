module Percheron
  module Commands
    class Purge < Abstract

      default_parameters!
      option('--yes', :flag, 'Yes, purge image / unit', default: false)
      option('--force', :flag, 'Force image / unit removal', default: false)

      def execute
        super
        runit { stack.purge!(unit_names: unit_names, force: force?) if yes? || confirm? }
      end

      private

        def confirm?
          ask('Are you sure you want to purge? (y|n) ') do |q|
            q.validate = /y(es)?|n(o)?/i
          end.match(/y(es)?/i)
        end
    end
  end
end
