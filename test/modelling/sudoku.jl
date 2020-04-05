
using JuMP
using GLPK


# Create a model
sudoku = Model(GLPK.Optimizer)

# Create our variables
@variable(sudoku, x[i=1:9, j=1:9, k=1:9], Bin);


for i = 1:9, j = 1:9  # Each row and each column
    # Sum across all the possible digits
    # One and only one of the digits can be in this cell, 
    # so the sum must be equal to one
    @constraint(sudoku, sum(x[i,j,k] for k in 1:9) == 1)
end


for ind = 1:9  # Each row, OR each column
    for k = 1:9  # Each digit
        # Sum across columns (j) - row constraint
        @constraint(sudoku, sum(x[ind,j,k] for j in 1:9) == 1)
        # Sum across rows (i) - column constraint
            @constraint(sudoku, sum(x[i,ind,k] for i in 1:9) == 1)
    end
end


for i = 1:3:7, j = 1:3:7, k = 1:9
    # i is the top left row, j is the top left column
    # We'll sum from i to i+2, e.g. i=4, r=4, 5, 6
    @constraint(sudoku, sum(x[r,c,k] for  r in i:i+2, c in j:j+2) == 1)
end


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

