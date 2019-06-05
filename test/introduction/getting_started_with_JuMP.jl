
using JuMP
using GLPK

model = Model(with_optimizer(GLPK.Optimizer))
@variable(model, x >= 0)
@variable(model, y >= 0)
@constraint(model, 6x + 8y >= 100)
@constraint(model, 7x + 12y >= 120)
@objective(model, Min, 12x + 20y)

optimize!(model)

@show value(x)
@show value(y)           
@show objective_value(model)


using JuMP


using GLPK


model = Model(with_optimizer(GLPK.Optimizer))


@variable(model, x >= 0)
@variable(model, y >= 0)


@constraint(model, 6x + 8y >= 100)
@constraint(model, 7x + 12y >= 120)


@objective(model, Min, 12x + 20y)


optimize!(model)


@show value(x)
@show value(y)
@show objective_value(model)


using Test
@test objective_value(model) ≈ 205

