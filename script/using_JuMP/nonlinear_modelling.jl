#' ---
#' title: Nonlinear Modelling
#' ---

#' **Originally Contributed by**: Arpit Bhatia

#' This tutorial provides a breif introduction to nonlinear modelling in JuMP.
#' For more details and specifics, visit the [JuMP docs](http://www.juliaopt.org/JuMP.jl/stable/nlp/).  

#' # Nonlinear Programs
#' While we have already seen examples of linear, quadratic and conic programs, 
#' JuMP also supports other general smooth nonlinear (convex and nonconvex) optimization problems.

#' A JuMP model object can contain a mix of linear, quadratic, and nonlinear contraints or objective functions.
#' Thus, a model object for a nonlinear program is constructed in the same way as before.

using JuMP, Ipopt
model = Model(with_optimizer(Ipopt.Optimizer));

#' ### Variables
#' Variables are modelled using the `@variable` macro as usual and 
#' a starting point may be provided by using the `start` keyword argument

@variable(model, x, start = 4)
@variable(model, y, start = -9.66);

#' ### Parameters
#' Only in the case of nonlinear models, JuMP offers a syntax for "parameter" objects 
#' which can refer to a numerical value.

@NLparameter(model, p == 0.003); # Providing a starting value is necessary for parameters
@NLparameter(model, l[i = 1:10] == 4 - i); # A collection of parameters

#' The `value` and `set_value` functions are used to query and update the value of a parameter respectively.

value(l[1])

#+

set_value(l[1], -4)
value(l[1])

#' Parameters are useful since it's faster to modify a model in-place by changing the value of the parameter
#' compared to creating an entirely new model object.

#' ### Expressions
#' JuMP also supports the creation of arithmetic expressions which can then be inserted into
#' constraints, the objective and other expressions.

@NLexpression(model, expr_1, sin(x))
@NLexpression(model, expr_2, asin(expr_1)); # Inserting one expression into another

#' There are some [syntax rules](https://pkg.julialang.org/docs/JuMP/DmXqY/0.19.2/nlp/#Syntax-notes-1) 
#' which must be followed while writing a nonlinear expression. 

#' Note that JuMP also supports linear and quadratic expression. 
#' You can find out more about this functionality in the [docs](https://pkg.julialang.org/docs/JuMP/DmXqY/0.19.2/expressions/).

#' ### Nonlinear Objectives and Constraints
#' Nonlinear objectives and constraints are specified by using the `@NLobjective` and `@NLconstraint` macros.

@NLconstraint(model, exp(x) + y^4 <= 0)
@NLobjective(model, Min, tan(x) + log(y))

#' ### User-defined Functions
#' In addition to supporting a library of built-in functions, 
#' JuMP supports the creation of user-defined nonlinear functions to use within nonlinear expressions.
#' The `register` function is used to enable this functionality.

my_function(a,b) = (a * b)^-6 + (b / a)^3
register(model, :my_function, 2, my_function, autodiff = true)

#' The arguements to the function are:
#' - model for which the function is being registered
#' - Julia symbol object corresponding to the name of the function
#' - Number of arguments the function takes 
#' - name of the Julia method
#' - instruction for JuMP to compute exact gradients automatically

#' # MLE using JuMP

#' Since we already have a bit of JuMP experience at this point,
#' let's try a modelling example and apply what we have learnt.
#' In this example, we compute the maximum likelihood estimate (MLE) of 
#' the parameters of a normal distribution i.e. the sample mean and variance.

using Random, Statistics

n = 1_000
#Random.seed!(1234)
data = randn(n)

mle = Model(with_optimizer(Ipopt.Optimizer, print_level = 0))
@NLparameter(mle, problem_data[i = 1:n] == data[i])
@variable(mle, μ, start = 0.0)
@variable(mle, σ >= 0.0, start = 1.0)
@NLexpression(mle, likelihood, 
(2 * π * σ^2)^(-n / 2) * exp(-(sum((problem_data[i] - μ)^2 for i in 1:n) / (2 * σ^2)))
)

@NLobjective(mle, Max, log(likelihood))

optimize!(mle)

println("μ = ", value(μ))
println("mean(data) = ", mean(data))
println("σ^2 = ", value(σ)^2)
println("var(data) = ", var(data))
println("MLE objective: ", objective_value(mle))

#+

# constrained MLE

@NLconstraint(mle, μ == σ^2)

optimize!(mle)

println("μ = ", value(μ))
println("σ^2 = ", value(σ)^2)
println("MLE objective: ", objective_value(mle))

#+

# Changing the data

data = randn(n)
optimize!(mle)

println("μ = ", value(μ))
println("mean(data) = ", mean(data))
println("σ^2 = ", value(σ)^2)
println("var(data) = ", var(data))
println("MLE objective: ", objective_value(mle))

#' # Disciplined Convex Programming
#' TBA