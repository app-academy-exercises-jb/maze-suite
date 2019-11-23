require 'byebug'
require_relative 'trie/trie.rb'

class Maze
  def random_maze(x, y)
    raise 'params must be ints' unless x.is_a?(Integer) && y.is_a?(Integer)

    @x = x - 1
    @y = y - 1

    make_grid(x, y)
    connect_grid
    draw_maze
  end
  private :random_maze

  def draw_maze # this is an implementation of DFS
    @stack = [] # we will only use push and pop for FIFO behaviour
    @discovered = Hash.new { |h, k| h[k] = false }
    @parents = {}

    start = @edges[rand(@edges.length)] # this is a random edge start
    start_pos = @grid[start[0]][start[1]]

    @discovered[start_pos] = true

    next_pos = start_pos.children.inject(nil) do |acc, child|
      @discovered[child] = true
      acc || (outside_edge?(child) ? acc : child)
    end # after setting an edge to 'S', we set its only non-edge neighbor to next_pos
    # we declare all of its neighbors discovered
    next_pos.value = 'S'
    @head = next_pos
    @stack.push(next_pos)
    until @stack.empty?
      node = @stack.pop

      node.children.shuffle.each do |child| # here we want to choose randomly
        next unless @discovered[child] == false

        @discovered[child] = true
        next if outside_edge?(child)

        # can i move 'forward' two, without reaching an edge?
        # choose that one, move, and add that position to the stack
        the_one_after = direction(node, child)
        next unless the_one_after.is_a?(Node) &&
                    !outside_edge?(the_one_after) &&
                    the_one_after.value == '*'

        child.value = ' '
        the_one_after.value = ' '
        @discovered[the_one_after] = true

        @parents[the_one_after] = node
        @stack.push(the_one_after)
      end
    end
    @parents.keys[-1].value = 'E'
    @parents.keys[-1].terminator = true
  end
  private :draw_maze

  def direction(node_1, node_2)
    movement = [(@coordinates[node_1][0] - @coordinates[node_2][0]), (@coordinates[node_1][1] - @coordinates[node_2][1])]

    case movement
    when [1, 0] # up
      new_node = [(@coordinates[node_2][0] - 1), (@coordinates[node_2][1])]
    when [-1, 0] # down
      new_node = [(@coordinates[node_2][0] + 1), (@coordinates[node_2][1])]
    when [0, 1] # left
      new_node = [(@coordinates[node_2][0]), (@coordinates[node_2][1]) - 1]
    when [0, -1] # right
      new_node = [(@coordinates[node_2][0]), (@coordinates[node_2][1]) + 1]
    end

    @grid[new_node[0]][new_node[1]]
  end
  private :direction
end
