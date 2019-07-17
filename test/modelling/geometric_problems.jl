
using JuMP
using Ipopt


x = rand(10)
a = rand(10)
b = rand()

model = Model(with_optimizer(Ipopt.Optimizer, print_level=0))
@variable(model, x0[1:10])
@objective(model, Min, sum((x - x0) .* (x - x0))) # We minimize the square of the distance here
@constraint(model, x0' * a == b)                  # Point must lie on the hyperplane

optimize!(model)
@show objective_value(model);
@show value.(x0);


A_1 = rand(10,10)
A_2 = rand(10,10)
b_1 = rand(10)
b_2 = rand(10)

model = Model(with_optimizer(Ipopt.Optimizer, print_level=0))
@variable(model, x[1:10])                       # Point closest on the first polyhedron
@variable(model, y[1:10])                       # Point closest on the second polyhedron
@objective(model, Min, sum((x - y) .* (x - y))) # We minimize the square of the distance here as above
@constraint(model, A_1 * x .<= b_1)             # Point x must lie on the first polyhedron
@constraint(model, A_2 * y .<= b_2)             # Point y must lie on the second polyhedron

optimize!(model)
@show objective_value(model);


fixed = [ 1   1  -1 -1    1   -1  -0.2  0.1;         # coordinates of fixed points
          1  -1  -1  1 -0.5 -0.2    -1    1]

M = size(fixed,2)                                    # number of fixed points
N = 6                                                # number of free points

A = [ 1  0  0 -1  0  0    0  0  0  0  0  0  0  0;    # Matrix on links
      1  0 -1  0  0  0    0  0  0  0  0  0  0  0;
      1  0  0  0 -1  0    0  0  0  0  0  0  0  0;
      1  0  0  0  0  0   -1  0  0  0  0  0  0  0;
      1  0  0  0  0  0    0 -1  0  0  0  0  0  0;
      1  0  0  0  0  0    0  0  0  0 -1  0  0  0;
      1  0  0  0  0  0    0  0  0  0  0  0  0 -1;
      0  1 -1  0  0  0    0  0  0  0  0  0  0  0;
      0  1  0 -1  0  0    0  0  0  0  0  0  0  0;
      0  1  0  0  0 -1    0  0  0  0  0  0  0  0;
      0  1  0  0  0  0    0 -1  0  0  0  0  0  0;
      0  1  0  0  0  0    0  0 -1  0  0  0  0  0;
      0  1  0  0  0  0    0  0  0  0  0  0 -1  0;
      0  0  1 -1  0  0    0  0  0  0  0  0  0  0;
      0  0  1  0  0  0    0 -1  0  0  0  0  0  0;
      0  0  1  0  0  0    0  0  0  0 -1  0  0  0;
      0  0  0  1 -1  0    0  0  0  0  0  0  0  0;
      0  0  0  1  0  0    0  0 -1  0  0  0  0  0;
      0  0  0  1  0  0    0  0  0 -1  0  0  0  0;
      0  0  0  1  0  0    0  0  0  0  0 -1  0  0;
      0  0  0  1  0  0    0  0  0  0  0 -1  0  0;        
      0  0  0  0  1 -1    0  0  0  0  0  0  0  0;
      0  0  0  0  1  0   -1  0  0  0  0  0  0  0;
      0  0  0  0  1  0    0  0  0 -1  0  0  0  0;
      0  0  0  0  1  0    0  0  0  0  0  0  0 -1;
      0  0  0  0  0  1    0  0 -1  0  0  0  0  0;
      0  0  0  0  0  1    0  0  0  0 -1  0  0  0;]

model = Model(with_optimizer(Ipopt.Optimizer, print_level=0))
@variable(model, x[1:M + N,1:2])                     # A variable array for the coordinates of each point
@constraint(model, x[N + 1:N + M,:] .== fixed')      # We had a constraint for the fixed points
dist = A * x                                         # Matrix of differences between coordinates of 2 points with a link
@objective(model, Min, sum(dist .* dist))            # We minimize the sum of the square of the distances

optimize!(model)
@show value.(x);
@show objective_value(model);


n = 5;

Amin = [                                        # We'll try this problem with 4 times with different minimum area constraints
100 100 100 100 100;
 20  50  80 150 200;
180  80  80  80  80;
 20 150  20 200 110]

r = 1

for i = 1:4
    A = Amin[i,:]

    model = Model(with_optimizer(Ipopt.Optimizer, print_level=0))

    @variable(model, x[1:n] >= r)
    @variable(model, y[1:n] >= r)
    @variable(model, w[1:n] >= 0)
    @variable(model, h[1:n] >= 0)
    @variable(model, W)
    @variable(model, H)

    @constraint(model, x[5] + w[5] + r <= W)    # No rectangles at the right of Rectangle 5
    @constraint(model, x[1] + w[1] + r <= x[3]) # Rectangle 1 is at the left of Rectangle 3
    @constraint(model, x[2] + w[2] + r <= x[3]) # Rectangle 2 is at the left of Rectangle 3
    @constraint(model, x[3] + w[3] + r <= x[5]) # Rectangle 3 is at the left of Rectangle 5
    @constraint(model, x[4] + w[4] + r <= x[5]) # Rectangle 4 is at the left of Rectangle 5
    @constraint(model, y[4] + h[4] + r <= H)    # No rectangles on top of Rectangle 4
    @constraint(model, y[5] + h[5] + r <= H)    # No rectangles on top of Rectangle 5
    @constraint(model, y[2] + h[2] + r <= y[1]) # Rectangle 2 is below Rectangle 1
    @constraint(model, y[1] + h[1] + r <= y[4]) # Rectangle 1 is below Rectangle 4
    @constraint(model, y[3] + h[3] + r <= y[4]) # Rectangle 3 is below Rectangle 4
    @constraint(model, w .<= 5*h)               # Aspect ratio constraint
    @constraint(model, h .<= 5*w)               # Aspect ratio constraint
    @constraint(model, A .<= h .*  w)           # Area constraint

    @objective(model, Min, W + H)

    optimize!(model)
    @show objective_value(model);
end

