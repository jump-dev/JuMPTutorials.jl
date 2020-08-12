
using GLPK
using JuMP
using LinearAlgebra

# N-Queens
N = 8

model = Model(GLPK.Optimizer);


@variable(model, x[i=1:N, j=1:N], Bin)


# There must be exactly one queen in a given row/column
for i=1:N
    @constraint(model, sum(x[i, :]) == 1)
    @constraint(model, sum(x[:, i]) == 1)
end

# There can only be one queen on any given diagonal
for i in -(N-1):(N-1)
    @constraint(model, sum(diag(x,i)) <= 1)
    @constraint(model, sum(diag(reverse(x,dims=1), i)) <=1)
end


optimize!(model)


solution = convert.(Int,value.(x))



