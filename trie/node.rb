class Node
    attr_reader :children
    attr_accessor :value, :terminator
    
    def initialize(value=nil)
        @value = value
        @children = []
        @terminator = false
    end

    def give_child(value)
        raise TypeError.new("value is not a node") unless value.kind_of?(Node)
        @children << value 
    end

    def give_children(values)
        unless values.kind_of?(Array) && values.all? { |value| value.kind_of?(Node) }
            raise TypeError.new("value is not a node")
        end

        @children += values
    end

    def node_at(node)
        raise TypeError.new("value is not a node") unless node.kind_of?(Node)
        @children.select { |child| child == node }[0]
    end
end