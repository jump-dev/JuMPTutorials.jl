#' ---
#' title: Sudoku
#' ---

#' **Originally Contributed by**: Iain Dunning

#' <img src="img/partialsudoku.svg" style="width: 300px; height: auto" alt="Partially Solved Sudoku">
#' <p style="text-align: center"><i>A partially solved Sudoku puzzle</i></p>

#' 
#' [Sudoku](http://en.wikipedia.org/wiki/Sudoku) is a popular number puzzle. The goal is to place the digits 1,...,9 on a nine-by-nine grid, with some of the digits already filled in. Your solution must satisfy the following rules:
#' 
#' * The numbers 1 to 9 must appear in each 3x3 square
#' * The numbers 1 to 9 must appear in each row
#' * The numbers 1 to 9 must appear in each column
#' 
#' This isn't an optimization problem, its actually a *feasibility* problem: we wish to find a feasible solution that satsifies these rules. You can think of it as an optimization problem with an objective of 0.
#' 
#' We can model this problem using 0-1 integer programming: a problem where all the decision variables are binary. We'll use JuMP to create the model, and then we can solve it with any integer programming solver.

using JuMP
using GLPK

#' We will define a binary variable (a variable that is either 0 or 1) for each possible number in each possible cell. The meaning of each variable is as follows:
#' 
#'     x[i,j,k] = 1  if and only if cell (i,j) has number k
#' 
#' where `i` is the row and `j` is the column. 

# Create a model
sudoku = Model(with_optimizer(GLPK.Optimizer))

# Create our variables
@variable(sudoku, x[i=1:9, j=1:9, k=1:9], Bin);

#' Now we can begin to add our constraints. We'll actually start with something obvious to us as humans, but what we need to enforce: that there can be only one number per cell.

for i = 1:9, j = 1:9  # Each row and each column
    # Sum across all the possible digits
    # One and only one of the digits can be in this cell, 
    # so the sum must be equal to one
    @constraint(sudoku, sum(x[i,j,k] for k in 1:9) == 1)
end

#' Next we'll add the constraints for the rows and the columns. These constraints are all very similar, so much so that we can actually add them at the same time.

for ind = 1:9  # Each row, OR each column
    for k = 1:9  # Each digit
        # Sum across columns (j) - row constraint
        @constraint(sudoku, sum(x[ind,j,k] for j in 1:9) == 1)
        # Sum across rows (i) - column constraint
            @constraint(sudoku, sum(x[i,ind,k] for i in 1:9) == 1)
    end
end

#' Finally, we have the to enforce the constraint that each digit appears once in each of the nine 3x3 sub-grids. Our strategy will be to index over the top-left corners of each 3x3 square with `for` loops, then sum over the squares.

for i = 1:3:7, j = 1:3:7, k = 1:9
    # i is the top left row, j is the top left column
    # We'll sum from i to i+2, e.g. i=4, r=4, 5, 6
    @constraint(sudoku, sum(x[r,c,k] for  r in i:i+2, c in j:j+2) == 1)
end

#' The final step is to add the initial solution as a set of constraints. We'll solve the problem that is in the picture at the start of the notebook. We'll put a `0` if there is no digit in that location.

# The given digits
init_sol = [ 5 3 0 0 7 0 0 0 0;
             6 0 0 1 9 5 0 0 0;
             0 9 8 0 0 0 0 6 0;
             8 0 0 0 6 0 0 0 3;
             4 0 0 8 0 3 0 0 1;
             7 0 0 0 2 0 0 0 6;
             0 6 0 0 0 0 2 8 0;
             0 0 0 4 1 9 0 0 5;
             0 0 0 0 8 0 0 7 9]
for i = 1:9, j = 1:9
    # If the space isn't empty
    if init_sol[i,j] != 0
        # Then the corresponding variable for that digit
        # and location must be 1
        @constraint(sudoku, x[i,j,init_sol[i,j]] == 1)
    end
end

# solve problem
optimize!(sudoku)

# Extract the values of x
x_val = value.(x)
# Create a matrix to store the solution
sol = zeros(Int,9,9)  # 9x9 matrix of integers
for i in 1:9, j in 1:9, k in 1:9
    # Integer programs are solved as a series of linear programs
    # so the values might not be precisely 0 and 1. We can just
    # round them to the nearest integer to make it easier
    if round(Int,x_val[i,j,k]) == 1
        sol[i,j] = k
    end
end
# Display the solution
sol

#' Which is the correct solution:
#' <img src="img/fullsudoku.svg" style="width: 300px; height: auto" alt="Fully Solved Sudoku">