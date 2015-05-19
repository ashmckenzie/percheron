require 'graphviz'

module Percheron
  class Graph

    def initialize(stack)
      @stack = stack
      @nodes = {}
      @graphs = {}
    end

    def save!(file)
      generate
      save(file)
    end

    private

      attr_reader :stack
      attr_accessor :nodes, :graphs

      def generate
        add_nodes
        add_links
      end

      def save(file)
        graph.output(png: file)
      end

      def graph
        @graph ||= GraphViz.new(:G, graph_opts)
      end

      def graph_opts
        { type: :digraph, nodesep: 0.75, ranksep: 1.0, label: header_label, fontsize: 12 }
      end

      def units
        @units ||= stack.units
      end

      def header_label
        '\n%s\n%s\n' % [ stack.name, stack.description ]
      end

      def add_nodes
        units.each do |_, unit|
          if unit.pseudo?
            add_pseudo_node(unit)
          else
            add_node(unit)
          end
        end
      end

      def add_node(unit)
        nodes[unit.name] = graph.add_nodes(unit.name, node_opts(unit))
      end

      def add_pseudo_node(unit)
        create_cluster(unit)
        nodes[unit.name] = graphs[unit.pseudo_name].add_nodes(unit.name, pseudo_node_opts(unit))
      end

      def create_cluster(unit)
        return nil if graphs[unit.pseudo_name]
        opts = 'cluster%s' % graphs.keys.count, cluster_opts(unit)
        graphs[unit.pseudo_name] = graph.add_graph(opts)
      end

      def cluster_opts(unit)
        { label: unit.pseudo_name, style: 'filled', color: 'lightgrey' }
      end

      def node_opts(unit)
        shape = unit.startable? ? 'box' : 'ellipse'
        label = [ unit.name ]
        unit.ports.each { |ports| label << 'public: %s, internal: %s' % ports.split(':') }
        { shape: shape, label: label.join("\n"), fontname: 'arial', fontsize: 12 }
      end

      def pseudo_node_opts(unit)
        node_opts(unit).merge!(style: 'filled', color: 'white')
      end

      def add_links
        units.each do |name, unit|
          unit.dependant_units.each do |dependant_name, dependant_unit|
            graph.add_edges(nodes[name], nodes[dependant_name], node_link_opts(dependant_unit))
          end
        end
      end

      def node_link_opts(unit)
        direction = unit.startable? ? 'forward' : 'none'
        style     = unit.startable? ? 'solid' : 'solid'
        color     = unit.startable? ? 'black' : 'gray'
        { dir: direction, style: style, color: color }
      end

  end
end
