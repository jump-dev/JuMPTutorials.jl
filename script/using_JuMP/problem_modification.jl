#' ---
#' title: Problem Modification
#' author: Arpit Bhatia
#' ---

#' This tutorial deals with how to modify models after they have been created and solved.
#' This functionality can be useful, for example, 
#' when we are solving many similar models in succession or generating the model dynamically. 
#' Additionally it is sometimes desirable for the solver to re-start from the last solution to 
#' reduce running times for successive solves (“hot-start”). 

#+ results = "hidden"

using JuMP
using MathOptInterface
const MOI = MathOptInterface

#' # Modifying Variables
#+ results = "hidden"

model = Model()
@variable(model, x)

#' ## Variable Bounds

#' The `set_lower_bound` and `set_upper_bound` functions can be used to create as well as 
#' modify an existing variable bound.

set_lower_bound(x, 3)
lower_bound(x)

#'

set_lower_bound(x, 2)
lower_bound(x)

#' We can delete variable bounds using the `delete_lower_bound` and `delete_upper_bound` functions.

delete_lower_bound(x)
has_lower_bound(x)

#' We can assign a fixed value to a variable using `fix`.

fix(x, 5)
fix_value(x)

#' However, fixing a variable with existing bounds will throw an error.
#+ tangle =  false

@variable(model, y >= 0)
fix(y, 2)

#' As we can see in the error message above, 
#' we have to specify to JuMP that we wish to forcefuly remove the bound.

fix(y, 2; force = true)
fix_value(y)

#' We can also call the `unfix` function to remove the fixed value.

unfix(x)
is_fixed(x)

#' ## Deleting Variables

#' The `all_variables` function returns a list of all variables present in the model.
all_variables(model)

#' To delete variables from a model, we can use the `delete` function. 

delete(model, x)
all_variables(model)

#' We can also check whether a variable is a valid JuMP variable in a model using the `is_valid` function.

is_valid(model, x)


#' # Modifying Constraints
#+ results = "hidden"

model = Model()
@variable(model, x)

#' ## Modifying a Variable Coefficient
#' It is also possible to modify the scalar coefficients 
#' (but notably not yet the quadratic coefficients) using the `set_coefficient` function.

@constraint(model, con, 2x <= 1)

#'

set_coefficient(con, x, 3)
con

#' ## Deleting a Constraint
#' Just like for deleting variables, we can use the `delete` function for constraints as well.

delete(model, con)
is_valid(model, con)

#' # Modifying the Objective
#+ results = "hidden"

model = Model()
@variable(model, x)
@objective(model, Min, 7x + 4)

#' The function `objective_function` is used to query the objective of a model.

objective_function(model)

#' `objective_sense` is similarily used to query the objective sense of a model.

objective_sense(model)

#' To easiest way to change the objective is to simply call `@objective` again 
#' - the previous objective function and sense will be replaced.

@objective(model, Max, 8x + 3)
objective_function(model)

#'

objective_sense(model)

#' Another way is to change the objective is to 
#' use the low-level functions `set_objective_function` and `set_objective_sense`.

set_objective_function(model, 5x + 11)
objective_function(model)

#'

set_objective_sense(model, MOI.MIN_SENSE) 
objective_sense(model)

#' Note that we can't use the Min and Max shortcuts here as its a low level function.