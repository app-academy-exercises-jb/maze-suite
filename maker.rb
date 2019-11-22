require 'byebug'
require_relative 'trie/trie.rb'

class Maze_Maker
    def self.draw_maze(x, y)
        raise "params must be ints" unless x.kind_of?(Integer) && y.kind_of?(Integer)

        @x, @y = x, y

        name_edges
        make_grid(@x, @y)

        
        carve_out

        out = []
        @grid.each { |row| 
            line = ""
            row.each { |node| 
                line += node.value
            }
            out << line
        }

        return out
    end
    

    private_class_method def self.make_grid(x, y)
        @grid = Array.new(x) { |i| 
            Array.new(y) { |i2| 
                Node.new("*")#must still connect these
            }
        }#we create an x by y sized grid of Nodes
        @coordinates = Hash.new #we'll keep a lookup table for easy access to node position

        @grid.each_with_index { |row, idx|
            row.each_with_index { |position, idx2|
                @coordinates[position] = [idx, idx2]
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
        }#and connect them in such a fashion as to connote a rectangular planar graph
    end


    private_class_method def self.carve_out #this is an implementation of DFS

        @stack = [] #we will only use push and pop for FIFO behaviour
        @discovered = Hash.new { |h,k| h[k] = false }
        @parents = {}
        @entry_time = {}
        @time = 1

        #start = [rand(1..@x-1), rand(1..@y-1)] #this is a random central start
        start = @edges[rand(@edges.length)] #this is a random edge start
        start_pos = @grid[start[0]][start[1]]
        
        @discovered[start_pos] = true

        next_pos = start_pos.children.inject(nil) { |acc, child| 
            @discovered[child] = true
            acc ? acc : (outside_edge?(child) ? acc : child)
        }#after setting an edge to 'S', we set its only non-edge neighbor to next_pos
        #we declare all of its neighbors discovered
        next_pos.value = "S"

        @stack.push(next_pos)
        until @stack.empty?
            node = @stack.pop

            node.children.shuffle.each { |child| #here we want to choose randomly
                if @discovered[child] == false
                    @discovered[child] = true
                    unless outside_edge?(child)
                        #can i move 'forward' two, without reaching an edge?
                        #choose that one, move, and add that position to the stack
                        the_one_after = direction(node, child)
                        if the_one_after.kind_of?(Node) && 
                            !outside_edge?(the_one_after) && 
                            the_one_after.value == "*"

                            @time += 1
                            @entry_time[@time] = the_one_after

                            child.value = " "
                            the_one_after.value = " "
                            @discovered[the_one_after] = true
                            
                            @parents[the_one_after] = node
                            @stack.push(the_one_after)
                        end
                    end
                end
            }
        end
        # debugger
        @parents.keys[-1].value = "E"
        #@entry_time[@entry_time.length + 1].value = "E"
    end

    private_class_method def self.direction(node_1, node_2)
        movement = [(@coordinates[node_1][0] - @coordinates[node_2][0]), (@coordinates[node_1][1] - @coordinates[node_2][1])]

        case movement
        when [1, 0] #up
            new_node = [(@coordinates[node_2][0] - 1), (@coordinates[node_2][1])]
        when [-1, 0] #down
            new_node = [(@coordinates[node_2][0] + 1), (@coordinates[node_2][1])]
        when [0, 1] #left
            new_node = [(@coordinates[node_2][0]), (@coordinates[node_2][1]) - 1]
        when [0, -1] #right
            new_node = [(@coordinates[node_2][0]), (@coordinates[node_2][1]) + 1]
        end
        

        @grid[new_node[0]][new_node[1]]
    end

    private_class_method def self.name_edges
        @corners = [[0,0],[@x-1,0],[0,@y-1],[@x-1,@y-1]]
        @edges = [] #discludes corners
        (1..@y-2).each { |i| @edges << [0,i] }
        (1..@y-2).each { |i| @edges << [@x-1,i] }
        (1..@x-2).each { |i| @edges << [i,0] }
        (1..@x-2).each { |i| @edges << [i,@y-1] }
    end

    private_class_method def self.outside_edge?(node)
        @edges.any?(@coordinates[node]) || 
        @corners.any?(@coordinates[node])
    end

    def self.print_maze
        @grid.each { |row| 
            line = ""
            row.each { |column|
                line += column.value
            }
            p line
        }
        nil
    end

    private_class_method def self.position_type(num_1, num_2)
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
    private_class_method def self.corner(position, idx, idx2)
        positions = []
        case idx
        when 0
            if idx2 == 0
                positions << @grid[idx][idx2+1]
                positions << @grid[idx+1][idx2]
            else
                positions << @grid[idx][idx2-1]
                positions << @grid[idx+1][idx2]
            end
        when @y
            if idx2 == 0
                positions << @grid[idx][idx2+1]
                positions << @grid[idx-1][idx2]
            else
                positions << @grid[idx][idx2-1]
                positions << @grid[idx-1][idx2]
            end
        end
        position.give_children(positions)
    end

    private_class_method def self.edge(position, idx, idx2)
        positions = []
        
        case idx
        when 0# && position_type(idx, idx2) != :corner
            positions << @grid[idx][idx2-1]
            positions << @grid[idx][idx2+1]
            positions << @grid[idx+1][idx2]
        when @y-1# && position_type(idx, idx2) != :corner
            positions << @grid[idx][idx2-1]
            positions << @grid[idx][idx2+1]
            positions << @grid[idx-1][idx2]
        end
        
        case idx2
        when 0# && position_type(idx, idx2) != :corner
            positions << @grid[idx][idx2+1]
            positions << @grid[idx+1][idx2]
            positions << @grid[idx-1][idx2]
        when @y-1# && position_type(idx, idx2) != :corner
            positions << @grid[idx][idx2-1]
            positions << @grid[idx+1][idx2]
            positions << @grid[idx-1][idx2]
        end
        
        position.give_children(positions)
    end

    private_class_method def self.central(position, idx, idx2)
        positions = []
        type = position_type(idx, idx2)
        unless type == :corner || type == :edge 
            positions << @grid[idx-1][idx2]
            positions << @grid[idx][idx2-1]
            positions << @grid[idx][idx2+1]
            positions << @grid[idx+1][idx2]
        end
        position.give_children(positions)
    end
end

