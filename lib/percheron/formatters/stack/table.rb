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
            resp = {}
            queue_jobs(resp)
            process_queue!
            sort_rows(resp)
          end

          def queue_jobs(resp)
            stack.containers.map do |_, container|
              queue << Thread.new { resp[Time.now.to_f] = row_for(container) }
            end
          end

          def process_queue!
            queue.length.times { queue.pop.join }
          end

          def sort_rows(resp)
            resp.sort.map { |_, row| row.flatten }
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
