# frozen_string_literal: true

require_relative 'reader.rb'

class Maze
  def solve_maze
    @queue = []
    @discovered = Hash.new { |h, k| h[k] = false }
    @parents = {}

    breadth_first_search

    end_pos = @parents.keys.select { |key| key.value == 'E' }[0]
    current_post = end_pos
    until current_post.value == 'S'
      current_post.value = 'X' unless current_post.value == 'E'
      current_post = @parents[current_post]
    end

    print_maze
  end

  def breadth_first_search
    start = @maze.head
    @queue.unshift(start)
    @discovered[start] = true
    until @queue.empty?
      node = @queue.pop
      node.children.select { |child| child.value != "*" }.each do |child|
        if @discovered[child] == false
          @queue.unshift(child)
          @discovered[child] = true
          @parents[child] = node
        end
      end
    end
  end
  private :breadth_first_search
end
