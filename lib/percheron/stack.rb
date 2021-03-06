require 'highline/import'

module Percheron
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
      @metastore_key ||= 'stacks.%s' % [ name ]
    end

    def unit_configs
      stack_config.units
    end

    def units(unit_names = [])
      unit_names = unit_names.empty? ? stack_units.keys : unit_names
      unit_names.each_with_object({}) do |unit_name, all|
        all[unit_name] = unit_from_name(unit_name)
      end
    end

    def graph!(file)
      Graph.new(self).save!(file)
      $logger.info "Saved '%s'" % [ file ]
    end

    def shell!(unit_name, raw_command: Percheron::Actions::Shell::DEFAULT_COMMAND)
      Actions::Shell.new(unit_from_name(unit_name), raw_command: raw_command).execute!
    end

    def logs!(unit_name, follow: false)
      Actions::Logs.new(unit_from_name(unit_name), follow: follow).execute!
    end

    def stop!(unit_names: [])
      unit_names = stack_units.keys if unit_names.empty?
      execute!(Actions::Stop, filter_unit_names(unit_names).reverse)
    end

    def start!(unit_names: [])
      unit_names = stack_units.keys if unit_names.empty?
      unit_names = needed_units_for(unit_names)
      exec_on_needed_units_for(unit_names) do |unit|
        needed_units = unit.startable_needed_units.values
        Actions::Start.new(unit, needed_units: needed_units).execute!
      end
      nil
    end

    def restart!(unit_names: [])
      unit_names = stack_units.keys if unit_names.empty?
      execute!(Actions::Restart, filter_unit_names(unit_names))
    end

    def build!(unit_names: [], usecache: true, forcerm: false)
      unit_names = stack_units.keys if unit_names.empty?
      unit_names = needed_units_for(unit_names)
      exec_on_needed_units_for(unit_names) do |unit|
        Actions::Build.new(unit, usecache: usecache, forcerm: forcerm).execute!
      end
      nil
    end

    def create!(unit_names: [], build: true, start: false, deep: false, force: false)
      opts = { build: build, start: start, force: force }
      unit_names = if deep
                     unit_names = stack_units.keys if unit_names.empty?
                     needed_units_for(unit_names)
                   else
                     filter_unit_names(unit_names)
                   end
      execute!(Actions::Create, unit_names, opts)
    end

    def purge!(unit_names: [], force: false)
      unit_names = stack_units.keys if unit_names.empty?
      execute!(Actions::Purge, filter_unit_names(unit_names).reverse, force: force)
    end

    def execute!(klass, unit_names, args=nil)
      exec_on_needed_units_for(unit_names) do |unit|
        args ? klass.new(unit, args).execute! : klass.new(unit).execute!
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

      def stack_units
        @stack_units ||= stack_config.fetch('units', {})
      end

      def filter_unit_names(unit_names = [])
        stack_units.map do |unit_name, unit_config|
          if unit_names.include?(unit_name) ||
             (unit_config.pseudo_name && unit_names.include?(unit_config.pseudo_name))
            unit_config.name
          end
        end.compact.uniq
      end

      def exec_on_needed_units_for(unit_names)
        exec_on_units(unit_names) do |unit|
          $logger.debug "Processing '#{unit.display_name}' unit"
          yield(unit)
          unit_names.delete(unit.full_name)
        end
      end

      def exec_on_units(unit_names)
        units(unit_names).each { |_, unit| yield(unit) }
      end

      def needed_units_for(unit_names)
        list = []
        unit_names = filter_unit_names(unit_names)
        units = all_units_and_neededs(unit_names)
        units.each do |unit_name, needed_unit_names|
          list += needed_unit_names unless needed_unit_names.empty?
          list << unit_name
        end
        list.uniq
      end

      def all_units_and_neededs(unit_names)
        all_units = units
        units = unit_names.each_with_object({}) do |unit_name, all|
          all[unit_name] = all_units[unit_name].needed_unit_names
        end
        units.sort { |x, y| x[1].length <=> y[1].length } # FIXME
      end

      def unit_from_name(unit_name)
        Unit.new(config, self, unit_name)
      end
  end
end
