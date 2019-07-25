
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


model_manual = Model(with_optimizer(GLPK.Optimizer),caching_mode = MOIU.MANUAL)
@variable(model_manual, 0 <= x <= 1)
@variable(model_manual, 0 <= y <= 1)
@constraint(model_manual, x + y <= 1)
@objective(model_manual, Max, x + 2y)
MOIU.attach_optimizer(model_manual)
optimize!(model_manual)
objective_value(model_manual)


model_direct = direct_model(GLPK.Optimizer())
@variable(model_direct, 0 <= x <= 1)
@variable(model_direct, 0 <= y <= 1)
@constraint(model_direct, x + y <= 1)
@objective(model_direct, Max, x + 2y)
optimize!(model_direct)
objective_value(model_direct)


using Cbc


model = Model(with_optimizer(Cbc.Optimizer, logLevel = 0));


model = Model(with_optimizer(Cbc.Optimizer, max_iters = 10000));


model = Model(with_optimizer(Cbc.Optimizer, seconds = 5));


termination_status(model_auto)


display(typeof(MOI.OPTIMAL))


primal_status(model_auto)
dual_status(model_auto)


display(typeof(MOI.FEASIBLE_POINT))


@show value(x)
@show value(y)           
@show objective_value(model_auto)

