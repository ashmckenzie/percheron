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

          def headings
            [
              'Unit',
              'ID',
              'Running?',
              'IP',
              'Ports',
              'Volumes',
              'Size',
              'Version'
            ]
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

          def row_for(unit)
            [
              unit.name,
              unit.id,
              startable(unit),
              unit.ip,
              unit.ports.join(', '),
              unit.volumes.join("\n"),
              unit.image_size,
              version(unit)
            ]
          end

          def version(unit)
            (unit.built_version == '0.0.0') ? '' : unit.built_version
          end

          def startable(unit)
            if unit.startable?
              unit.running? ? 'yes' : '-'
            else
              'n/a'
            end
          end
      end
    end
  end
end
