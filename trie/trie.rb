# frozen_string_literal: true

require_relative 'node.rb'

#This class is meant to provide a traversal mechanism of a graph definable by an interconnected set of Nodes. It features a @head in order to remember where we started in the graph, and a @pointer, which enables us to move within the graph (only in the direction of a given node's children). We #reset_pointer to come back to the @head.

class Trie
  attr_reader :head, :pointer

  # Basic Functionality
  def initialize(head)
    raise TypeError.new("#{head} is not a node") unless head.is_a?(Node)
    @head = head
    reset_pointer
  end

  # Pointer Functionlity
  def reset_pointer
    @pointer = @head
  end

  def traverse_pointer(new_head)
    @pointer[new_head]
  end

  def valid_subnodes
    @pointer.children.keys
  end
end
