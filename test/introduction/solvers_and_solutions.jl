
using JuMP 
using GLPK


model_auto = Model(with_optimizer(GLPK.Optimizer))
@variable(model_auto, 0 <= x <= 1)
@variable(model_auto, 0 <= y <= 1)
@constraint(model_auto, x + y <= 1)
@objective(model_auto, Max, x + 2y)
optimize!(model_auto)
objective_value(model_auto)


model_auto_no = Model()
@variable(model_auto_no, 0 <= x <= 1)
@variable(model_auto_no, 0 <= y <= 1)
@constraint(model_auto_no, x + y <= 1)
@objective(model_auto_no, Max, x + 2y)
optimize!(model_auto_no, with_optimizer(GLPK.Optimizer))
objective_value(model_auto_no)


model_man = Model(with_optimizer(GLPK.Optimizer),caching_mode = MOIU.MANUAL)
@variable(model_man, 0 <= x <= 1)
@variable(model_man, 0 <= y <= 1)
@constraint(model_man, x + y <= 1)
@objective(model_man, Max, x + 2y)
MOIU.attach_optimizer(model_man)
optimize!(model_man)
objective_value(model_man)


model_dir = direct_model(GLPK.Optimizer())
@variable(model_dir, 0 <= x <= 1)
@variable(model_dir, 0 <= y <= 1)
@constraint(model_dir, x + y <= 1)
@objective(model_dir, Max, x + 2y)
optimize!(model_dir)
objective_value(model_dir)


using Cbc


model1 = Model(with_optimizer(Cbc.Optimizer, logLevel = 0))


model2 = Model(with_optimizer(Cbc.Optimizer, max_iters=10000))


model3 = Model(with_optimizer(Cbc.Optimizer, seconds=5))


termination_status(model_auto)


display(typeof(MOI.OPTIMAL))


primal_status(model_auto)
dual_status(model_auto)


display(typeof(MOI.FEASIBLE_POINT))


@show value(x)
@show value(y)           
@show objective_value(model_auto)


model_nosol = Model(with_optimizer(GLPK.Optimizer))
@variable(model_nosol, 0 <= x <= 1)
@variable(model_nosol, 0 <= y <= 1)
@constraint(model_nosol, x + y >= 3)
@objective(model_nosol, Max, x + 2y)
optimize!(model_nosol)

if termination_status(model_nosol) == MOI.OPTIMAL
    optimal_solution = value(x)
    optimal_objective = objective_value(model_nosol)
elseif termination_status(model_nosol) == MOI.TIME_LIMIT && has_values(model_nosol)
    suboptimal_solution = value(x)
    suboptimal_objective = objective_value(model_nosol)
else
    error("The model was not solved correctly.")
end

