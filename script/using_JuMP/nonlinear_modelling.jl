#' ---
#' title: Nonlinear Modelling
#' ---

#' **Originally Contributed by**: Arpit Bhatia

#' This tutorial provides a breif introduction to nonlinear modelling in JuMP.
#' For more details and specifics, visit the [JuMP docs](http://www.juliaopt.org/JuMP.jl/stable/nlp/).

#' ## Nonlinear Programs
#' While we have already seen examples of linear, quadratic and conic programs,
#' JuMP also supports other general smooth nonlinear (convex and nonconvex) optimization problems.

#' A JuMP model object can contain a mix of linear, quadratic, and nonlinear contraints or objective functions.
#' Thus, a model object for a nonlinear program is constructed in the same way as before.

using JuMP, Ipopt
model = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0));

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

#' ## MLE using JuMP

#' Since we already have a bit of JuMP experience at this point,
#' let's try a modelling example and apply what we have learnt.
#' In this example, we compute the maximum likelihood estimate (MLE) of
#' the parameters of a Gaussian distribution i.e. the sample mean and variance.

#' If $X_{1}, \ldots, X_{n}$ are an id sample from a population with pdf or pmf
#' $f\left(x | \theta_{1}, \ldots, \theta_{k}\right),$ the likelihood function is defined by

#' $$
#' L(\theta | \mathbf{x})=L\left(\theta_{1}, \ldots, \theta_{k} | x_{1}, \ldots, x_{n}\right)=\prod_{i=1}^{n} f\left(x_{i} | \theta_{1}, \ldots, \theta_{k}\right)
#' $$

#' For each sample point $\mathbf{x}$, let $\hat{\theta}(\mathbf{x})$ be a parameter value
#' at which $L(\theta | \mathbf{x})$ attains its maximum as a function of $\theta,$ with $\mathbf{x}$ held fixed.
#' A maximum likelihood estimator (MLE) of the parameter $\theta$ based on a sample $\mathbf{X}$ is
#' $\hat{\theta}(\mathbf{X})$.

#'The Gaussian likelihood is -

#' $$
#' L(\theta | \mathbf{x})=\prod_{i=1}^{n} \frac{1}{(2 \pi)^{1 / 2}} e^{-(1 / 2)\left(x_{i}-\theta\right)^{2}}=\frac{1}{(2 \pi)^{n / 2}} e^{(-1 / 2) \Sigma_{i=1}^{n}\left(x_{i}-\theta\right)^{2}}
#' $$

#' In most cases, the natural logarithm of
#' $L(\theta | \mathbf{x}), \log L(\theta | \mathbf{x})$ (known as the log likelihood),
#' is used rather than $L(\theta | \mathbf{x})$ directly.
#' The reason is that the log likelihood is easier to differentiate.
#' This substituion is possible because the log function is strictly increasing on $(0, \infty)$,
#' which implies that the extrema of $L(\theta | \mathbf{x})$ and $\log L(\theta | \mathbf{x})$ coincide.

using Random, Statistics

Random.seed!(1234)

n = 1_000
data = randn(n)

mle = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0))
@NLparameter(mle, problem_data[i = 1:n] == data[i])
μ0 = randn()
σ0 = rand() + 1
@info "Starting guess, mean: $μ0, std: $σ0"
@variable(mle, μ, start = μ0)
@variable(mle, σ >= 0.0, start = σ0)
@NLexpression(mle, loglikelihood,
    -(n / 2) * (log(2π) + 2 * log(σ)) - inv(2 * σ^2) * sum((xi - μ)^2 for xi in problem_data)
)

@NLobjective(mle, Max, loglikelihood)

optimize!(mle)

println("μ = ", value(μ))
println("mean(data) = ", mean(data))
println("σ^2 = ", value(σ)^2)
println("var(data) = ", var(data))
println("MLE value: ", exp(objective_value(mle)))

#+

# Changing the data

data = randn(n)
optimize!(mle)

println("μ = ", value(μ))
println("mean(data) = ", mean(data))
println("σ^2 = ", value(σ)^2)
println("var(data) = ", var(data))
println("MLE objective: ", objective_value(mle))

#' ## Writing Convex Models

#' Nonlinear solvers like Ipopt are usually local solvers.
#' For convex problems, the local optima is also the global optima,
#' and thus Ipopt is able to provide us with the correct solution.
#' However, in case a problem is not written in the convex form, then we may be unable to solve it.

#' A tool that helps us in dealing with this issue is [Disciplined Convex Programming](https://dcp.stanford.edu) (DCP).
#' DCP is a system for constructing mathematical expressions with known curvature from a given library of base functions.
#' Specifically, it helps us to construct convex optimization models when possible,
#' i.e. minimize convex function or maximize concave function and use constraints that are convex $f$ <= concave $g$
