module Percheron
  class Stack

    extend Forwardable

    def_delegators :stack_config, :name, :description

    def initialize(config, stack_name)
      @config = config
      @stack_name = stack_name
      valid?
      self
    end

    def self.get(config, stack_name=nil)
      if stack_name
        stack = new(config, stack_name)
        stack ? { stack.name => stack } : {}
      else
        all = {}
        config.stacks.each do |stack_name, _|
          stack = new(config, stack_name)
          all[stack.name] = stack
        end
        all
      end
    end

    def container_configs
      stack_config.containers.to_hash_by_key(:name)
    end

    # FIXME: YUCK
    def filter_containers(container_names=[])
      container_names = !container_names.empty? ? container_names : filter_container_names
      container_names.inject({}) do |all, container_name|
        all[container_name] = Container.new(config, self, container_name)
        all
      end
    end

    def stop!(container_names: [])
      container_names = dependant_containers_for(container_names).reverse
      exec_on_dependant_containers_for(container_names) { |container| Actions::Stop.new(container).execute! }
    end

    def start!(container_names: [])
      container_names = dependant_containers_for(container_names)
      exec_on_dependant_containers_for(container_names) { |container| Actions::Start.new(container, container.dependant_containers.values).execute! }

    end

    def restart!(container_names: [])
      container_names = dependant_containers_for(container_names)
      exec_on_dependant_containers_for(container_names) { |container| Actions::Restart.new(container).execute! }
    end

    def create!(container_names: [])
      container_names = dependant_containers_for(container_names)
      exec_on_dependant_containers_for(container_names) { |container| Actions::Create.new(container).execute! }
    end

    def recreate!(container_names: [], force_recreate: false, delete: false)
      current = container_names_final = filter_container_names(container_names)

      # FIXME: make this suck less
      while true
        current = deps = containers_affected(current).uniq
        break if deps.empty?
        container_names_final += deps
      end

      exec_on_dependant_containers_for(container_names_final.uniq) { |container| Actions::Recreate.new(container, force_recreate: force_recreate, delete: delete).execute! }
    end

    def purge!(container_names: [])
      container_names = filter_container_names(container_names)
      exec_on_dependant_containers_for(container_names) { |container| Actions::Purge.new(container).execute! }
    end

    def valid?
      Validators::Stack.new(self).valid?
    end

    private

      attr_reader :config, :stack_name

      def stack_config
        @stack_config ||= (config.stacks[stack_name] || Hashie::Mash.new({}))
      end

      def filter_container_names(container_names=[])
        stack_config.containers.map do |container_config|
          if container_names.empty? || container_names.include?(container_config.name)
            container_config.name
          end
        end.compact
      end

      def exec_on_containers(container_names)
        filter_containers(container_names).each { |_, container| yield(container) }
      end

      def exec_on_dependant_containers_for(container_names)
        serial_processor(container_names) do |container|
          yield(container)
          $logger.info ''
        end
      end

      def serial_processor(container_names)
        exec_on_containers(container_names) do |container|
          yield(container)
          container_names.delete(container.name)
        end
      end

      def containers_affected(container_names)
        deps = []
        container_names.each do |container_name|
          filter_containers.each do |_, container|
            deps << container.name if container.dependant_container_names.include?(container_name)
          end
        end
        deps
      end

      def containers_and_their_dependants(container_names)
        all_containers = filter_containers
         container_names.inject({}) do |all, container_name|
          all[container_name] = all_containers[container_name].dependant_container_names
          all
        end
      end

      def dependant_containers_for(container_names)
        container_names = filter_container_names(container_names)

        wip_list = []
        containers_and_their_dependants(container_names).each do |container_name, dependant_container_names|
          wip_list += dependant_container_names unless dependant_container_names.empty?
          wip_list << container_name
        end
        wip_list.uniq
      end

  end
end
