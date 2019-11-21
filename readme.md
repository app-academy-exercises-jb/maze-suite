To see the maze reader and solver in action, simply run 'ruby watch_em_go.rb'

The Maze reader takes in a rectangular grid of the following characters: " ", "*", "E", and "S". Setting the head at 'S', it creates an undirected graph in which the connected nodes are connoted by the adjacency of characters in the grid. Specifically, " " is understood as a walkable tile, and is connected to any other adjacent, walkable tile; "*" is understood as a wall or barrier, and adjacent walkable tiles do not connect to these. Thus, the generated graph is a tree of legal movement choices in the maze.

The Maze solver takes in this graph and performs a depth based search on it, beginning from the head, visiting every node in the graph, and assigning it a parent node (from which it was discovered). Once this walk is completed, we simply access the terminator node, and walk backward to the beginning using our parent hash. 