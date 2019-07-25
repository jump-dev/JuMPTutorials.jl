
using JuMP


a = rand(1:100, 5, 5)
c = rand(1:100, 5, 5)
b = rand(1:100, 5)
d = rand(1:100, 5)

model = Model()
@variable(model, x[1:5])
@variable(model, y, Bin)
@constraint(model, a * x .>= y .* b)
@constraint(model, c * x .>= (1 - y) .* d)


a = rand(1:100, 5, 5)
b = rand(1:100, 5)
m = rand(10000:11000, 5)

model = Model()
@variable(model, x[1:5])
@variable(model, z, Bin)
@constraint(model, a * x .<=  b .+ (m .* (1 - z))) 
# If z was a regular Julia variable, we would not have had to use the vectorized dot operator


model = Model()

@variable(model, x)
@variable(model, y)
@constraint(model, x in MOI.ZeroOne())
@constraint(model, y in MOI.Integer())


l = 7.45
u = 22.22
@variable(model, a)
@constraint(model, a in MOI.Semicontinuous(l, u))


l = 5
u = 34
@variable(model, b)
@constraint(model, b in MOI.Semiinteger(l, u))


@variable(model, u[1:3])
@constraint(model, u in MOI.SOS1([1.0, 2.0, 3.0]))


@variable(model, v[1:3])
@constraint(model, v in MOI.SOS2([3.0, 1.0, 2.0]))

