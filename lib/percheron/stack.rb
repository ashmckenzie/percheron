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
        stack_name, _ = stack_config
        stack = new(config, stack_name)
        all[stack.name] = stack
      end
    end

    def container_configs
      stack_config.containers
    end

    def containers(container_names = [])
      container_names = !container_names.empty? ? container_names : filter_container_names
      container_names.each_with_object({}) do |container_name, all|
        all[container_name] = container_from_name(container_name)
      end
    end

    def shell!(container_name, shell: Percheron::Actions::Shell::DEFAULT_SHELL)
      Actions::Shell.new(container_from_name(container_name), shell: shell).execute!
    end

    def logs!(container_name, follow: false)
      Actions::Logs.new(container_from_name(container_name), follow: follow).execute!
    end

    def stop!(container_names: [])
      container_names = filter_container_names(container_names).reverse
      exec_on_dependant_containers_for(container_names) do |container|
        Actions::Stop.new(container).execute!
      end
      nil
    end

    # FIXME: bug when non-startable container specified, all containers started
    def start!(container_names: [])
      container_names = dependant_containers_for(container_names)
      exec_on_dependant_containers_for(container_names) do |container|
        dependant_containers = container.startable_dependant_containers.values
        Actions::Start.new(container, dependant_containers: dependant_containers).execute!
      end
      nil
    end

    def restart!(container_names: [])
      container_names = filter_container_names(container_names)
      exec_on_dependant_containers_for(container_names) do |container|
        Actions::Restart.new(container).execute!
      end
      nil
    end

    def build!(container_names: [])
      container_names = dependant_containers_for(container_names)
      exec_on_dependant_containers_for(container_names) do |container|
        Actions::Build.new(container).execute!
      end
      nil
    end

    def create!(container_names: [],  start: false)
      container_names = dependant_containers_for(container_names)
      exec_on_dependant_containers_for(container_names) do |container|
        Actions::Create.new(container, start: start).execute!
      end
      nil
    end

    def recreate!(container_names: [], start: false)
      container_names = filter_container_names(container_names)
      exec_on_dependant_containers_for(container_names) do |container|
        Actions::Recreate.new(container, start: start).execute!
      end
      nil
    end

    def purge!(container_names: [])
      container_names = filter_container_names(container_names).reverse
      exec_on_dependant_containers_for(container_names) do |container|
        # FIXME: Don't delete containers that are not buildable
        Actions::Purge.new(container).execute!
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
      def filter_container_names(container_names = [])
        stack_config.fetch('containers', {}).map do |container_name, container_config|
          if container_names.empty? || container_names.include?(container_name) ||
             (container_config.pseudo_name &&
               container_names.include?(container_config.pseudo_name))
            container_config.name
          end
        end.compact
      end
      # rubocop:enable Style/Next

      def exec_on_dependant_containers_for(container_names)
        exec_on_containers(container_names) do |container|
          $logger.debug "Processing '#{container.name}' container"
          yield(container)
          container_names.delete(container.full_name)
        end
      end

      def exec_on_containers(container_names)
        containers(container_names).each { |_, container| yield(container) }
      end

      def dependant_containers_for(container_names)
        list = []
        container_names = filter_container_names(container_names)
        containers = all_containers_and_dependants(container_names)
        containers.each do |container_name, dependant_container_names|
          list += dependant_container_names unless dependant_container_names.empty?
          list << container_name
        end
        list.uniq
      end

      def all_containers_and_dependants(container_names)
        all_containers = containers
        containers = container_names.each_with_object({}) do |container_name, all|
          all[container_name] = all_containers[container_name].dependant_container_names
        end
        containers.sort { |x, y| x[1].length <=> y[1].length } # FIXME
      end

      def container_from_name(container_name)
        Container.new(self, container_name, config.file_base_path)
      end
  end
end
