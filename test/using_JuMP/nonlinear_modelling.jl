
using JuMP, Ipopt
model = Model(optimizer_with_attributes(Ipopt.Optimizer, "print_level" => 0));


@variable(model, x, start = 4)
@variable(model, y, start = -9.66);


@NLparameter(model, p == 0.003); # Providing a starting value is necessary for parameters
@NLparameter(model, l[i = 1:10] == 4 - i); # A collection of parameters


value(l[1])


set_value(l[1], -4)
value(l[1])


@NLexpression(model, expr_1, sin(x))
@NLexpression(model, expr_2, asin(expr_1)); # Inserting one expression into another


@NLconstraint(model, exp(x) + y^4 <= 0)
@NLobjective(model, Min, tan(x) + log(y))


my_function(a,b) = (a * b)^-6 + (b / a)^3
register(model, :my_function, 2, my_function, autodiff = true)


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


# Changing the data

data = randn(n)
optimize!(mle)

println("μ = ", value(μ))
println("mean(data) = ", mean(data))
println("σ^2 = ", value(σ)^2)
println("var(data) = ", var(data))
println("MLE objective: ", objective_value(mle))



