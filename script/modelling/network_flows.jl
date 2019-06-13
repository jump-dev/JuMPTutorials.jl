#' ---
#' title: Network Flows
#' author: Arpit Bhatia
#' ---

#' In graph theory, a flow network (also known as a transportation network) is a directed graph where 
#' each edge has a capacity and each edge receives a flow. The amount of flow on an edge cannot exceed the capacity of the edge. 
#' Often in operations research, a directed graph is called a network, the vertices are called nodes and the edges are called arcs. 
#' A flow must satisfy the restriction that the amount of flow into a node equals the amount of flow out of it, 
#' unless it is a source, which has only outgoing flow, or sink, which has only incoming flow. 
#' A network can be used to model traffic in a computer network, circulation with demands, fluids in pipes, 
#' currents in an electrical circuit, or anything similar in which something travels through a network of nodes.

using JuMP
using GLPK

#' # The Shortest Path Problem
#' Suppose that each arc $(i, j)$ of a graph is assigned a scalar cost $a_{i,j}$, and 
#' suppose that we define the cost of a forward path to be the sum of the costs of its arcs. 
#' Given a pair of nodes, the shortest path problem is to find a forward path that connects these nodes and has minimum cost.

#' $$
#' \begin{align*}
#' \min && \sum_{\forall e(i,j) \in E} a_{i,j} \times x_{i,j} \\
#' s.t. && b(i) = \sum_j x_{ij} - \sum_k x_{ki} = \begin{cases}
#' 1 &\mbox{if $i$ is the starting node,} \\
#' -1 &\mbox{if $i$ is the ending node,} \\
#' 0 &\mbox{otherwise.} \end{cases} \\
#' && x_{e} \in \{0,1\} && \forall e \in E
#' \end{align*}
#' $$

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
@constraint(model, con[i = 1:n; i!=1 && i!=2], sum(x[i,:]) == sum(x[:,i]))
@constraint(model, con2[i = 1:n, j=1:n; G[i,j]==0], x[i,j] == 0)
@constraint(model, sum(x[1,:]) - sum(x[:,1]) == 1)
@constraint(model, sum(x[2,:]) - sum(x[:,2]) == -1)
@objective(model, Min, sum(G .* x))

optimize!(model)
@show objective_value(model)
@show value.(x)

#' # The Assignment Problem
#' Suppose that there are $n$ persons and $n$ objects that we have to match on a one-to-one basis. 
#' There is a benefit or value $a_{i,j}$ for matching person $i$ with object $j$, and 
#' we want to assign persons to objects so as to maximize the total benefit. 
#' There is also a restriction that person $i$ can be assigned to object $j$ only if $(i, j)$ belongs to a given set of pairs $A$. 
#' Mathematically, we want to find a set of person-object pairs $(1, j_{1}),..., (n, j_{n})$ from $A$ such that 
#' the objects $j_{1},...,j_{n}$ are all distinct, and the total benefit $\sum_{i=1}^{x} a_{ij_{i}}$ is maximized.

#' $$
#' \begin{align*}
#' \max && \sum_{(i,j) \in A} a_{i,j} \times x_{i,j} \\
#' s.t. && \sum_{\{j|(i,j) \in A\}} x_{i,j} = 1 && \forall i = \{1,2....n\} \\
#' && \sum_{\{i|(i,j) \in A\}} x_{i,j} = 1 && \forall j = \{1,2....n\} \\
#' && x_{i,j} \in \{0,1\} && \forall (i,j) \in \{1,2...k\}
#' \end{align*}
#' $$

G = [
6 4 5 0;
0 3 6 0;
5 0 4 3;
7 5 5 5;
]

n = size(G)[1]

model = Model(with_optimizer(GLPK.Optimizer))
@variable(model, x[1:n,1:n], Bin)
@constraint(model, [i=1:n], sum(x[:,i]) == 1)
@constraint(model, [j=1:n], sum(x[j,:]) == 1)
@objective(model, Max, sum(G .* x))

optimize!(model)
@show objective_value(model)
@show value.(x)

#' # The Max-Flow Problem
#' In the max-flow problem, we have a graph with two special nodes: the $source$, denoted by $s$, and the $sink$, denoted by $t$. 
#' The objective is to move as much flow as possible from $s$ into $t$ while observing the capacity constraints.

#' $$
#' \begin{align*}
#' \max && \sum_{v:(s,v) \in E} f(s,v) \\
#' s.t. && \sum_{u:(u,v) \in E} f(u,v)  = \sum_{w:(v,w) \in E} f(v,w) && \forall v \in V - \{s,t\} \\
#' && f(u,v) \leq c(u,v) && \forall (u,v) \in E \\
#' && f(u,v) \geq 0 && \forall (u,v) \in E 
#' \end{align*}
#' $$

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

@variable(model, f[1:n,1:n] >=0)
@constraint(model, capacity[i = 1:n, j=1:n], f[i,j] <= G[i,j])
@constraint(model, flow[i = 1:n; i!=1 && i!=8], sum(f[i,:]) == sum(f[:,i]))
@objective(model, Max, sum(f[1, :]))

optimize!(model)
@show objective_value(model)
@show value.(f)