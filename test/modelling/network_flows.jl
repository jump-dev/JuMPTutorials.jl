
using JuMP
using GLPK


G = [
0 100 30  0  0;
0   0 20  0  0;  
0   0  0 10 60;
0  15  0  0 50;
0   0  0  0  0
]

n = size(G)[1]

model = Model(with_optimizer(GLPK.Optimizer))

@variable(model, x[1:n,1:n], Bin)
@constraint(model, [i = 1:n, j = 1:n; G[i,j] == 0], x[i,j] == 0) # Arcs with zero cost are not a part of the path as they do no exist
@constraint(model, [i = 1:n; i != 1 && i != 2], sum(x[i,:]) == sum(x[:,i])) # Flow conservation constraint
@constraint(model, sum(x[1,:]) - sum(x[:,1]) == 1) # Flow coming out of source = 1
@constraint(model, sum(x[2,:]) - sum(x[:,2]) == -1) # Flowing coming out of destination = -1 i.e. Flow entering destination = 1  
@objective(model, Min, sum(G .* x))

optimize!(model)
@show objective_value(model);
@show value.(x);


G = [
6 4 5 0;
0 3 6 0;
5 0 4 3;
7 5 5 5;
]

n = size(G)[1]

model = Model(with_optimizer(GLPK.Optimizer))
@variable(model, x[1:n,1:n], Bin)
@constraint(model, [i = 1:n], sum(x[:,i]) == 1) # One person can only be assigned to one object
@constraint(model, [j = 1:n], sum(x[j,:]) == 1) # One object can only be assigned to one person
@objective(model, Max, sum(G .* x))

optimize!(model)
@show objective_value(model);
@show value.(x);


G = [
0 3 2 2 0 0 0 0 
0 0 0 0 5 1 0 0 
0 0 0 0 1 3 1 0 
0 0 0 0 0 1 0 0 
0 0 0 0 0 0 0 4 
0 0 0 0 0 0 0 2 
0 0 0 0 0 0 0 4 
0 0 0 0 0 0 0 0 
]

n = size(G)[1]

model = Model(with_optimizer(GLPK.Optimizer))

@variable(model, f[1:n,1:n] >= 0)
@constraint(model, [i = 1:n, j = 1:n], f[i,j] <= G[i,j]) # Capacity constraints
@constraint(model, [i = 1:n; i != 1 && i != 8], sum(f[i,:]) == sum(f[:,i])) # Flow conservation contraints
@objective(model, Max, sum(f[1, :]))

optimize!(model)
@show objective_value(model);
@show value.(f);

