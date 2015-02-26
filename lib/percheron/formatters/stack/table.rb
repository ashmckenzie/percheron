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
            stack.container_configs.map do |container_name, container_config|
              [
                container_name,
                container_config.id,
                container_config.version,
                container_config.running?
              ]
            end
          end
      end
    end
  end
end
