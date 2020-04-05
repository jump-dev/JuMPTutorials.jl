#' ---
#' title: Maximum cut problem, linear and semi-definite optimization formulations
#' ---

#' **Originally Contributed by**: Mathieu Besançon

using LinearAlgebra
using SparseArrays
using Test

using JuMP
using GLPK
using LightGraphs
using GraphPlot
import SCS
using Colors: @colorant_str

#' ## The Maximum Cut problem

# TODO explain problem

#' The Integer Linear Formulation

#' $$
#' \begin{align*}
#' \max_{x,z} & \sum_{\forall (i,j) \in E} w_{i,j} z_{ij} \\
#' \text{s.t. } & z_{ij} \leq x_i + x_j \\
#' & z_ij \leq 2 - (x_i + x_j)\\
#' & z_{ij} \in \{0,1\} \forall (i,j) \in E \\
#' & x_{i} \in \{0,1\} \forall i \in V
#' \end{align*}
#' $$

function compute_cut_value(g::LightGraphs.AbstractGraph, w::AbstractMatrix, vertex_subset)
    return sum(w[i,j] for i in vertices(g) for j in neighbors(g, i) if in(i, vertex_subset)  != in(j, vertex_subset))
end

#' The following example graph is taken from https://en.wikipedia.org/wiki/Graph_theory#/media/File:6n-graf.svg
#'

g = SimpleGraph(6)
add_edge!(g, 1, 2)
add_edge!(g, 1, 5)
add_edge!(g, 2, 3)
add_edge!(g, 2, 5)
add_edge!(g, 3, 4)
add_edge!(g, 4, 5)
add_edge!(g, 4, 6);

GraphPlot.gplot(g, nodelabel=1:6)

#' Creating a unit weight matrix

w = spzeros(6, 6)

for e in edges(g)
   (i, j) = Tuple(e)
   w[i,j] = 1
end

#' Computing value for a solution

@test compute_cut_value(g, w, (2, 5, 6)) ≈ 5
@show compute_cut_value(g, w, (2, 5, 6));

#' Building the linear optimization model

n = nv(g)

linear_max_cut = Model(GLPK.Optimizer)

@variable(linear_max_cut, z[1:n,1:n], Bin)
@variable(linear_max_cut, x[1:n], Bin)
@constraint(linear_max_cut, [i = 1:n, j = 1:n; (i, j) in edges(g)], z[i,j] <= x[i] + x[j])
@constraint(linear_max_cut, [i = 1:n, j = 1:n; (i, j) in edges(g)], z[i,j] <= 2 - (x[i] + x[j]))

@objective(linear_max_cut, Max, dot(w, z))

optimize!(linear_max_cut)

@test objective_value(linear_max_cut) ≈ 6.0
@show objective_value(linear_max_cut);

x_linear = value.(x)
@show x_linear;
@show [(i,j) for i in 1:n-1 for j in i+1:n if JuMP.value.(z)[i,j] > 0.5];

#' Visualizing a solution

nodecolor = [colorant"lightseagreen", colorant"orange"]
all_node_colors = [nodecolor[round(Int, xi + 1)]  for xi in x_linear]
GraphPlot.gplot(g, nodelabel=1:6, nodefillc=all_node_colors)

# membership color
nodefillc = nodecolor[membership]
gplot(g, nodefillc=nodefillc)

#' ### Semi-definite formulation

#' The maximum cut problem can also be formulated as a quadratic optimization model.
#' If the solution vector is composed of $\{-1, 1\}$ for belonging to the subset or not.
#' Then, the product $x_i x_j$ is $-1$ if i and j are in different subsets, and 1 otherwise.
#' This implies $1 - x_i x_j$ is $0$ if i and j are in the same subset, and 2 otherwise.
#' Since each pair is counted twice with (i,j) and (j,i), we need to divide it by 4:
#' $\frac{w_{ij}}{4} (1 - x_i x_j)$ is $0$ if i and j are in the same subset, and $z_{ij}$ otherwise.

#' The resulting model is given by:
#' $$
#' \begin{align*}
#' \max_{x} & \frac{w_{ij}}{4} (1 - x_i x_j) \\
#' \text{s.t. } & x_i \in \{-1, 1\} \forall i \in V
#' \end{align*}
#' $$

#' Introducing a matrix variable $Y_{ij} = x_i x_j$,
#' we can equivalently reformulate the above quatratic problem as follows:
#' $$
#' \begin{align*}
#' \max_{x,Y} & \frac{w_{ij}}{4} (1 - Y_{ij}) \\
#' \text{s.t. } & Y_{ii} = 1 \forall i \in V \\
#'              & Y = x x^T
#' \end{align*}
#' $$

#' The constraint $Y = x x^T$ requires $Y$ to be a Positive Semi-Definite matrix
#' of rank one. This optimization problem is fully equivalent to the initial
#' quadratic problem and hard to solve.
#' A possible relaxation is to remove the rank-1, yielding the following problem:
#' $$
#' \begin{align*}
#' \max_{Y} & \frac{w_{ij}}{4} (1 - Y_{ij}) \\
#' \text{s.t. } & Y_{ii} = 1 \forall i \in V \\
#'              & Y \in \mathcal{S}_n^+
#' \end{align*}
#' $$

#' with $\mathcal{S}_n^+$ the set of positive semi-definite matrices.
#' Such model can be implemented in JuMP and solved using an underlying solver
#' which supports semi-definite optimization.

sdp_max_cut = Model(optimizer_with_attributes(SCS.Optimizer, "verbose" => 0))

@variable(sdp_max_cut, Y[1:n,1:n] in PSDCone())
@constraint(sdp_max_cut, [i = 1:n], Y[i,i] == 1)
@objective(sdp_max_cut, Max, 1/4 * sum(w[i,j] * (1 - Y[i,j]) for i in 1:n for j in 1:n))

optimize!(sdp_max_cut)

@test objective_value(linear_max_cut) >= 6.0
@show objective_value(linear_max_cut);

#' Re-computing the vector:
#' $Y$ approximates $x x^T$, we can compute the estimate by randomized rounding.
#' TODO add paper.

F = svd(value.(Y))
xhat_unnormalized = F.U[:,1]
xhat = map(xhat_unnormalized) do v
    (v >= 0) * 1 
end

@show collect(zip(round.(Int, x_linear), xhat))
@test LinearAlgebra.norm1(round.(Int, x_linear) .- xhat) == 0 || LinearAlgebra.norm1(round.(Int, x_linear) .- xhat) == n

#' ### Representing the SDP approximated solution

nodecolor = [colorant"lightseagreen", colorant"orange"]
all_node_colors = [nodecolor[xi + 1] for xi in xhat]
GraphPlot.gplot(g, nodelabel=1:6, nodefillc=all_node_colors)
