#' ---
#' title: Conic Programming
#' author: Arpit Bhatia
#' ---

#' This tutorial is aimed at providing a simplistic introduction to conic programming using JuMP.

#' # What is a Cone?
#' A subset $C$ of a vector space $V$ is a cone if $\forall x \in C$ and positive scalars $\alpha$, 
#' the product $\alpha x \in C$. A cone C is a convex cone if $\alpha x + \beta y \in C$, 
#' for any positive scalars $\alpha, \beta$, and any $x, y \in C$.

#' # Conic Programming
#' Conic programming problems are convex optimization problems in which a convex function is minimized
#' over the intersection of an affine subspace and a convex cone. 
#' A primal-dual pair of cone optimization problems is illustrated below.

#' $$
#' {\qquad \begin{aligned} 
#' & \operatorname{minimize} \hspace{0.25cm} c^{T} x & \text { maximize }-b^{T} y \\ 
#' & \text { s.t. }  A x+s=b & \text { s.t. }-A^{T} y+r=c \\ 
#' &(x, s) \in \mathbb{R}^{n} \times \mathcal{K} &(r, y) \in\{0\}^{n} \times \mathcal{K}^{*} \end{aligned}}
#' $$

#' Here $x \in \mathbb{R}^{n}$ and $s \in \mathbb{R}^{m}$ (with $n \leq m )$ are the primal variables, 
#' and $r \in \mathbb{R}^{n}$ and $y \in \mathbb{R}^{m}$ are the dual variables We refer to $x$ as the 
#' primal variable, $s$ as the primal slack variable, $y$ as the dual variable, and $r$ as the dual residual. 
#' The set $\mathcal{K}$ is a nonempty, closed, convex cone with dual cone $\mathcal{K}^{*},$ and $\{0\}^{n}$
#' is the dual cone of $\mathbb{R}^{n},$ so the cones $\mathbb{R}^{n} \times \mathcal{K}$ and $\{0\}^{n} \times
#' \mathcal{K}^{*}$ are duals of each other. The problem data are $A \in \mathbb{R}^{m \times n}, 
#' b \in \mathbb{R}^{m}, c \in \mathbb{R}^{n},$ and the cone $\mathcal{K}$. 
#' (We consider all vectors to be column vectors.)

#' # Some of the Types of Cones Supported by JuMP 

using JuMP
using ECOS
using CSDP

#' By this point we have used quite a few different solvers. 
#' To find out all the different solvers and their supported problem types, check out the 
#' [solver table](http://www.juliaopt.org/JuMP.jl/v0.19.0/installation/#Getting-Solvers-1) in the docs.

#' ## Second-Order Cone
#' The Second-Order Cone (or Lorenz Cone) of dimension $n$ is of the form:

#' $$
#' Q^n = \{ (t,x) \in \mathbb{R}^\mbox{n} : t \ge ||x||_2 \}
#' $$

#' A Second-Order Cone rotated by $\pi/4$ in the $(x_1,x_2)$ plane is called a Rotated Second-Order Cone.
#' It is of the form:

#' $$
#' Q_r^n = \{ (t,u,x) \in \mathbb{R}^\mbox{n} : 2tu \ge ||x||_2^2, t,u \ge 0 \}
#' $$

#' These cones are represented in JuMP using the MOI sets `SecondOrderCone` and `RotatedSecondOrderCone`.

#' ### Example: Euclidean Norm
#' We can model the problem of finding the Euclidean norm(L2 norm) of a vector $x$
#' as the following conic program:

#' $$
#' \begin{align*}
#' \| x \|_2 = \min t \\
#' \text { s.t. } (t, x) \in Q^{n+1}
#' \end{align*}
#' $$

#+ results = "hidden"

x = [1 1 1 1 1 1 1 1 1]
model = Model(with_optimizer(ECOS.Optimizer, printlevel = 0))
@variable(model, t)
@objective(model, Min, t)
@constraint(model, [t, x...] in SecondOrderCone())

optimize!(model)

#'

objective_value(model)

