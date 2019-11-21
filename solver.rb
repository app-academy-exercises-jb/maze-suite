require_relative 'reader.rb'

class Maze_Solver
   def self.breadth_first_search
      start = @maze.head
      @queue.unshift(start)
      @discovered[start] = true
      until @queue.empty?
         node = @queue.pop
         node.children.each { |child|
            if @discovered[child] == false
               @queue.unshift(child)
               @discovered[child] = true
               @parents[child] = node
            end
         }
      end
   end

   def self.solve_maze(maze)
      raise "only mazes pls" unless maze.kind_of?(Maze_Reader)
      @maze = maze.maze
      @queue = []  
      @discovered = Hash.new { |h,k| h[k] = false }
      @parents = {}

      self.breadth_first_search



      end_pos = @parents.keys.select { |key| key.value == "E" }[0]
      current_post = end_pos
      until current_post.value == "S"
         current_post.value = "X" unless current_post.value == "E"
         current_post = @parents[current_post]
      end
   end
end