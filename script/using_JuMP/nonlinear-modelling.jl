#' ---
#' title: Nonlinear Modelling
#' ---

#' **Originally Contributed by**: Arpit Bhatia

#' This tutorial illustrates nonlinear modelling through a complete example - controlling a rocket with JuMP!

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
#' Parameters are useful since it's faster to modify a model in-place by changing the value of the parameter
#' compared to creating an entirely new model object.

@NLparameter(model, p == 0.003); # Providing a starting value is necessary for parameters

#' ### Expressions
#' JuMP also supports the creation of arithmetic expressions which can then be inserted into
#' constraints, the objective and other expressions.

@NLexpression(model, expr_1, sin(x))
@NLexpression(model, expr_2, asin(expr_1)); # Inserting one expression into another

#' There are some [syntax rules](https://pkg.julialang.org/docs/JuMP/DmXqY/0.19.2/nlp/#Syntax-notes-1) 
#' which must be followed while writing a nonlinear expression. 

#' Note that JuMP also supports linear and quadratic expression. 
#' You can find out more about this functionality in the [docs](https://pkg.julialang.org/docs/JuMP/DmXqY/0.19.2/expressions/)

#' ### Nonlinear Objectives and Constraints
#' Nonlinear objectives and constraints are specified by using the `@NLobjective` and `@NLconstraint` macros.

@NLconstraint(model, exp(x) + y^4 <= 0)
@NLobjective(model, Min, tan(x) + log(y))

#' Since we already have a bit of experience at this point,
#' let's "JuMP" right into a modelling example and apply what we have learnt.