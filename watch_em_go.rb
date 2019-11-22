require_relative 'solver.rb'
require_relative 'reader.rb'
require_relative 'maker.rb'


random_maze = Maze_Reader.new(Maze_Maker.draw_maze(11))
random_maze.print_maze

Maze_Solver.solve_maze(random_maze)

p "-"*32
random_maze.print_maze