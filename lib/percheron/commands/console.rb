module Percheron
  module Commands
    class Console < Abstract

      parameter('STACK_NAME', 'stack name', required: true)

      def execute
        super
        require 'pry-byebug'
        pry
      end

      private

        def logs(unit_name, follow: false)
          stack.logs!(unit_name, follow: follow)
          nil
        end

        def shell(unit_name)
          stack.shell!(unit_name)
          nil
        end

        def purge(unit_names)
          stack.purge!(unit_names: [ *unit_names ])
          nil
        end

        def create(unit_names, start: false)
          stack.create!(unit_names: [ *unit_names ], start: start)
          nil
        end

        def recreate(unit_names, start: false)
          stack.create!(unit_names: [ *unit_names ], start: start)
          nil
        end

        def start(unit_names)
          stack.start!(unit_names: [ *unit_names ])
          nil
        end

        def stop(unit_names)
          stack.stop!(unit_names: [ *unit_names ])
          nil
        end

        def restart(unit_names)
          stack.restart!(unit_names: [ *unit_names ])
          nil
        end
    end
  end
end
