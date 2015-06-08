require 'graphviz'

module Percheron
  class Graph

    def initialize(stacks)
      @stacks = stacks

      @nodes = {}
      @stack_graph = {}
      @unit_group_graph = {}
    end

    def save!(file)
      generate
      save(file)
    end

    private

      attr_reader :stacks
      attr_accessor :nodes, :stack_graph, :unit_group_graph

      def generate
        stacks.each do |stack|
          stack.units.each do |_, unit|
            add_node(stack, unit)
            unit.dependant_units.each do |_, dependant_unit|
              add_node(dependant_unit.stack, dependant_unit)
              graph.add_edges(nodes[unit.display_name], nodes[dependant_unit.display_name],
                              node_link_opts(dependant_unit))
            end
          end
        end
      end

      def save(file)
        graph.output(png: file)
      end

      def graph
        @graph ||= GraphViz.new(:G, graph_opts)
      end

      def graph_opts
        { type: :digraph, nodesep: 0.75, ranksep: 1.0, fontsize: 12 }
      end

      def add_node(stack, unit)
        create_stack(stack)
        unit.pseudo? ? add_pseudo_node(stack, unit) : add_real_node(stack, unit)
      end

      def add_real_node(stack, unit)
        nodes[unit.display_name] = stack_graph[stack.name].add_nodes(unit.name, node_opts(unit))
      end

      def add_pseudo_node(stack, unit)
        create_unit_group(stack, unit)
        nodes[unit.display_name] = unit_group_graph[unit.pseudo_name].add_nodes(unit.name, pseudo_node_opts(unit))
      end

      def create_stack(stack)
        return nil if stack_graph[stack.name]
        name = 'cluster-stack%s' % stack_graph.keys.count
        stack_graph[stack.name] = graph.add_graph(name, stack_opts(stack))
      end

      def stack_opts(stack)
        label = '%s\n%s\n' % [ stack.name, stack.description ]
        { label: label, style: 'filled', fontcolor: 'black', color: 'lightblue' }
      end

      def create_unit_group(stack, unit)
        return nil if unit_group_graph[unit.pseudo_name]
        name = 'cluster-unit-group%s' % unit_group_graph.keys.count
        unit_group_graph[unit.pseudo_name] = stack_graph[stack.name].add_graph(name, unit_group_opts(unit))
      end

      def unit_group_opts(unit)
        { label: unit.pseudo_name, style: 'filled', color: 'lightgrey' }
      end

      def node_opts(unit)
        shape = unit.startable? ? 'box' : 'ellipse'
        label = [ unit.name ]
        unit.ports.each { |ports| label << 'public: %s, internal: %s' % ports.split(':') }
        { style: 'filled', color: 'white', shape: shape, label: label.join("\n"),
          fontname: 'arial', fontsize: 12 }
      end

      def pseudo_node_opts(unit)
        node_opts(unit)
      end

      def node_link_opts(unit)
        direction = unit.startable? ? 'forward' : 'none'
        style     = unit.startable? ? 'solid' : 'solid'
        color     = unit.startable? ? 'black' : 'gray'
        { dir: direction, style: style, color: color }
      end

  end
end
