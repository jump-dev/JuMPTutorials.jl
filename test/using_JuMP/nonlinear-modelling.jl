
using JuMP, Ipopt
model = Model(with_optimizer(Ipopt.Optimizer));


@variable(model, x, start = 4)
@variable(model, y, start = -9.66);


@NLparameter(model, p == 0.003); # Providing a starting value is necessary for parameters


@NLexpression(model, expr_1, sin(x))
@NLexpression(model, expr_2, asin(expr_1)); # Inserting one expression into another


@NLconstraint(model, exp(x) + y^4 <= 0)
@NLobjective(model, Min, tan(x) + log(y))

