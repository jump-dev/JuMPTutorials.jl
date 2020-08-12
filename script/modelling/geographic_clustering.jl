#' ---
#' title: Geographical Clustering With Additional Constraint
#' ---

#' **Originally Contributed by**: Matthew Helm ([with help from Mathieu Tanneau on Julia Discourse](https://discourse.julialang.org/t/which-jump-jl-solver-for-this-problem/43350/17?u=mthelm85))

#' The goal of this exercise is to cluster $n$ cities into $k$ groups, minimizing the total pairwise distance between cities 
#' *and* ensuring that the variance in the total populations of each group is relatively small. 

#' For this example, we'll use the 20 most populous cities in the United States.

using Cbc
using DataFrames
using Distances
using JuMP
using LinearAlgebra

cities = DataFrame(
    city=[ "New York, NY", "Los Angeles, CA", "Chicago, IL", "Houston, TX", "Philadelphia, PA", "Phoenix, AZ", "San Antonio, TX", "San Diego, CA", "Dallas, TX", "San Jose, CA", "Austin, TX", "Indianapolis, IN", "Jacksonville, FL", "San Francisco, CA", "Columbus, OH", "Charlotte, NC", "Fort Worth, TX", "Detroit, MI", "El Paso, TX", "Memphis, TN"],
    population=[8405837,3884307,2718782,2195914,1553165,1513367,1409019,1355896,1257676,998537,885400,843393,842583,837442,822553,792862,792727,688701,674433,653450],
    lat=[40.7127,34.0522,41.8781,29.7604,39.9525,33.4483,29.4241,32.7157,32.7766,37.3382,30.2671,39.7684,30.3321,37.7749,39.9611,35.2270,32.7554,42.3314,31.7775,35.1495],
    lon=[-74.0059,-118.2436,-87.6297,-95.3698,-75.1652,-112.0740,-98.4936,-117.1610,-96.7969,-121.8863,-97.7430,-86.1580,-81.6556,-122.4194,-82.9987,-80.8431,-97.3307,-83.0457,-106.4424,-90.0489])

#' ### Model Specifics

#' We will cluster these 20 cities into 3 different groups and we will assume that the ideal or target population $P$ for a
#' group is simply the total population of the 20 cities divided by 3:

n = size(cities,1)
k = 3
P = sum(cities.population) / k

#' ### Obtaining the distances between each city

#' Let's leverage the *Distances.jl* package to compute the pairwise Haversine distance between each of the cities in our data
#' set and store the result in a variable we'll call `dm`:

dm = Distances.pairwise(Haversine(6372.8), Matrix(cities[:, [3,4]])', dims=2)

#' Our distance matrix is symmetric so we'll convert it to a `LowerTriangular` matrix so that we can better interpret the
#' objective value of our model (if we don't do this the total distance will be doubled):

dm = LowerTriangular(dm)

#' ### Build the model
#' Now that we have the basics taken  care of, we can set up our model, create decision variables, add constraints, and then
#' solve.

#' First, we'll set up a model that leverages the [Cbc](https://github.com/coin-or/Cbc) solver. Next, we'll set up a binary
#' variable $x_{i,k}$ that takes the value $1$ if city $i$ is in group $k$ and $0$ otherwise. Each city must be in a group, so
#' we'll add the constraint $\sum_kx_{i,k} = 1$ for every $i$.

model = Model(Cbc.Optimizer)

@variable(model, x[1:n, 1:k], Bin)

for i in 1:n
    @constraint(model, sum(x[i,:]) == 1)
end

#'The total population of a group $k$ is $Q_k = \sum_ix_{i,k}q_i$ where $q_i$ is simply the $i$th value from the `population`
#' column in our `cities` DataFrame. Let's add constraints so that $\alpha \leq (Q_k - P) \leq \beta$. We'll set $\alpha$
#' equal to -2,500,000 and $\beta$ equal to 2,500,000. By adjusting these thresholds you'll find that there is a tradeoff
#' between having relatively even populations between groups and having geographically close cities within each group. In
#' other words, the larger the absolute values of $\alpha$ and $\beta$, the closer together the cities in a group will be but
#' the variance between the group populations will be higher.

α = -2_500_000
β = 2_500_000

for i in 1:k
    @constraint(model, (x' * cities.population)[i] - P <= β)
    @constraint(model, (x' * cities.population)[i] - P >= α)
end

#' Now we need to add one last binary variable $z_{i,j}$ to our model that we'll use to compute the total distance between the 
#' cities in our groups, defined as  $\sum_{i,j}d_{i,j}z_{i,j}$. Variable $z_{i,j}$ will equal $1$ if cities $i$ and $j$ are 
#' in the same group, and $0$ if they are not in the same group.

#' To ensure that $z_{i,j} = 1$ if and only if cities $i$ and $j$ are in the same group, we add the constraints $z_{i,j} \geq 
#' x_{i,k} + x_{j,k} - 1$ for every pair $i,j$ and every $k$:

@variable(model, z[1:n,1:n], Bin)

for k in 1:k, i in 1:n, j in 1:n
    @constraint(model, z[i,j] >= x[i,k] + x[j,k] - 1)
end

#' We can now add an objective to our model which will simply be to minimize the dot product of $z$ and our distance matrix,
#' `dm`. We can then call `optimize!` and review the results.

@objective(model, Min, dot(z,dm));

optimize!(model)

#' ### Reviewing the Results

#' Now that we have results, we can add a column to our `cities` DataFrame for the group and then loop through our $x$
#' variable to assign each city to its group. Once we have that, we can look at the total population for each group and also
#' plot the cities and their groups to verify visually that they are grouped by geographic proximity.

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

#' The populations of each group are fairly even and we can see from the plot below that the groupings look good in terms of
#' geographic proximity:

#' <img src="img/geo_clusters.png" style="width: auto; height: auto" alt="Geographic Clusters">
