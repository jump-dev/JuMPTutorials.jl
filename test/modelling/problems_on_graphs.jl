
using JuMP
using GLPK
using GraphPlot 
using LightGraphs
using Colors


G = [
0 1 0 0 0 0;
1 0 1 1 0 0;
0 1 0 0 1 1;
0 1 0 0 1 0;
0 0 1 1 0 0;
0 0 1 0 0 0
]

g = SimpleGraph(G)
       
gplot(g)


vertex_cover = Model(with_optimizer(GLPK.Optimizer))

@variable(vertex_cover, y[1:nv(g)], Bin)
@constraint(vertex_cover, [i = 1:nv(g), j = 1:nv(g); G[i,j] == 1], y[i] + y[j] >= 1)
@objective(vertex_cover, Min, sum(y))

optimize!(vertex_cover)
@show value.(y);


membership = convert(Array{Int},value.(y)) # Change to Int 
membership = membership + ones(Int, nv(g)) # Make the color groups one indexed
nodecolor = [colorant"red", colorant"blue"] # Blue to represent vertices in the cover
nodefillc = nodecolor[membership]
gplot(g, nodefillc = nodefillc)


G = [
0 1 0 0 0 0 0 0 0 1 0 ;
1 0 1 0 0 0 0 0 0 0 1;
0 1 0 1 0 1 0 0 0 0 0;
0 0 1 0 1 0 0 0 0 0 0;
0 0 0 1 0 1 0 0 0 0 0;
0 0 1 0 1 0 1 0 0 0 0;
0 0 0 0 0 1 0 1 0 0 0;
0 0 0 0 0 0 1 0 1 0 1;
0 0 0 0 0 0 0 1 0 1 1;
1 0 0 0 0 0 0 0 1 0 1;
0 1 0 0 0 0 0 1 1 1 0
]

g = SimpleGraph(G)
       
gplot(g)


dominating_set = Model(with_optimizer(GLPK.Optimizer))

@variable(dominating_set, x[1:nv(g)], Bin)
@constraint(dominating_set, [i = 1:nv(g)], sum(G[i,:] .* x) >= 1)
@objective(dominating_set, Min, sum(x))

optimize!(dominating_set)
@show value.(x);


membership = convert(Array{Int},value.(x)) # Change to Int 
membership = membership + ones(Int, nv(g)) # Make the color groups one indexed
nodecolor = [colorant"red", colorant"blue"] # Blue to represent vertices in the set
nodefillc = nodecolor[membership]
gplot(g, nodefillc = nodefillc)


G = [
0 0 0 0 1 0 0 0;
0 0 0 0 0 1 0 0;
0 0 0 0 0 0 1 0;
0 0 0 0 0 0 0 1;
1 0 0 0 0 1 0 1;
0 1 0 0 1 0 1 0;
0 0 1 0 0 1 0 1;
0 0 0 1 1 0 1 0;
]

g = SimpleGraph(G)
       
gplot(g)


matching = Model(with_optimizer(GLPK.Optimizer))

@variable(matching, m[i = 1:nv(g), j = 1:nv(g)], Bin)
@constraint(matching, [i = 1:nv(g)], sum(m[i,:]) <= 1)
@constraint(matching, [i = 1:nv(g), j = 1:nv(g); G[i,j] == 0], m[i,j] == 0)
@constraint(matching, [i = 1:nv(g), j = 1:nv(g)], m[i,j] == m[j,i])
@objective(matching, Max, sum(m))

optimize!(matching)
@show value.(m);


G = [
0 1 0 0 1 1 0 0 0 0;
1 0 1 0 0 0 1 0 0 0;
0 1 0 1 0 0 0 1 0 0;
0 0 1 0 1 0 0 0 1 0;
1 0 0 1 0 0 0 0 0 1;
1 0 0 0 0 0 1 0 0 1;
0 1 0 0 0 1 0 1 0 0;
0 0 1 0 0 0 1 0 1 0;
0 0 0 1 0 0 0 1 0 1;
0 0 0 0 1 1 0 0 1 0;
]

g = SimpleGraph(G)
       
gplot(g)


k = nv(g)

k_colouring = Model(with_optimizer(GLPK.Optimizer))

@variable(k_colouring, z[1:k], Bin)
@variable(k_colouring, c[1:nv(g),1:k], Bin)
@constraint(k_colouring, [i = 1:nv(g)], sum(c[i,:]) == 1)
@constraint(k_colouring, [i = 1:nv(g), j = 1:nv(g), l = 1:k; G[i,j] == 1], c[i,l] + c[j,l] <= 1)
@constraint(k_colouring, [i = 1:nv(g), l = 1:k], c[i,l] <= z[l])

@objective(k_colouring, Min, sum(z))

optimize!(k_colouring)
@show value.(z);
@show value.(c);


c = value.(c)
membership = zeros(nv(g))
for i in 1:nv(g)
    for j in 1:k
        if c[i,j] == 1
            membership[i] = j
            break
        end
    end
end
membership = convert(Array{Int},membership)

nodecolor = distinguishable_colors(nv(g), colorant"green")
nodefillc = nodecolor[membership]
gplot(g, nodefillc = nodefillc)

