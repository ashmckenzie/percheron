module Percheron
  module Formatters
    module Stack
      class Table

        def initialize(stack)
          @stack = stack
        end

        def generate
          Terminal::Table.new(title: title, headings: headings, rows: rows)
        end

        private

          attr_reader :stack

          def title
            stack.name
          end

          def headings
            [
              'Container',
              'ID',
              'Running?',
              'Ports',
              'Volumes',
              'Version'
            ]
          end

          def rows
            stack.containers.map do |_, container|
              [
                container.name,
                container.id,
                startable(container),
                container.ports.join(', '),
                container.volumes.join(', '),
                (container.built_version == '0.0.0') ? '' : container.built_version
              ]
            end
          end

          def startable(container)
            if container.startable?
              container.running? ? 'yes' : '-'
            else
              'n/a'
            end
          end
      end
    end
  end
end
