
using JuMP
model = Model()


@variable(model, free_x)


@variable(model, keyword_x, lower_bound = 1, upper_bound = 2)


has_upper_bound(keyword_x)


upper_bound(keyword_x)


@variable(model, a[1:2, 1:2])


n = 10
l = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10]
u = [10; 11; 12; 13; 14; 15; 16; 17; 18; 19]

@variable(model, l[i] <= x[i = 1:n] <= u[i])


@variable(model, y[i = 1:2, j = 1:2] >= 2i + j)


@variable(model, z[i = 2:3, j = 1:2:3] >= 0)


@variable(model, w[1:5,["red","blue"]] <= 1)


@variable(model, u[i = 1:3, j = i:5])


@variable(model, v[i = 1:9; mod(i, 3) == 0])


@variable(model, integer_x, integer = true)


@variable(model, binary_x, binary = true)


@variable(model, psd_x[1:2, 1:2], PSD)


@variable(model, sym_x[1:2, 1:2], Symmetric)


model = Model()
@variable(model, x)
@variable(model, y)
@variable(model, z[1:10])


@constraint(model, con, x <= 4)


@constraint(model, [i = 1:3], i * x <= i + 1)


@constraint(model, [i = 1:2, j = 2:3], i * x <= j + 1)


@constraint(model, [i = 1:2, j = 1:2; i != j], i * x <= j + 1)


for i in 1:3
    @constraint(model, 6x + 4y >= 5i)
end


@constraint(model, [i in 1:3], 6x + 4y >= 5i)


@constraint(model, sum(z[i] for i in 1:10) <= 1)


using GLPK

model = Model(with_optimizer(GLPK.Optimizer))
@variable(model, x >= 0)
@variable(model, y >= 0)
set_objective_sense(model, MOI.MIN_SENSE)
set_objective_function(model, x + y)

optimize!(model)
       
@show objective_value(model)


objective_sense(model)


objective_function(model)


objective_function_type(model)


vector_model = Model(with_optimizer(GLPK.Optimizer))

A= [ 1 1 9  5;
     3 5 0  8;
     2 0 6 13]

b = [7; 3; 5]

c = [1; 3; 5; 2]

@variable(vector_model, x[1:4] >= 0)
@constraint(vector_model, A * x .== b)
@objective(vector_model, Min, c' * x)

optimize!(vector_model)

@show objective_value(vector_model)

