using Cbc
using DataFrames
using Distances
using JuMP
using LinearAlgebra

cities = DataFrame(
    city=[ "New York, NY", "Los Angeles, CA", "Chicago, IL", "Houston, TX", "Philadelphia, PA", "Phoenix, AZ", "San Antonio, TX", "San Diego, CA", "Dallas, TX", "San Jose, CA", "Austin, TX", "Indianapolis, IN", "Jacksonville, FL", "San Francisco, CA", "Columbus, OH", "Charlotte, NC", "Fort Worth, TX", "Detroit, MI", "El Paso, TX", "Memphis, TN"],
    population=[8405837,3884307,2718782,2195914,1553165,1513367,1409019,1355896,1257676,998537,885400,843393,842583,837442,822553,792862,792727,688701,674433,653450],
    lat=[40.7127,34.0522,41.8781,29.7604,39.9525,33.4483,29.4241,32.7157,32.7766,37.3382,30.2671,39.7684,30.3321,37.7749,39.9611,35.2270,32.7554,42.3314,31.7775,35.1495],
    lon=[-74.0059,-118.2436,-87.6297,-95.3698,-75.1652,-112.0740,-98.4936,-117.1610,-96.7969,-121.8863,-97.7430,-86.1580,-81.6556,-122.4194,-82.9987,-80.8431,-97.3307,-83.0457,-106.4424,-90.0489]
)

n = size(cities,1)
k = 3
P = sum(cities.population) / k

dm = Distances.pairwise(Haversine(6372.8), Matrix(cities[:, [3,4]])', dims=2)
dm = LowerTriangular(dm)

model = Model(Cbc.Optimizer)

@variable(model, x[1:n, 1:k], Bin)

for i in 1:n
    @constraint(model, sum(x[i,:]) == 1)
end

α = -2_500_000
β = 2_500_000

for i in 1:k
    @constraint(model, (x' * cities.population)[i] - P <= β)
    @constraint(model, (x' * cities.population)[i] - P >= α)
end

@variable(model, z[1:n,1:n], Bin)

for k in 1:k, i in 1:n, j in 1:n
    @constraint(model, z[i,j] >= x[i,k] + x[j,k] - 1)
end

@objective(model, Min, dot(z,dm));

optimize!(model)

cities.group = zeros(n)

for i in 1:n, j in 1:k
    if round(value.(x)[i,j]) == 1.0
        cities.group[i] = j
    end
end

for group in groupby(cities, :group)
    @show group
    println("")
    @show sum(group.population)
    println("")
end