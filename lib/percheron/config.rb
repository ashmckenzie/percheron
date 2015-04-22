require 'yaml'

module Percheron
  class Config

    DEFAULT_CONFIG_FILE = '.percheron.yml'

    extend Forwardable

    def_delegators :contents, :docker

    def initialize(file)
      @file = Pathname.new(file).expand_path
      docker_setup!
      self
    end

    def stacks
      process_stacks!
    end

    def file_base_path
      file.dirname
    end

    def valid?
      Validators::Config.new(file).valid?
    end

    def self.load!(config_file = DEFAULT_CONFIG_FILE)
      new(config_file)
    end

    private

      attr_reader :file

      def process_stacks!   # FIXME: bugs here :(
        stacks_by_name = contents.stacks.to_hash_by_key(:name)
        scanned = scan_container_configs(stacks_by_name)
        stacks_by_name.each do |_, stack|
          stack_containers = stack.containers.each_with_object({}) do |container_config, all|
            scanned[container_config.name] ? merge(all, container_config, scanned) : replace_scanned(all, container_config, scanned)
          end
          stack.containers = stack_containers
        end
      end

      def merge(all, container_config, scanned)  # FIXME: poor name
        all.merge!(expand_container_config(container_config, scanned[container_config.name]))
      end

      def replace_scanned(all, container_config, scanned)  # FIXME: poor name
        unless (scanned_match = container_config.fetch(:dependant_container_names, []) & scanned.keys).empty?
          container_config.dependant_container_names = scanned_match.map { |v| scanned[v] }.flatten
        end
        all[container_config.name] = container_config
      end

      def scan_container_configs(stacks_by_name)  # FIXME
        all = {}
        stacks_by_name.each do |_, stack|
          stack.containers.each do |container_config|
            if container_config.fetch(:instances, 1) > 1
              all[container_config.name] = 1.upto(container_config.instances).map { |number| "#{container_config.name}#{number}" }
            end
          end
        end
        all
      end

      def expand_container_config(container_config, new_container_names)  # FIXME
        new_container_names.each_with_object({}) do |new_name, all|
          temp_container_config = container_config.dup
          temp_container_config.delete(:instances)
          temp_container_config.pseudo_name = container_config.name
          temp_container_config.name = new_name
          all[new_name] = eval_container_config(temp_container_config)
        end
      end

      def eval_container_config(container_config)
        template = Liquid::Template.parse(container_config.to_h.to_yaml.to_s)
        YAML.load(template.render(container_config))
      end

      def contents
        Hashie::Mash.new(YAML.load_file(file))
      end

      def docker_setup!
        Percheron::DockerConnection.new(self).setup!
      end
  end
end
