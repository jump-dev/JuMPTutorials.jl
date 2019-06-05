#' ---
#' title: Variables, Constraints and Objective
#' author: Arpit Bhatia
#' ---

#' While the last tutorial introduced you to basics of of JuMP code, this tutorial will go in depth focusing on how to work 
#' with different parts of a JuMP program. 

#+ echo = false; results = "hidden"
using JuMP
model = Model()

#' # Variables

#' ## Variable Bounds
#' All of the variables we have created till now have had a bound. We can also create a free variable.

@variable(model, freex)

#' While creating a variable, instead of using the <= and >= syntax, we can also use the `lower_bound` and `upper_bound` keyword arguments.

@variable(model, altx, lower_bound=1, upper_bound=2)

#' We can query whether a variable has a bound using the `has_lower_bound` and `has_upper_bound` functions. The values of the bound can be obtained 
#' using the `lower_bound` and `upper_bound` functions.

has_upper_bound(altx)

#'

upper_bound(altx)

#' Note querying the value of a bound that does not exist will result in an error.
#+ tangle = false

lower_bound(freex)

#' JuMP also allows us to change the bounds on variable. We will learn this in the problem modification tutorial. 

#' ## Containers
#' We have already seen how to add a single variable to a model using the `@variable` macro. Let's now look at more ways to add 
#' variables to a JuMP model. JuMP provides data structures for adding collections of variables to a model. These data 
#' structures are reffered to as Containers and are of three types - `Arrays`, `DenseAxisArrays`, and `SparseAxisArrays`.

#' ### Arrays
#' JuMP arrays are created in a similar syntax to Julia arrays with the addition of specifying that the indices start with 1. If
#' we do not tell JuMP that the indices start at 1, it will create a DenseAxisArray instead.

@variable(model, a[1:2, 1:2])

#' An n-dimensional variable $x \in {R}^n$ having a bound $l \preceq x \preceq u$ ($l, u \in {R}^n$) is added in the following 
#' manner.

n = 10
l = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10]
u = [10; 11; 12; 13; 14; 15; 16; 17; 18; 19]

@variable(model, l[i] <= x[i=1:n] <= u[i])

#' Note that while working with Containers, we can also create variable bounds depending upon the indices

@variable(model, y[i=1:2, j=1:2] >= 2i + j)

#' ### DenseAxisArrays
#' DenseAxisArrays are used when the required indices are not one-based integer ranges. The syntax is similar except with an 
#' arbitrary vector as an index as opposed to a one-based range.

#' An example where the indices are integers but do not start with one.

@variable(model, z[i=2:3, j=1:2:3] >= 0)

#' Another example where the indices are an arbitrary vector.

@variable(model, w[1:5,["red","blue"]] <= 1)

#' ### SparseAxisArrays
#' SparseAxisArrays are created when the indices do not form a rectangular set. For example, this applies when indices have a 
#' dependence upon previous indices (called triangular indexing). 

@variable(model, u[i=1:3, j=i:5])

#' We can also conditionally create variables by adding a comparison check that depends upon the named indices and is separated 
#' from the indices by a semi-colon (;).

@variable(model, v[i=1:9; mod(i, 3)==0])

#' ## Variable Types

#' The last arguement to the `@variable` macro is usually the variable type. Here we'll look at how to specifiy he variable type.

#' ### Integer Variables
#' Integer optimization variables are constrained to the set $x \in {Z}$
#+ eval = false; tangle = false

@variable(model, intx, Int)

#' or

@variable(model, intx, integer=true)

#' ### Binary Variables
#' Binary optimization variables are constrained to the set $x \in \{0, 1\}$. 
#+ eval = false; tangle = false

@variable(model, binx, Bin)

#' or

@variable(model, binx, binary=true)

#' ### Semidefinite variables
#' JuMP also supports modeling with semidefinite variables. A square symmetric matrix X is positive semidefinite if all eigenvalues 
#' are nonnegative.

@variable(model, psdx[1:2, 1:2], PSD)

#' We can also impose a weaker constraint that the square matrix is only symmetric (instead of positive semidefinite) as follows:

@variable(model, symx[1:2, 1:2], Symmetric)

#' # Constraints
#+ echo = false; results = "hidden"

model = Model()
@variable(model, x)
@variable(model, y)
@variable(model, z[1:10])

#' ## Constraint References
#' While calling the `@constraint` macro, we can also set up a constraint reference. Such a refference is useful for obtaining
#' additional information about the constraint such as its dual.

@constraint(model, con, x <= 4)

#' ## Containers
#' Just as we had containers for variables, JuMP also provides `Arrays`, `DenseAxisArrays`, and `SparseAxisArrays` for storing
#' collections of constraints. Examples for each container type are given below.

#' ### Arrays

@constraint(model, acon[i = 1:3], i * x <= i + 1)

#' ### DenseAxisArrays

@constraint(model, dcon[i = 1:2, j = 2:3], i * x <= j + 1)

#' ### SparseAxisArrays

@constraint(model, scon[i = 1:2, j = 1:2; i != j], i * x <= j + 1)

#' ## Constraints in a Loop
#' We can add constraints using regular Julia loops

for i in 1:3
    @constraint(model, 6*x + 4*y >= 5*i)
end

#' or use for each loops inside the `@constraint` macro

@constraint(model, conRef3[i in 1:3], 6*x + 4*y >= 5*i)

#' We can also created constraints such as ``$\sum _{i = 1}^{10} z_i \leq 1$``

@constraint(model, sum(z[i] for i in 1:10) <= 1)

#' # Objective
#' While the recommended way to set the objective is with the @objective macro, the functions `set_objective_sense` and 
#' `set_objective_function` provide an equivalent lower-level interface.

using GLPK

mymodel = Model(with_optimizer(GLPK.Optimizer))
@variable(mymodel, x >= 0)
@variable(mymodel, y >= 0)
set_objective_sense(mymodel, MOI.MIN_SENSE)
set_objective_function(mymodel, x + y)

optimize!(mymodel)
       
@show objective_value(mymodel)

#' To query the objective function from a model, we use the `objective_sense`, `objective_function`, and `objective_function_type`
#' functions.

objective_sense(mymodel)

#'

objective_function(mymodel)

#'

objective_function_type(mymodel)

#' # Vectorized Constraints and Objective
#' We can also add constraints and objective to JuMP using vectorized linear algebra. We'll illustrate this by solving an LP in
#' standard form i.e.

#' $$
#' \begin{align*}
#' \min && c^T x \\
#' \text{subject to} && A x = b \\
#' && x \succeq 0 \\
#' && x \in \mathbb{R}^n \\
#' \end{align*}
#' $$


vectormodel = Model(with_optimizer(GLPK.Optimizer))

A= [ 1 1 9 5;
     3 5 0 8;
     2 0 6 13]

b = [7; 3; 5]

c = [1; 3; 5; 2]

@variable(vectormodel, x[1:4] >= 0)
@constraint(vectormodel, A * x .== b)
@objective(vectormodel, Min, c' * x)

optimize!(vectormodel)

@show objective_value(vectormodel)
