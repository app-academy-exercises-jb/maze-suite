require 'byebug'
require_relative 'trie/trie.rb'

class Maze_Reader
    attr_reader :maze
    #the objective of this class is to present Maze_Solver with something that it can cleanly parse. that is, a Maze object, composed of positions, one of which is the start and another the end, passable or not, each of which has 2, 3, or 4 connected positions (corner, edge, or center). Ergo, this maze has no diagonal movement.
    
    #We can represent this maze as an undirected, unweighted graph using our pre-existing Trie data structure with some changes.
    def initialize(object)
        #we expect object to be an array, all of whose elements are the same length
        #for the sake of argument, we will consider the following symbols: 
        #" " will be a space we can move into
        #"*" will be an obstacle -- a space we cannot move into
        #"E" and "S" -- there must be exactly one of each. we will initialize @end and @start variables at their positions
        
        #raise "error" if any of the above are false

        @literal = object
        @x = @literal.length - 1
        @y = @literal[0].length - 1
        define_positions

        #create an array of arrays of nodes, corresponding to the maze's grid size
        #when we find S and E, assign head and terminator, respectively
        @positions = Array.new(object.length) { |i| 
            Array.new(object[0].length) { |i2| 
                new_node = Node.new(object[i][i2])
                unless /[SE *]/.match?(object[i][i2])
                    raise "fatal"
                end
                case object[i][i2]
                when "S"
                    @head = new_node
                when "E"
                    new_node.terminator = true
                end
                new_node
            }
        }

        #go through all of our nodes, and decide who is going to be neighbors
        #neighbors are grid-adjacent, walkable tiles
        @positions.each_with_index { |row, idx|
            row.each_with_index { |position, idx2|
                case position_type(idx, idx2)
                when :edge
                    edge(position, idx, idx2)
                when :corner
                    corner(position, idx, idx2)
                when :central
                    central(position, idx, idx2)
                else
                    raise "fatal"
                end
            }
        }

        #this trie object represents the maze as a series of choices to be made, starting from the start position.
        @maze = Trie.new(@head)
    end

    #Maze Helper Methods
    def print_maze
        @positions.each { |row| 
            line = ""
            row.each { |column|
                line += column.value
            }
            p line
        }
        nil
    end


    #Initialize Helper Methods
    def define_positions
        @corners = [[0,0],[@x,0],[0,@y],[@x,@y]]
        @edges = []
        (1..@y-1).each { |i| @edges << [0,i] }
        (1..@y-1).each { |i| @edges << [@x,i] }
        (1..@x-1).each { |i| @edges << [i,0] }
        (1..@x-1).each { |i| @edges << [i,@y] }
    end

    def position_type(num_1, num_2)
        #returns :edge, :corner, or :other
        if @corners.include?([num_1, num_2])
            return :corner
        elsif @edges.include?([num_1, num_2])
            return :edge
        elsif (num_1 > @x || num_2 > @y)
            return :none
        else
            return :central
        end
    end

    #the following code is very smelly, pls fix?
    def corner(position, idx, idx2)
        positions = []
        case idx
        when 0
            if idx2 == 0
                positions << @positions[idx][idx2+1] if @positions[idx][idx2+1].value != "*"
                positions << @positions[idx+1][idx2] if @positions[idx+1][idx2].value != "*"
            else
                positions << @positions[idx][idx2-1] if @positions[idx][idx2-1].value != "*"
                positions << @positions[idx+1][idx2] if @positions[idx+1][idx2].value != "*"
            end
        when @y
            if idx2 == 0
                positions << @positions[idx][idx2+1] if @positions[idx][idx2+1].value != "*"
                positions << @positions[idx-1][idx2] if @positions[idx-1][idx2].value != "*"
            else
                positions << @positions[idx][idx2-1] if @positions[idx][idx2-1].value != "*"
                positions << @positions[idx-1][idx2] if @positions[idx-1][idx2].value != "*"
            end
        end
        position.give_children(positions)
    end

    def edge(position, idx, idx2)
        positions = []
        
        case idx
        when 0 && position_type(idx, idx2) != :corner
            positions << @positions[idx][idx2-1] if @positions[idx][idx2-1].value != "*"
            positions << @positions[idx][idx2+1] if @positions[idx][idx2+1].value != "*"
            positions << @positions[idx+1][idx2] if @positions[idx+1][idx2].value != "*"
        when @y && position_type(idx, idx2) != :corner
            positions << @positions[idx][idx2-1] if @positions[idx][idx2-1].value != "*"
            positions << @positions[idx][idx2+1] if @positions[idx][idx2+1].value != "*"
            positions << @positions[idx-1][idx2] if @positions[idx-1][idx2].value != "*"
        end
        
        case idx2
        when 0 && position_type(idx, idx2) != :corner
            positions << @positions[idx][idx2+1] if @positions[idx][idx2+1].value != "*"
            positions << @positions[idx+1][idx2] if @positions[idx+1][idx2].value != "*"
            positions << @positions[idx-1][idx2] if @positions[idx-1][idx2].value != "*"
        when @y && position_type(idx, idx2) != :corner
            positions << @positions[idx][idx2-1] if @positions[idx][idx2-1].value != "*"
            positions << @positions[idx+1][idx2] if @positions[idx+1][idx2].value != "*"
            positions << @positions[idx-1][idx2] if @positions[idx-1][idx2].value != "*"
        end
        
        position.give_children(positions)
    end

    def central(position, idx, idx2)
        positions = []
        type = position_type(idx, idx2)
        unless type == :corner || type == :edge 
            positions << @positions[idx-1][idx2] if @positions[idx-1][idx2].value != "*"
            positions << @positions[idx][idx2-1] if @positions[idx][idx2-1].value != "*"
            positions << @positions[idx][idx2+1] if @positions[idx][idx2+1].value != "*"
            positions << @positions[idx+1][idx2] if @positions[idx+1][idx2].value != "*"
        end
        position.give_children(positions)
    end

end