module Percheron
  module Commands
    class Console < Abstract

      parameter('STACK_NAME', 'stack name', required: false)

      def execute
        super
        require 'pry-byebug'
        pry
      end

      private

        def list
          Stack.get(config, stack_name).each do |_, stack|
            puts("\n", Percheron::Formatters::Stack::Table.new(stack).generate)
          end
          nil
        end

        def logs(container_name, follow: false)
          stack.logs!(container_name, follow: follow)
          nil
        end

        def shell(container_name)
          stack.shell!(container_name)
          nil
        end

        def purge(container_names)
          stack.purge!(container_names: [ *container_names ])
          nil
        end

        def create(container_names, start: false)
          stack.create!(container_names: [ *container_names ], start: start)
          nil
        end

        def recreate(container_names, start: false)
          stack.create!(container_names: [ *container_names ], start: start)
          nil
        end

        def start(container_names)
          stack.start!(container_names: [ *container_names ])
          nil
        end

        def stop(container_names)
          stack.stop!(container_names: [ *container_names ])
          nil
        end

        def restart(container_names)
          stack.restart!(container_names: [ *container_names ])
          nil
        end
    end
  end
end
