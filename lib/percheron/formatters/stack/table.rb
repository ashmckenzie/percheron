require 'thread'

module Percheron
  module Formatters
    module Stack
      class Table

        def initialize(stack)
          @stack = stack
          @queue = Queue.new
        end

        def generate
          Terminal::Table.new(title: title, headings: headings, rows: rows)
        end

        private

          attr_reader :stack, :queue

          def title
            stack.name
          end

          def rows
            queue_jobs
            process_queue!
          end

          def queue_jobs
            stack.units.map { |_, unit| queue << row_for(unit) }
          end

          def process_queue!
            resp = []
            4.times.map do
              Thread.new { queue.size.times { resp << queue.pop(true) } }
            end.map(&:join)
            resp
          end

          # rubocop:disable Metrics/MethodLength
          def headings
            [
              'Unit',
              'Container ID',
              'Image ID',
              'Up?',
              'IP',
              'Ports',
              'Volumes',
              'Volumes from',
              'Version'
            ]
          end

          def row_for(unit)
            [
              unit.name,
              unit.id,
              unit.image.id,
              startable(unit),
              unit.ip,
              ports(unit),
              unit.volumes.join("\n"),
              unit.volumes_from.join(', '),
              version(unit)
            ]
          end
          # rubocop:enable Metrics/MethodLength

          def ports(unit)
            unit.ports.map { |m| '%s(pub):%s(int)' % [ m['public'], m['internal'] ] }.join(', ')
          end

          def version(unit)
            (unit.built_version == '0.0.0') ? '' : unit.built_version
          end

          def startable(unit)
            unit.startable? ? boolean_to_human(unit.running?) : 'n/a'
          end

          def boolean_to_human(bool)
            bool ? 'yes' : 'no'
          end
      end
    end
  end
end
