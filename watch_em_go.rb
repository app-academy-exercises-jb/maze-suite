require_relative 'solver.rb'
require_relative 'reader.rb'
require_relative 'maker.rb'


maze_1 = Maze.new('mazes/maze_2.txt')
maze_1.solve_maze

p "-"*32

maze_2 = Maze.new(15, 15)
maze_2.solve_maze
