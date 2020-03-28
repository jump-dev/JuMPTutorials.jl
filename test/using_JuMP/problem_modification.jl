
using JuMP


model = Model()
@variable(model, x);


set_lower_bound(x, 3)
lower_bound(x)


set_lower_bound(x, 2)
lower_bound(x)


delete_lower_bound(x)
has_lower_bound(x)


fix(x, 5)
fix_value(x)


@variable(model, y >= 0);


fix(y, 2; force = true)
fix_value(y)


unfix(x)
is_fixed(x)


all_variables(model)


delete(model, x)
all_variables(model)


is_valid(model, x)


model = Model()
@variable(model, x);


@constraint(model, con, 2x <= 1);


set_normalized_coefficient(con, x, 3)
con


delete(model, con)
is_valid(model, con)


model = Model()
@variable(model, x)
@objective(model, Min, 7x + 4);


objective_function(model)


objective_sense(model)


@objective(model, Max, 8x + 3)
objective_function(model)


objective_sense(model)


set_objective_function(model, 5x + 11)
objective_function(model)


set_objective_sense(model, MOI.MIN_SENSE) 
objective_sense(model)

