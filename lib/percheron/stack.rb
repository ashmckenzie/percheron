require 'highline/import'

module Percheron
  class StackProxy

    extend Forwardable

    def initialize(config, stack_names)
      @config = config
      @stack_names = stack_names
    end

    def valid?
      true
    end

    def start!(unit_names: [])
      stacks.map { |stack| stack.start!(unit_names: unit_names) }
    end

    private

      attr_reader :config, :stack_names

      def stacks
        @stacks ||= stack_names.map { |stack_name| Percheron::Stack.new(config, stack_name) }
      end
  end

  class Stack
    extend Forwardable

    def_delegators :stack_config, :name, :description

    def initialize(config, stack_name)
      @config = config
      @stack_name = stack_name
      self
    end

    def self.get(config, name = nil)
      stacks = name.nil? ? config.stacks : { name => config.stacks[name] }
      stacks.each_with_object({}) do |stack_config, all|
        stack_name = stack_config.shift
        stack = new(config, stack_name)
        all[stack.name] = stack
      end
    end

    def metastore_key
      @metastore_key ||= 'stacks.%s' % name
    end

    def unit_configs
      stack_config.units
    end

    def units(unit_names = [])
      unit_names = !unit_names.empty? ? unit_names : filter_unit_names
      unit_names.each_with_object({}) do |unit_name, all|
        all[unit_name] = unit_from_name(unit_name)
      end
    end

    def graph!(file)
      Graph.new(self).save!(file)
      $logger.info "Saved '%s'" % file
    end

    def run!(unit_name, interactive: false, command: nil)
      Actions::Run.new(unit_from_name(unit_name), command: command, interactive: interactive).execute!
    end

    def logs!(unit_name, follow: false)
      Actions::Logs.new(unit_from_name(unit_name), follow: follow).execute!
    end

    def stop!(unit_names: [])
      execute!(Actions::Stop, filter_unit_names(unit_names).reverse)
    end

    # FIXME: bug when non-startable unit specified, all units started
    def start!(unit_names: [])
      unit_names = dependant_units_for(unit_names)
      exec_on_dependant_units_for(unit_names) do |unit|
        dependant_units = unit.startable_dependant_units.values
        Actions::Start.new(unit, dependant_units: dependant_units).execute!
      end
      nil
    end

    def restart!(unit_names: [])
      execute!(Actions::Restart, filter_unit_names(unit_names))
    end

    def build!(unit_names: [])
      unit_names = dependant_units_for(unit_names)
      exec_on_dependant_units_for(unit_names) do |unit|
        Actions::Build.new(unit).execute!
      end
      nil
    end

    def create!(unit_names: [],  start: false)
      execute!(Actions::Create, dependant_units_for(unit_names), start: start)
    end

    def recreate!(unit_names: [], start: false)
      execute!(Actions::Recreate, filter_unit_names(unit_names), start: start)
    end

    def purge!(unit_names: [], force: false)
      execute!(Actions::Purge, filter_unit_names(unit_names).reverse, force: force)
    end

    def execute!(klass, unit_names, args=nil)
      exec_on_dependant_units_for(unit_names) do |unit|
        if args
          klass.new(unit, args).execute!
        else
          klass.new(unit).execute!
        end
      end
      nil
    end

    def valid?
      Validators::Stack.new(self).valid?
    end

    private

      attr_reader :config, :stack_name

      def stack_config
        @stack_config ||= (config.stacks[stack_name] || Hashie::Mash.new({}))
      end

      # FIXME: yuck
      # rubocop:disable Style/Next
      def filter_unit_names(unit_names = [])
        stack_config.fetch('units', {}).map do |unit_name, unit_config|
          if unit_names.empty? || unit_names.include?(unit_name) ||
             (unit_config.pseudo_name &&
               unit_names.include?(unit_config.pseudo_name))
            unit_config.name
          end
        end.compact
      end
      # rubocop:enable Style/Next

      def exec_on_dependant_units_for(unit_names)
        exec_on_units(unit_names) do |unit|
          $logger.debug "Processing '#{unit.display_name}' unit"
          yield(unit)
          unit_names.delete(unit.full_name)
        end
      end

      def exec_on_units(unit_names)
        units(unit_names).each { |_, unit| yield(unit) }
      end

      def dependant_units_for(unit_names)
        list = []
        unit_names = filter_unit_names(unit_names)
        units = all_units_and_dependants(unit_names)
        units.each do |unit_name, dependant_unit_names|
          list += dependant_unit_names unless dependant_unit_names.empty?
          list << unit_name
        end
        list.uniq
      end

      def all_units_and_dependants(unit_names)
        all_units = units
        units = unit_names.each_with_object({}) do |unit_name, all|
          all[unit_name] = all_units[unit_name].dependant_unit_names
        end
        units.sort { |x, y| x[1].length <=> y[1].length } # FIXME
      end

      def unit_from_name(name)
        # FIXME
        res = name.match(/^((?<stack_name>[^:]+):)?(?<unit_name>[^:]+)$/)
        stack = res[:stack_name] ? self.class.new(config, res[:stack_name]) : self
        Unit.new(config, stack, res[:unit_name])
      end
  end
end
