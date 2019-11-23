# frozen_string_literal: true

#This class provides us with a very general implementation of a graph. The vertices are the Nodes themselves, and edges are defined by the 'child' relationship. We can use this class to construct both directed and undirected graphs. We currently use a Boolean @terminator variable to arbitrarily decide which point in the graph constitutes an 'endpoint', as this is useful to know for several problem types.

class Node
  attr_accessor :value, :terminator

  def initialize(value = nil)
    @value = value
    @children = Hash.new { |h,k| h[k] = k }
    @terminator = false
  end

  def connect(node)
    unless node.is_a?(Node) || node.is_a?(Array)
      raise TypeError.new("#{node} is not a node")
    end

    @children[node]
  end

  def children
    @children.keys
  end

  def [](node)
    raise TypeError, 'value is not a node' unless node.is_a?(Node)
    raise ArgumentError, "node not found" unless @children.has_key?(node)
    @children[node]
  end
end