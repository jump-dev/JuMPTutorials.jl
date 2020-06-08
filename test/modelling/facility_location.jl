
using Random
using LinearAlgebra

using JuMP
import GLPK
using Plots


Random.seed!(314)

m = 12  # number of clients
n = 5  # number of facility locations

# Clients' locations
Xc = rand(m)
Yc = rand(m)

# Facilities' potential locations
Xf = rand(n)
Yf = rand(n)

# Fixed costs
f = ones(n);

# Distance
c = zeros(m, n)
for i in 1:m
    for j in 1:n
        c[i, j] = norm([Xc[i] - Xf[j], Yc[i] - Yf[j]], 2)
    end
end


# Display the data
scatter(Xc, Yc, label = "Clients", markershape=:circle, markercolor=:blue)
scatter!(Xf, Yf, label="Facility", 
    markershape=:square, markercolor=:white, markersize=6,
    markerstrokecolor=:red, markerstrokewidth=2
)


# Create a JuMP model
ufl = Model(GLPK.Optimizer)

# Variables
@variable(ufl, y[1:n], Bin);
@variable(ufl, x[1:m, 1:n], Bin);

# Each client is served exactly once
@constraint(ufl, client_service[i in 1:m],
    sum(x[i, j] for j in 1:n) == 1
);

# A facility must be open to serve a client
@constraint(ufl, open_facility[i in 1:m, j in 1:n],
    x[i, j] <= y[j]
)

# Objective
@objective(ufl, Min, f'y + sum(c .* x));


# Solve the uncapacitated facility location problem with GLPK
optimize!(ufl)
println("Optimal value: ", objective_value(ufl))

x_ = value.(x) .> 1 - 1e-5
y_ = value.(y) .> 1 - 1e-5

# Display clients
p = scatter(Xc, Yc, markershape=:circle, markercolor=:blue, label=nothing)

# Show open facility
mc = [(y_[j] ? :red : :white) for j in 1:n]
scatter!(Xf, Yf, 
    markershape=:square, markercolor=mc, markersize=6,
    markerstrokecolor=:red, markerstrokewidth=2,
    label=nothing
)

# Show client-facility assignment
for i in 1:m
    for j in 1:n
        if x_[i, j] == 1
           plot!([Xc[i], Xf[j]], [Yc[i], Yf[j]], color=:black, label=nothing)
        end
    end
end

display(p)


# Demands
a = rand(1:3, m);

# Capacities
q = rand(5:10, n);


# Display the data
scatter(Xc, Yc, label=nothing,
    markershape=:circle, markercolor=:blue, markersize= 2 .*(2 .+ a)
)

scatter!(Xf, Yf, label=nothing, 
    markershape=:rect, markercolor=:white, markersize= q,
    markerstrokecolor=:red, markerstrokewidth=2
)


# Create a JuMP model
cfl = Model(GLPK.Optimizer)

# Variables
@variable(cfl, y[1:n], Bin);
@variable(cfl, x[1:m, 1:n], Bin);

# Each client is served exactly once
@constraint(cfl, client_service[i in 1:m], sum(x[i, :]) == 1)

# Capacity constraint
@constraint(cfl, capacity, x'a .<= (q .* y))

# Objective
@objective(cfl, Min, f'y + sum(c .* x));


# Solve the problem
optimize!(cfl)
println("Optimal value: ", objective_value(cfl))
@test termination_status(cfl) == MOI.OPTIMAL


x_ = value.(x) .> 1 - 1e-5
y_ = value.(y) .> 1 - 1e-5

# Display the solution
p = scatter(Xc, Yc, label=nothing,
    markershape=:circle, markercolor=:blue, markersize= 2 .*(2 .+ a)
)

mc = [(y_[j] ? :red : :white) for j in 1:n]
scatter!(Xf, Yf, label=nothing, 
    markershape=:rect, markercolor=mc, markersize=q,
    markerstrokecolor=:red, markerstrokewidth=2
)

# Show client-facility assignment
for i in 1:m
    for j in 1:n
        if x_[i, j] == 1
            plot!([Xc[i], Xf[j]], [Yc[i], Yf[j]], color=:black, label=nothing)
            break
        end
    end
end

display(p)
