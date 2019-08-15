
using JuMP
using GLPK


financing = Model(with_optimizer(GLPK.Optimizer))

@variables(financing, begin
    0 <= u[1:5] <= 100
    0 <= v[1:3]
    0 <= w[1:5]
    m
end)

@objective(financing, Max, m) # Money at the end of June

@constraints(financing, begin
    u[1] + v[1] - w[1] == 150 # January
    u[2] + v[2] - w[2] - 1.01u[1] + 1.003w[1] == 100 # February
    u[3] + v[3] - w[3] - 1.01u[2] + 1.003w[2] == -200 # March
    u[4] - w[4] - 1.02v[1] - 1.01u[3] + 1.003w[3] == 200 # April
    u[5] - w[5] - 1.02v[2] - 1.01u[4] + 1.003w[4] == -50 # May
    -m - 1.02v[3] - 1.01u[5] + 1.003w[5] == -300 # June
end)

optimize!(financing)
@show objective_value(financing);


bid_values = [6 3 12 12 8 16]
bid_items = [[1], [2], [3 4], [1 3], [2 4], [1 3 4]]

auction = Model(with_optimizer(GLPK.Optimizer))
@variable(auction, y[1:6], Bin)
@objective(auction, Max, sum(y' .* bid_values))
for i in 1:6
    @constraint(auction, sum(y[j] for j in 1:6 if i in bid_items[j]) <= 1)
end

optimize!(auction)

@show objective_value(auction);
@show value.(y);


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

portfolio = Model(with_optimizer(Ipopt.Optimizer, print_level=0))
@variable(portfolio, x[1:3] >= 0)
@objective(portfolio, Min, x' * Q * x)
@constraint(portfolio, sum(x) <= 1000)
@constraint(portfolio, sum(r .* x) >= 50)

optimize!(portfolio)

@show objective_value(portfolio);
@show value.(x);

