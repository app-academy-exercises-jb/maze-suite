require_relative 'solver.rb'
require_relative 'reader.rb'

maze = Maze_Reader.new(File.read('mazes/maze_4.txt').split("\n"))

maze.print_maze

Maze_Solver.solve_maze(maze)

p "-"*32
maze.print_maze