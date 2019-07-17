#' ---
#' title: Conic Programming
#' ---

#' **Originally Contributed by**: Arpit Bhatia

#' This tutorial is aimed at providing a simplistic introduction to conic programming using JuMP.

#' # What is a Cone?
#' A subset $C$ of a vector space $V$ is a cone if $\forall x \in C$ and positive scalars $\alpha$, 
#' the product $\alpha x \in C$. A cone C is a convex cone if $\alpha x + \beta y \in C$, 
#' for any positive scalars $\alpha, \beta$, and any $x, y \in C$.

#' # Conic Programming
#' Conic programming problems are convex optimization problems in which a convex function is minimized
#' over the intersection of an affine subspace and a convex cone. 
#' An example of a conic-form minimization problems, in the primal form is:

#' $$
#' \begin{align}
#' & \min_{x \in \mathbb{R}^n} & a_0^T x + b_0 \\
#' & \;\;\text{s.t.} & A_i x + b_i & \in \mathcal{C}_i & i = 1 \ldots m
#' \end{align}
#' $$

#' The corresponding dual problem is:

#' $$
#' \begin{align}
#' & \max_{y_1, \ldots, y_m} & -\sum_{i=1}^m b_i^T y_i + b_0 \\
#' & \;\;\text{s.t.} & a_0 - \sum_{i=1}^m A_i^T y_i & = 0 \\
#' & & y_i & \in \mathcal{C}_i^* & i = 1 \ldots m
#' \end{align}
#' $$

#' where each $\mathcal{C}_i$ is a closed convex cone and $\mathcal{C}_i^*$ is its dual cone.

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

#' ### Example: Euclidean Projection on a Hyperplane
#' For a given point $u_{0}$ and a set $K$, we refer to any point $u \in K$ 
#' which is closest to $u_{0}$ as a projection of $u_{0}$ on $K$. 
#' The projection of a point $u_{0}$ on a hyperplane $K = \{u | p' \cdot u = q\}$ is given by

#' $$
#' \begin{align*}
#' \min && ||u - u_{0}|| \\
#' s.t. && p' \cdot u = q 
#' \end{align*}
#' $$

u0 = rand(10)
p = rand(10)
q = rand();

#' We can model the above problem as the following conic program:

#' $$
#' \begin{align*}
#' \min t \\
#' \text { s.t. }  p' \cdot u = q \\
#' (t, u - u_{0}) \in Q^{n+1}
#' \end{align*}
#' $$

#' On comparing this with the primal form of a conic problem we saw above,

#' $$
#' \begin{align*}
#' x = (t , u) \\
#' a_0 = e_1 \\
#' b_0 = 0 \\
#' A_1 = (0, p) \\
#' b_1 = -q \\
#' C_1 = \mathbb{R}_- \\
#' A_2 = 1 \\
#' b_2 = -(0, u_0) \\
#' C_2 = Q^{n+1} 
#' \end{align*}
#' $$

#' Thus, we can obtain the dual problem as:

#' $$
#' \begin{align*}
#' \max q  y_1 + (0, u_0)^T y_2 \\
#' \text { s.t. } e_1 - (0,p)^T y_1 - y_2 = 0 \\
#' y_1 \in ? \\
#' y_2 \in Q^{n+1} 
#' \end{align*}
#' $$

model = Model(with_optimizer(ECOS.Optimizer, printlevel = 0))
@variable(model, u[1:10])
@variable(model, t)
@objective(model, Min, t)
@constraint(model, [t, (u - u0)...] in SecondOrderCone())
@constraint(model, u' * p == q) 
optimize!(model)

#+

@show value.(u);

#' We can also have an equivalent formulation using a Rotated Second-Order Cone:

#' $$
#' \begin{align*}
#' \min t \\
#' \text { s.t. }  p' \cdot u = q \\
#' (t, 1/2, u - u_{0})\in Q_r^{n+2}
#' \end{align*}
#' $$

model = Model(with_optimizer(ECOS.Optimizer, printlevel = 0))
@variable(model, u[1:10])
@variable(model, t)
@objective(model, Min, t)
@constraint(model, [t, 0.5, (u - u0)...] in RotatedSecondOrderCone())
@constraint(model, u' * p == q) 
optimize!(model)

#+

@show value.(u);

#' The difference here is that the objective in the case of the Second-Order Cone is $||u - u_{0}||_2$,
#' while in the case of a Rotated Second-Order Cone is $||u - u_{0}||_2^2$.
#' However, the value of x is the same for both.

#' ## Exponential Cone

#' An Exponential Cone is a set of the form:

#' $$
#' K_{exp} = \{ (x,y,z) \in \mathbb{R}^3 : y \exp (x/y) \le z, y > 0 \}
#' $$

#' It is represented in JuMP using the MOI set `ExponentialCone`.

#' ### Example: Entropy Maximization
#' As the name suggests, the entropy maximization problem consists of maximizing the entropy function,
#' $H(x) = -x\log{x}$ subject to linear inequality constraints.

#' $$
#' \begin{align*}
#' \max - \sum_{i=1}^n x_i \log x_i \\
#' \text { s.t. } \mathbf{1}' x = 1 \\
#' Ax \leq b
#' \end{align*}
#' $$

#' We can model this problem using an exponential cone by using the following transformation:

#' $$
#' t\leq -x\log{x} \iff t\leq x\log(1/x)  \iff (1, x, t) \in K_{exp}
#' $$

#' Thus, our problem becomes,

#' $$
#' \begin{align*}
#' \max 1^Tt \\
#' \text { s.t. } Ax \leq b \\
#' 1^T x = 1 \\
#' (1, x_i, t_i) \in K_{exp} && \forall i = 1 \ldots n
#' \end{align*}
#' $$

# Cannot use the exponential cone directly in JuMP, hence we import MOI to specify the set.
using MathOptInterface
const MOI = MathOptInterface

n = 15;
m = 10;
A = randn(m, n); 
b = rand(m, 1);

model = Model(with_optimizer(ECOS.Optimizer, printlevel = 0))
@variable(model, t[1:n])
@variable(model, x[1:n])
@objective(model, Max, sum(t))
@constraint(model, sum(x) == 1)
@constraint(model, A * x .<= b )
@constraint(model, con[i = 1:n], [1, x[i], t[i]] in MOI.ExponentialCone())

optimize!(model);

#+

@show objective_value(model);

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

#+

@show objective_value(model);

#' # Other Cones and Functions
#' For other cones supported by JuMP, check out the 
#' [MathOptInterface Manual](http://www.juliaopt.org/MathOptInterface.jl/dev/apimanual/#Standard-form-problem-1).
#' A good resource for learning more about functions which can be modelled using cones is the 
#' MOSEK Modeling Cookbook[[1]](#c1).

#' ### References
#' <a id='c1'></a>
#' 1. MOSEK Modeling Cookbook — MOSEK Modeling Cookbook 3.1. Available at: https://docs.mosek.com/modeling-cookbook/index.html.