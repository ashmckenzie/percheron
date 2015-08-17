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
        { type: :digraph, nodesep: 0.75, ranksep: 1.0, label: header_label }
      end

      def header_label
        '<
          <table border="0" cellborder="0">
            <tr><td height="36" valign="bottom">
              <font face="Arial Bold" point-size="14">%s</font>
            </td></tr>
            <tr><td height="18"><font face="Arial Italic" point-size="11">%s</font></td></tr>
          </table>
          >' % [ stack.name, stack_description ]
      end

      def stack_description
        stack.description || ' '
      end

      def units
        @units ||= stack.units
      end

      def add_nodes
        units.each do |_, unit|
          unit.pseudo? ? add_pseudo_node(unit) : add_node(unit)
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
        name = 'cluster%s' % graphs.keys.count
        graphs[unit.pseudo_name] = graph.add_graph(name, cluster_opts(unit))
      end

      def cluster_opts(unit)
        label = '<<font face="Arial Bold">%s</font>>' % unit.pseudo_name
        { label: label, style: 'filled', color: 'lightgrey', fontsize: 13 }
      end

      def node_opts(unit)
        shape = unit.startable? ? 'box' : 'ellipse'
        label = [ '<font face="Arial Bold" point-size="12">%s</font><br/>' % unit.name ]
        unit.ports.each do |ports|
          label << '<font point-size="11">p: %s, i: %s</font>' % ports.split(':')
        end
        { shape: shape, label: '<%s>' % [ label.join('<br/>') ], fontname: 'arial' }
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
