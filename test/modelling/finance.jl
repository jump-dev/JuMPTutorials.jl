
using JuMP
using GLPK


model = Model(with_optimizer(GLPK.Optimizer))
@variable(model, 0 <= x[1:5] <= 100)
@variable(model, 0 <= y[1:3])
@variable(model, 0 <= z[1:5])
@variable(model, v)

@objective(model, Max, v) # Money at the end of June

@constraint(model, x[1] + y[1] - z[1] == 150) # January
@constraint(model, x[2] + y[2] - z[2] - 1.01x[1] + 1.003z[1] == 100) # February
@constraint(model, x[3] + y[3] - z[3] - 1.01x[2] + 1.003z[2] == -200) # March
@constraint(model, x[4] - z[4] - 1.02y[1] - 1.01x[3] + 1.003z[3] == 200) # April
@constraint(model, x[5] - z[5] - 1.02y[2] - 1.01x[4] + 1.003z[4] == -50) # May
@constraint(model, -v - 1.02y[3] - 1.01x[5] + 1.003z[5] == -300) # June

optimize!(model)
@show objective_value(model)


bid_values = [6 3 12 12 8 16]
bid_items = [[1], [2], [3 4], [1 3], [2 4], [1 3 4]]

model = Model(with_optimizer(GLPK.Optimizer))
@variable(model, x[1:6], Bin)
@objective(model, Max, sum(x' .* bid_values))
for i in 1:6
    @constraint(model, sum(x[j] for j in 1:6 if i in bid_items[j]) <= 1)
end

optimize!(model)

@show objective_value(model)
@show value.(x)


using Statistics # Useful for calculations
using Ipopt      # Ipopt since our objective is quadratic

stock_data = [
93.043 51.826 1.063;
84.585 52.823 0.938;
111.453 56.477 1.000;
99.525 49.805 0.938;
95.819 50.287 1.438;
114.708 51.521 1.700;
111.515 51.531 2.540;
113.211 48.664 2.390;
104.942 55.744 3.120;
99.827 47.916 2.980;
91.607 49.438 1.900;
107.937 51.336 1.750;
115.590 55.081 1.800;
]

# Calculating stock returns

stock_returns = Array{Float64}(undef, 12, 3) 

for i in 1:12
    stock_returns[i, :] = (stock_data[i + 1, :] .- stock_data[i, :]) ./ stock_data[i, :] 
end

# Calculating the expected value of monthly return

r = [Statistics.mean(stock_returns[:,1]) Statistics.mean(stock_returns[:,2]) Statistics.mean(stock_returns[:,3])]'

# Calculating the covariance matrix Q

Q = Statistics.cov(stock_returns)


# JuMP Model

model = Model(with_optimizer(Ipopt.Optimizer, print_level=0))
@variable(model, x[1:3] >= 0)
@objective(model, Min, x' * Q * x)
@constraint(model, sum(x) <= 1000)
@constraint(model, sum(r .* x) >= 50)

optimize!(model)

@show objective_value(model)
@show value.(x)

