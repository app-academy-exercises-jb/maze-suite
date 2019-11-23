To see the maze suite in action, simply run 'ruby watch_em_go.rb'

As per the project's instructions, a Maze may be initialized with a string, which will be assumed to be a relative path to a .txt file on disk. However, Maze can also be initialized with a pair of numbers (minimum of 5 each), which will construct a random maze of that grid size. Usage is as follows:

    maze = Maze.new('mazes/maze_2.txt')
    maze = Maze.new(15, 15)

Maze objects have an ease of life #print_maze method which will show you the parsed maze. At this point you can choose to invoke the method #solve_maze, which will automatically print the solved maze. Eg:

    maze.solve_maze


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