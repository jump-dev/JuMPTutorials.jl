
using JuMP
model = Model()


@variable(model, freex)


@variable(model, altx, lower_bound=1, upper_bound=2)


has_upper_bound(altx)


upper_bound(altx)


lower_bound(freex)


@variable(model, a[1:2, 1:2])


n = 10
l = [1; 2; 3; 4; 5; 6; 7; 8; 9; 10]
u = [10; 11; 12; 13; 14; 15; 16; 17; 18; 19]

@variable(model, l[i] <= x[i=1:n] <= u[i])


@variable(model, y[i=1:2, j=1:2] >= 2i + j)


@variable(model, z[i=2:3, j=1:2:3] >= 0)


@variable(model, w[1:5,["red","blue"]] <= 1)


@variable(model, u[i=1:3, j=i:5])


@variable(model, v[i=1:9; mod(i, 3)==0])


@variable(model, intx, integer=true)


@variable(model, binx, binary=true)


@variable(model, psdx[1:2, 1:2], PSD)


@variable(model, symx[1:2, 1:2], Symmetric)


model = Model()
@variable(model, x)
@variable(model, y)
@variable(model, z[1:10])


@constraint(model, con, x <= 4)


@constraint(model, acon[i = 1:3], i * x <= i + 1)


@constraint(model, dcon[i = 1:2, j = 2:3], i * x <= j + 1)


@constraint(model, scon[i = 1:2, j = 1:2; i != j], i * x <= j + 1)


for i in 1:3
    @constraint(model, 6*x + 4*y >= 5*i)
end


@constraint(model, conRef3[i in 1:3], 6*x + 4*y >= 5*i)


@constraint(model, sum(z[i] for i in 1:10) <= 1)


using GLPK

mymodel = Model(with_optimizer(GLPK.Optimizer))
@variable(mymodel, x >= 0)
@variable(mymodel, y >= 0)
set_objective_sense(mymodel, MOI.MIN_SENSE)
set_objective_function(mymodel, x + y)

optimize!(mymodel)
       
@show objective_value(mymodel)


objective_sense(mymodel)


objective_function(mymodel)


objective_function_type(mymodel)


vectormodel = Model(with_optimizer(GLPK.Optimizer))

A= [ 1 1 9 5;
     3 5 0 8;
     2 0 6 13]

b = [7; 3; 5]

c = [1; 3; 5; 2]

@variable(vectormodel, x[1:4] >= 0)
@constraint(vectormodel, A * x .== b)
@objective(vectormodel, Min, c' * x)

optimize!(vectormodel)

@show objective_value(vectormodel)

