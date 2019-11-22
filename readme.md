To see the maze reader, maker, and solver in action, simply run 'ruby watch_em_go.rb'

The use of each is as follows. Care must be taken as input sanitation has not been properly processed.

Maze_Reader expects a rectangular array of characters, each element of which represents a line in a text maze, and expects to be instantiated. Eg:

    maze = Maze_Reader.new(File.read('mazes/maze_2.txt').split("\n"))

Maze_Reader objects have an ease of life #print_maze method.

Maze_Solver is invoked through its class method ::solve_maze. This method expects a Maze_Reader object as its argument. Eg:

    Maze_Solver.solve_maze(maze)

Finally, Maze_Maker is invoked through its class method ::draw_maze. This method expects an integer, which it will understand to be the size of the square maze it will make. Eg:

    Maze_Maker.draw_maze(11)

You can use them together like this:

    maze = Maze_Reader.new(Maze_Maker.draw_maze(11))
    Maze_Solver.solve_maze(maze)
    maze.print_maze



The Maze reader takes in a rectangular grid of the following characters: " ", "\*", "E", and "S". Setting the head at 'S', it creates an undirected graph in which the connected nodes are connoted by the adjacency of characters in the grid. Specifically, " " is understood as a walkable tile, and is connected to any other adjacent, walkable tile; "\*" is understood as a wall or barrier, and adjacent walkable tiles do not connect to these. Thus, the generated graph is a tree of legal movement choices in the maze.

The Maze solver takes in this graph and performs a breadth-first search on it, beginning from the head, visiting every node in the graph, and assigning it a parent node (from which it was discovered). Once this walk is completed, we simply access the terminator node, and walk backward to the beginning using our parent hash. 

The Maze maker makes a planar undirected graph representable by a rectangular grid in which every node is a wall ("*"). It then proceeds to take a random walk depth-first search through this graph, taking away walls and leaving walkable space as it goes. We are guaranteed to encounter every node in the graph, andby only taking double steps, to leave behind a cogent maze.

Here is a sample maze and its solution:

```
*****************
*  S        *  E*
*** * * * *** ***
* * * * *   * * *
* ******* *** * *
*   * *     *   *
*** * *** ***** *
*           * * *
* * * * * *** * *
* * * * * *     *
* ********* *** *
*   *         * *
* *** *** * *** *
*   *   * * *   *
* *** ******* * *
*       *     * *
*****************

*****************
*  SXXXXXX  *XXE*
*** * * *X***X***
* * * * *X  *X* *
* *******X***X* *
*   * *  X  *XXX*
*** * ***X*****X*
*XXXXXXXXX  * *X*
*X* * * * *** *X*
*X* * * * *XXXXX*
*X*********X*** *
*X  *XXXXXXX  * *
*X***X*** * *** *
*X  *X  * * *   *
*X***X******* * *
*XXXXX  *     * *
*****************
```