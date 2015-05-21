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
              'Unit ID',
              'Image ID',
              'Up?',
              'IP',
              'Ports',
              'Volumes',
              'Volumes from',
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
              Thread.new do
                queue.size.times { resp << queue.pop(true) }
              end
            end.map(&:join)
            resp
          end

          def row_for(unit)
            [
              unit.name,
              unit.id,
              unit.image_id,
              startable(unit),
              unit.ip,
              unit.ports.join(', '),
              unit.volumes.join(', '),
              unit.volumes_from.join(', '),
              version(unit)
            ]
          end

          def version(unit)
            (unit.built_version == '0.0.0') ? '' : unit.built_version
          end

          def startable(unit)
            if unit.startable?
              unit.running? ? 'yes' : 'no'
            else
              'n/a'
            end
          end
      end
    end
  end
end
