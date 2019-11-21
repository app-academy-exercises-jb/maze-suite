require_relative 'node.rb'

class Trie
    attr_reader :head, :pointer

    #Basic Functionality
    def initialize(head)     
        @head = head
        reset_pointer
    end

    def valid_subnodes
        @pointer.children
    end
    
    #Pointer Functionlity
    def reset_pointer 
        @pointer = @head
    end

    def traverse_pointer(new_head)
        head = @pointer.node_at(new_head)
        if head
            @pointer = head
        else
            raise "invalid head"
        end
    end
end
