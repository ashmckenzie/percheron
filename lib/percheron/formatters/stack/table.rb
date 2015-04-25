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
              'IP',
              'Ports',
              'Volumes',
              'Version'
            ]
          end

          # rubocop:disable Metrics/MethodLength
          def rows
            stack.containers.map do |_, container|
              [
                container.name,
                container.id,
                startable(container),
                container.ip,
                container.ports.join(', '),
                container.volumes.join(', '),
                (container.built_version == '0.0.0') ? '' : container.built_version
              ]
            end
          end
          # rubocop:enable Metrics/MethodLength

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
