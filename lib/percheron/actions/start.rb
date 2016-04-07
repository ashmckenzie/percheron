module Percheron
  module Actions
    class Start
      include Base

      def initialize(unit, needed_units: [], create: true, cmd: false)
        @unit = unit
        @needed_units = needed_units
        @create = create
        @cmd = cmd
      end

      def execute!
        return nil if unit.running?
        results = []
        results << create! unless unit.exists?
        results << start!  if unit.startable?
        results.compact.empty? ? nil : unit
      end

      private

        attr_reader :unit, :needed_units, :create, :cmd

        alias_method :create?, :create

        def create!
          return nil unless create?
          Create.new(unit, cmd: cmd).execute!
        end

        def start!
          return nil if unit_running?
          $logger.info "Starting '#{unit.display_name}' unit"
          if needed_unit_names_not_running.empty?
            unit.container.start!
          else
            $logger.error "Cannot start '%s' unit because %s is not running" % [ unit.display_name, needed_unit_names_not_running ]
          end
        end

        def unit_running?
          !unit.startable? || unit.running?
        end

        def needed_unit_names_not_running(retry_max=3, delay=3)
          @needed_unit_names_not_running ||= begin
            unit.startable_needed_units.each_with_object([]) do |unit_tuple, all|
              retry_count = 0
              _, unit = unit_tuple
              until retry_count > (retry_max + 1)
                break if unit.running?
                retry_count += 1
                if retry_count > retry_max
                  all << unit.display_name
                  break
                else
                  $logger.warn "Waiting #{delay} secs for '#{unit.display_name}' to start (#{retry_count}/#{retry_max})"
                  sleep(delay)
                end
              end
            end
          end
        end
    end
  end
end
