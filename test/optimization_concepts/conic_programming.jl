
using JuMP
using ECOS


u0 = rand(10)
p = rand(10)
q = rand();


model = Model(with_optimizer(ECOS.Optimizer, printlevel = 0))
@variable(model, u[1:10])
@variable(model, t)
@objective(model, Min, t)
@constraint(model, [t, (u - u0)...] in SecondOrderCone())
@constraint(model, u' * p == q) 
optimize!(model)


@show value.(u);


model = Model(with_optimizer(ECOS.Optimizer, printlevel = 0))
@variable(model, u[1:10])
@variable(model, t)
@objective(model, Min, t)
@constraint(model, [t, 0.5, (u - u0)...] in RotatedSecondOrderCone())
@constraint(model, u' * p == q) 
optimize!(model)


@show value.(u);


# Cannot use the exponential cone directly in JuMP, hence we import MOI to specify the set.
using MathOptInterface

n = 15;
m = 10;
A = randn(m, n); 
b = rand(m, 1);

model = Model(with_optimizer(ECOS.Optimizer, printlevel = 0))
@variable(model, t[1:n])
@variable(model, x[1:n])
@objective(model, Max, sum(t))
@constraint(model, sum(x) == 1)
@constraint(model, A * x .<= b )
@constraint(model, con[i = 1:n], [1, x[i], t[i]] in MathOptInterface.ExponentialCone())

optimize!(model);


@show objective_value(model);

