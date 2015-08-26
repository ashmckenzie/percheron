require 'graphviz'

module Percheron
  class Graph

    def initialize(config, stacks, stack_name)
      @config = config
      @stacks = stacks
      @stack_name = stack_name

      @nodes = {}
      @all_nodes ={}
      @graphs = {}
    end

    def save!(file)
      generate
      save(file)
    end

    private

      attr_reader :config, :stacks, :stack_name
      attr_accessor :nodes, :all_nodes, :graphs

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

      def stack
        @stack ||= stacks[stack_name]
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
          >' % [ graph_name, graph_description ]
      end

      def graph_name
        return stack_name if stack_name
        config.project.name || ' '
      end

      def graph_description
        return stack.description if stack && stack.description
        config.project.description || ' '
      end

      def stacks_and_units
        @stacks_and_units ||= begin
          stacks.each_with_object({}) do |stack_tuple, all|
            stack_name, stack = stack_tuple
            all[stack_name] = stack.units
          end
        end
      end

      def stack_units_for(stack_name)
        if stack_name
          { stack_name => stacks_and_units[stack_name] }
        else
          stacks_and_units
        end
      end

      def add_nodes
        stack_units_for(stack_name).each do |stack_name, units|
          units.each do |unit_name, unit|
            key = '%s:%s' % [ stack_name, unit_name ]
            $logger.debug "Adding #{key}"
            nodes[key] = unit.pseudo? ? pseudo_node_from(unit) : node_from(unit)

            unit.needed_units(stacks).each do |un, u|
              next if nodes[un]
              $logger.debug "Adding dep #{un}"
              nodes[un] = unit.pseudo? ? pseudo_node_from(u) : node_from(u)
            end
          end
        end
      end

      def node_from(unit)
        graph.add_nodes(unit.name, node_opts(unit))
      end

      def pseudo_node_from(unit)
        create_cluster(unit)
        graphs[unit.pseudo_name].add_nodes(unit.name, pseudo_node_opts(unit))
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
        stack_units_for(stack_name).each do |stack_name, units|
          units.each do |unit_name, unit|
            unit.needed_units(stacks).each do |needed_name, needed_unit|
              name = '%s:%s' % [ stack_name, unit_name ]
              $logger.debug "Adding link for #{name} to #{needed_name}"
              graph.add_edges(nodes[name], nodes[needed_name], node_link_opts(needed_unit))
            end
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
