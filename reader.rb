# frozen_string_literal: true
require 'byebug'
require_relative 'trie/trie.rb'
require_relative 'maker.rb'
require_relative 'solver.rb'

class Maze
  attr_reader :maze

  def initialize(*args)
    # as per the instructions, a Maze may be initialized with a string, which will be assumed to be a relative path to a .txt file on disk.
    # however, Maze can also be initialized with a number(min 5), which will construct a random maze of that size

    case args.length
    when 1
      #We assume we have a relative path to a file, expecting to find a legal maze
      raise TypeError.new("argument must be a string") unless args[0].is_a?(String)
      raise "the file #{args[0]} does not exist" unless File.exist?(args[0])

      maze = File.read(args[0]).split("\n")
      unless maze.flatten.all? { |c| /[SE *]/.match?(c) }
        raise "invalid characters found"
      end
      unless maze.all? { |row| row.length == maze[0].length }
        raise "Mazes currently must be rectangular"
      end


      prc = Proc.new { |_i, _i2| 
        node = Node.new(maze[_i][_i2])
        case node.value
        when 'S'
          @head = node
        when 'E'
          node.terminator = true
        end
        node
      }

      @x = maze.length - 1
      @y = maze[0].length - 1



      make_grid(maze.length, maze[0].length, &prc)
      connect_grid

    when 2
      unless args.all? { |a| a.is_a?(Integer) && a >= 5 }
        raise 'Both args must be integers greater than 4'
      end

      random_maze(args[0], args[1])
    end

    @maze = Trie.new(@head)
    #We set self.maze to a trie which may be traversed by ::solve_maze
  end

  def print_maze
    @grid.each do |row|
      line = ''
      row.each do |column|
        line += column.value
      end
      p line
    end
    nil
  end

  def make_grid(x, y, &prc)
    define_positions
    @coordinates = {}
    @grid = Array.new(x) do |_i|
      Array.new(y) do |_i2|
        if prc
          node = prc.call(_i, _i2)
        else
          node = Node.new('*')
        end
        @coordinates[node] = [_i, _i2]
        node
      end
    end # we create an x by y sized grid of Nodes
  end
  private :make_grid

  def connect_grid(&prc)
    @grid.each_with_index do |row, idx|
      row.each_with_index do |position, idx2|
        case position_type(idx, idx2)
        when :edge
          edge(position, idx, idx2)
        when :corner
          corner(position, idx, idx2)
        when :central
          central(position, idx, idx2)
        else
          raise 'fatal'
        end
      end
    end # and connect them in such a fashion as to connote a rectangular planar graph
  end
  private :connect_grid

  def define_positions
    @corners = [[0, 0], [@x, 0], [0, @y], [@x, @y]]
    @edges = [] # discludes corners
    (1..@y - 1).each { |i| @edges << [0, i] }
    (1..@y - 1).each { |i| @edges << [@x, i] }
    (1..@x - 1).each { |i| @edges << [i, 0] }
    (1..@x - 1).each { |i| @edges << [i, @y] }
  end
  protected :define_positions

  def position_type(num_1, num_2)
    # returns :edge, :corner, or :other
    if @corners.include?([num_1, num_2])
      :corner
    elsif @edges.include?([num_1, num_2])
      :edge
    elsif num_1 > @x || num_2 > @y || num_1 < 0 || num_2 < 0
      :none
    else
      :central
    end
  end
  private :position_type

  def outside_edge?(node)
    @edges.any?(@coordinates[node]) ||
    @corners.any?(@coordinates[node])
  end
  private :outside_edge?

  # the following code is very smelly, pls fix?
  def corner(position, idx, idx2)
    positions = []
    case idx
    when 0
      if idx2 == 0
        positions << @grid[idx][idx2 + 1]
        positions << @grid[idx + 1][idx2]
      else
        positions << @grid[idx][idx2 - 1]
        positions << @grid[idx + 1][idx2]
      end
    when @y
      if idx2 == 0
        positions << @grid[idx][idx2 + 1]
        positions << @grid[idx - 1][idx2]
      else
        positions << @grid[idx][idx2 - 1]
        positions << @grid[idx - 1][idx2]
      end
    end
    positions.each { |node| position.connect(node) }
  end
  private :corner

  def edge(position, idx, idx2)
    positions = []

    case idx
    when 0 # && position_type(idx, idx2) != :corner
      positions << @grid[idx][idx2 - 1]
      positions << @grid[idx][idx2 + 1]
      positions << @grid[idx + 1][idx2]
    when @x # && position_type(idx, idx2) != :corner
      positions << @grid[idx][idx2 - 1]
      positions << @grid[idx][idx2 + 1]
      positions << @grid[idx - 1][idx2]
    end

    case idx2
    when 0 # && position_type(idx, idx2) != :corner
      positions << @grid[idx][idx2 + 1]
      positions << @grid[idx + 1][idx2]
      positions << @grid[idx - 1][idx2]
    when @y # && position_type(idx, idx2) != :corner
      positions << @grid[idx][idx2 - 1]
      positions << @grid[idx + 1][idx2]
      positions << @grid[idx - 1][idx2]
    end

    positions.each { |node| position.connect(node) }
  end
  private :edge

  def central(position, idx, idx2)
    positions = []
    type = position_type(idx, idx2)
    unless type == :corner || type == :edge
      positions << @grid[idx - 1][idx2]
      positions << @grid[idx][idx2 - 1]
      positions << @grid[idx][idx2 + 1]
      positions << @grid[idx + 1][idx2]
    end
    positions.each { |node| position.connect(node) }
  end
  private :central
end