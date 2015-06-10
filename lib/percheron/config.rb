require 'yaml'

module Percheron
  class Config

    extend Forwardable

    DEFAULT_CONFIG_FILE = '.percheron.yml'

    def_delegators :contents, :docker

    def initialize(file = DEFAULT_CONFIG_FILE)
      @file = Pathname.new(file).expand_path
      self
    end

    def stacks
      @stacks ||= process_stacks!
    end

    def file_base_path
      file.dirname
    end

    def valid?
      Validators::Config.new(file).valid?
    end

    private

      attr_reader :file

      def process_stacks!   # FIXME: bugs here :(
        stacks_by_name = contents.stacks.to_hash_by_key(:name)
        scanned = scan_unit_configs(stacks_by_name)
        stacks_by_name.each do |_, stack|
          stack_units = stack.fetch(:units, []).each_with_object({}) do |unit_config, all|
            merge_or_replace(all, unit_config, scanned)
          end
          $logger.warn "No units defined for '%s' stack" % stack.name if stack_units.empty?
          stack.units = stack_units
        end
      end

      def merge_or_replace(all, config, scanned)
        if scanned[config.name]
          merge_scanned(all, config, scanned)
        else
          replace_scanned(all, config, scanned)
        end
      end

      def merge_scanned(all, config, scanned)
        all.merge!(expand_unit_config(config, scanned[config.name]))
      end

      def replace_scanned(all, config, scanned)
        match = config.fetch(:dependant_unit_names, [])
        unless (match & scanned.keys).empty?
          config.dependant_unit_names = match.map { |v| scanned[v] }.flatten.compact  # FIXME
        end
        all[config.name] = config
      end

      def scan_unit_configs(stacks_by_name)  # FIXME
        all = {}
        stacks_by_name.each do |_, stack|
          stack.fetch(:units, []).each do |unit_config|
            next if unit_config.fetch(:instances, 1) == 1
            all[unit_config.name] = 1.upto(unit_config.instances).map do |number|
              "#{unit_config.name}#{number}"
            end
          end
        end
        all
      end

      def expand_unit_config(unit_config, new_unit_names)  # FIXME
        new_unit_names.each_with_object({}) do |new_name, all|
          temp_unit_config = unit_config.dup
          temp_unit_config.delete(:instances)
          temp_unit_config.pseudo_name = unit_config.name
          temp_unit_config.name = new_name
          all[new_name] = eval_unit_config(temp_unit_config)
        end
      end

      def eval_unit_config(unit_config)
        template = Liquid::Template.parse(unit_config.to_h.to_yaml.to_s)
        YAML.load(template.render(unit_config))
      end

      def contents
        Hashie::Mash.new(YAML.load_file(file))
      end
  end
end
