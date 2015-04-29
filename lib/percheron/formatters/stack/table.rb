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
              'Container',
              'ID',
              'Running?',
              'IP',
              'Ports',
              'Volumes',
              'Version'
            ]
          end

          def rows
            queue_jobs
            process_queue!
          end

          def queue_jobs
            stack.containers.map { |_, container| queue << row_for(container) }
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

          def row_for(container)
            [
              container.name,
              container.id,
              startable(container),
              container.ip,
              container.ports.join(', '),
              container.volumes.join(', '),
              version(container)
            ]
          end

          def version(container)
            (container.built_version == '0.0.0') ? '' : container.built_version
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
