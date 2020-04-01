#' ---
#' title: Facility Location
#' ---

#' **Originally Contributed by**: Mathieu Tanneau and Alexis Montoison

#'Benchmark instances: http://resources.mpi-inf.mpg.de/departments/d1/projects/benchmarks/UflLib/

#' ## Uncapacitated facility location
#'
#' Problem description
#' * $M=\{1, \dots, m\}$ clients, $N=\{ 1, \dots, n\}$ sites where a facility can be built.

n = 2  # number of facility locations
m = 5  # number of clients

#' * $f_j$: fixed cost of building a facility at site $j$
#' * $c_{i, j}$: cost for serving customer $i$ from facility $j$

# Draw costs
Random.seed!(0)
f = rand(1000:10000, n);
c = rand(0:1000, m, n);

#' ### MILP formulation
#'
#' $$
#' \begin{array}{cl}
#' \min_{x, y} \ \ \ &
#' \sum_{i, j} c_{i, j} x_{i, j} + 
#' \sum_{j} f_{j} y_{j}\\
#' s.t. &
#' \sum_{j} x_{i, j} = 1, \ \ \ \forall i \in M\\
#' & x_{i, j} \leq y_{j}, \ \ \ \forall i \in M, j \in N\\
#' & x_{i, j}, y_{j} \in \{0, 1\}, \ \ \ \forall i \in M, j \in N
#' \end{array}
#' $$

using JuMP
using GLPK
using Cbc

# Create a model
ufl = Model();

#+

# Create our variables
@variable(ufl, y[1:m], Bin);
@variable(ufl, x[1:m, 1:n], Bin);

#+

# Add constraints

# Each client is serve exactly once
@constraint(
    ufl,
    [i in 1:m],
    sum(x[i, j] for j in 1:n) == 1
);

# Fixed cost of opening facilities
@constraint(
    ufl,
    [i in 1:m, j in 1:n],
    x[i, j] <= y[j]
);

#+

# Set objective
F = sum([f[j]*y[j] for j in 1:n]);
C = sum([c[i, j]*x[i, j] for i in 1:m for j in 1:n]);
                
@objective(ufl, Min, F + C);

#+

# Set optimizer
set_optimizer(ufl, with_optimizer(GLPK.Optimizer))

#+

# Solve the uncapacitated facility location problem with GLPK
optimize!(ufl)
println("Optimal value: ", objective_value(ufl))

#+

# Get y and x solutions
xsol = value.(x);
println("Optimal solution x: ", value.(x))
ysol = value.(y);
println("Optimal solution y: ", value.(y))

#+

# relax all binary variables
for var in x
    is_binary(var) && unset_binary(var)
    set_lower_bound(var, 0.0)
    set_upper_bound(var, 1.0)
end

for var in y
    is_binary(var) && unset_binary(var)
    set_lower_bound(var, 0.0)
    set_upper_bound(var, 1.0)
end

#+

# Solve the LP relaxation
optimize!(ufl)
lp_val = objective_value(ufl)
println("Optimal value of relaxed ufl: ", lp_val)

#+

# Get y and x solutions
lp_ysol = value.(y);
println("Optimal solution y: ", value.(y))
lp_xsol = value.(x);
println("Optimal solution x: ", value.(x))

#+

# Set all variables to be binary
for var in x
    set_binary(var)
end

for var in y
    set_binary(var)
end

optimize!(ufl)
mip_val = objective_value(ufl)
println("Optimal value of integer ufl: ", mip_val)

#+

# Integrality gap
(mip_val - lp_val) / mip_val

#' ## Capacitated Facility location

#' * Each client $i$ has a demand $a_{i}$, and each facility has a capacity $q_{j}$

#' $$
#' \begin{array}{cl}
#' \min_{x, y} \ \ \ &
#' \sum_{i, j} c_{i, j} x_{i, j} + 
#' \sum_{j} f_{j} y_{j}\\
#' s.t. &
#' \sum_{j} x_{i, j} = 1, \ \ \ \forall i \in M\\
#' & \sum_{i} a_{i} x_{i, j} \leq q_{j} y_{j}, \ \ \ \forall j \in N\\
#' & x_{i, j}, y_{j} \in \{0, 1\}, \ \ \ \forall i \in M, j \in N
#' \end{array}
#' $$

n = 10  # number of facility locations
m = 30  # number of clients

# Draw costs
Random.seed!(0)
f = rand(1000:10000, n);
c = rand(0:1000, m, n);

# Clients' demands
a = rand(1:10, m);

# Capacities
q = rand(30:40, n);

#+

# Instantiate an empty model
cfl = Model();

#+

# Create variables
y = @variable(cfl, y[1:n], Bin);
x = @variable(cfl, x[1:m, 1:n], Bin);

#+

# set objective
C = sum([c[i, j]*x[i, j] for i in 1:m for j in 1:n])  # demand serving cost
F = sum([f[j]*y[j] for j in 1:n])  # fixed cost

@objective(cfl, Min, C + F);

#+

# Add constraints

# Each client is serve exactly once
ctr_ = @constraint(
    cfl,                             # add constraints to model
    [i in 1:m],                      # there are `m` constraints, indexed by `i`
    sum(x[i, j] for j in 1:n) == 1   # the actual constraint
);

# Capacity constraints
ctr_capacity = @constraint(
    cfl,
    [j in 1:n],
    sum(a[i] * x[i, j] for i in 1:m) <= q[j]*y[j]
);

#+

# Set optimizer
set_optimizer(
    cfl,
    with_optimizer(
        GLPK.Optimizer,
        msg_lev=3,    # verbosity level
        tm_lim=10000  # time limit, in ms
    )
)

#+

# Best solution found so far
println("Optimal value: ", objective_value(cfl))

#+

# Solve the capacitated facility location problem with Cbc
set_optimizer(cfl, with_optimizer(Cbc.Optimizer))
optimize!(cfl)