#' An equivalent formulation using a Rotated Second-Order Cone is the following:

#' $$
#' \begin{align*}
#' \| x \|_2^2 = \min t \\
#' \text { s.t. } (1/2, t, x)\in Q_r^{n+2}
#' \end{align*}
#' $$

#+ results = "hidden"

x = [1 1 1 1 1 1 1 1 1]
model = Model(with_optimizer(ECOS.Optimizer, printlevel = 0))
@variable(model, t)
@objective(model, Min, t)
@constraint(model, [t, 0.5, x...] in RotatedSecondOrderCone())

optimize!(model)

#'

objective_value(model)

#' ## Positive Semidefinite Cone
#' The set of Positive Semidefinite Matrices of dimension $n$ form a cone in $\mathbb{R}^n$.
#' We write this set mathematically as 

#' $$
#' \mathcal{S}_{+}^n = \{ X \in \mathcal{S}^n \mid z^T X z \geq 0, \: \forall z\in \mathbb{R}^n \}.
#' $$

#' A PSD cone is represented in JuMP using the MOI sets 
#' `PositiveSemidefiniteConeTriangle` (for upper triangle of a PSD matrix) and
#' `PositiveSemidefiniteConeSquare` (for a complete PSD matrix). 
#' However, it is prefferable to use the `PSDCone` shortcut as illustrated below.

#' ### Example: Largest Eigenvalue of a Symmetric Matrix
#' Suppose $A$ has eigenvalues $\lambda_{1} \geq \lambda_{2} \ldots \geq \lambda_{n}$. 
#' Then the matrix $t I-A$ has eigenvalues $t-\lambda_{1}, t-\lambda_{2}, \ldots, t-\lambda_{n}$. 
#' Note that $t I-A$ is PSD exactly when all these eigenvalues are non-negative, 
#' and this happens for values $t \geq \lambda_{1} .$ 
#' Thus, we can model the problem of finding the largest eigenvalue of a symmetric matrix as:

#' $$
#' \begin{align*}
#' \lambda_{1} = \max t \\
#' \text { s.t. } t I-A \succeq 0
#' \end{align*}
#' $$

#+ results = "hidden"

using LinearAlgebra

A = [3 2 4;
     2 0 2;
     4 2 3]

model = Model(with_optimizer(CSDP.Optimizer, printlevel = 0))
@variable(model, t)
@objective(model, Min, t)
@constraint(model, t .* Matrix{Float64}(I, 3, 3) - A in PSDCone())

optimize!(model)

#'

objective_value(model)

#' ## Exponential Cone

#' An Exponential Cone is a set of the form:

#' $$
#' K_{exp} = \{ (x,y,z) \in \mathbb{R}^3 : y \exp (x/y) \le z, y > 0 \}
#' $$

#' It is represented in JuMP using the MOI set `ExponentialCone`.

#' ### Example: Minimize a Natural Logarithm

#' Suppose we want an objective function as the natural log of a variable $x$.
#' We can model this as:

#' $$
#' \begin{align*}
#' \min \log{x} = \max t \\
#' \text { s.t. } (x, 1, t) \in K_{exp} \\
#' x \geq 0
#' \end{align*}
#' $$

#+ results = "hidden"

# Cannot use the exponential cone directly in JuMP, hence we import MOI to specify the set.
using MathOptInterface
const MOI = MathOptInterface

x = 7.5
model = Model(with_optimizer(ECOS.Optimizer, printlevel = 0))
@variable(model, t)
@objective(model, Max, t)
@constraint(model, [t, 1, x] in MOI.ExponentialCone())

optimize!(model);

#'

objective_value(model)

#' # Other Cones and Functions
#' For other cones supported by JuMP, check out the 
#' [MathOptInterface Manual](http://www.juliaopt.org/MathOptInterface.jl/dev/apimanual/#Standard-form-problem-1).
#' A good resource for learning more about functions which can be modelled using cones is the 
#' [MOSEK Modeling Cookbook](https://docs.mosek.com/modeling-cookbook/index.html).