
using JuMP
using GLPK
using LinearAlgebra


G = [
    0 100 30  0  0;
    0   0 20  0  0;  
    0   0  0 10 60;
    0  15  0  0 50;
    0   0  0  0  0;
]

n = size(G)[1]

shortest_path = Model(GLPK.Optimizer)

@variable(shortest_path, x[1:n,1:n], Bin)
@constraint(shortest_path, [i = 1:n, j = 1:n; G[i,j] == 0], x[i,j] == 0) # Arcs with zero cost are not a part of the path as they do no exist
@constraint(shortest_path, [i = 1:n; i != 1 && i != 2], sum(x[i,:]) == sum(x[:,i])) # Flow conservation constraint
@constraint(shortest_path, sum(x[1,:]) - sum(x[:,1]) == 1) # Flow coming out of source = 1
@constraint(shortest_path, sum(x[2,:]) - sum(x[:,2]) == -1) # Flowing coming out of destination = -1 i.e. Flow entering destination = 1  
@objective(shortest_path, Min, dot(G, x))

optimize!(shortest_path)
@show objective_value(shortest_path);
@show value.(x);


G = [
    6 4 5 0;
    0 3 6 0;
    5 0 4 3;
    7 5 5 5;
]

n = size(G)[1]

assignment = Model(GLPK.Optimizer)
@variable(assignment, y[1:n,1:n], Bin)
@constraint(assignment, [i = 1:n], sum(y[:,i]) == 1) # One person can only be assigned to one object
@constraint(assignment, [j = 1:n], sum(y[j,:]) == 1) # One object can only be assigned to one person
@objective(assignment, Max, dot(G, y))

optimize!(assignment)
@show objective_value(assignment);
@show value.(y);


G = [
    0 3 2 2 0 0 0 0;
    0 0 0 0 5 1 0 0;
    0 0 0 0 1 3 1 0;
    0 0 0 0 0 1 0 0;
    0 0 0 0 0 0 0 4;
    0 0 0 0 0 0 0 2;
    0 0 0 0 0 0 0 4;
    0 0 0 0 0 0 0 0;
]

n = size(G)[1]

max_flow = Model(GLPK.Optimizer)

@variable(max_flow, f[1:n,1:n] >= 0)
@constraint(max_flow, [i = 1:n, j = 1:n], f[i,j] <= G[i,j]) # Capacity constraints
@constraint(max_flow, [i = 1:n; i != 1 && i != 8], sum(f[i,:]) == sum(f[:,i])) # Flow conservation contraints
@objective(max_flow, Max, sum(f[1, :]))

optimize!(max_flow)
@show objective_value(max_flow);
@show value.(f);

