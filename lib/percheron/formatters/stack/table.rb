module Percheron
  module Formatters
    module Stack
      class Table

        def initialize(stack)
          @stack = stack
        end

        def generate
          Terminal::Table.new(
            title:    stack.name,
            headings: headings,
            rows:     rows
          )
        end

        private

          attr_reader :stack

          def headings
            [
              'Container name',
              'ID',
              'Version',
              'Running?'
            ]
          end

          def rows
            stack.filter_containers.map do |container_name, container|
              [
                container_name,
                container.id,
                container.built_version,
                container.running?
              ]
            end
          end
      end
    end
  end
end
