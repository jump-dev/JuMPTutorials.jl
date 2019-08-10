
using JuMP
using Ipopt
# for plots
using Gadfly
using DataFrames


x = rand(10)
a = rand(10)
b = rand()

projection = Model(with_optimizer(Ipopt.Optimizer, print_level=0))
@variable(projection, x0[1:10])
@objective(projection, Min, sum((x - x0) .* (x - x0))) # We minimize the square of the distance here
@constraint(projection, x0' * a == b)                  # Point must lie on the hyperplane

optimize!(projection)
@show objective_value(projection);
@show value.(x0);


A_1 = rand(10, 10)
A_2 = rand(10, 10)
b_1 = rand(10)
b_2 = rand(10)

polyhedra_distance = Model(with_optimizer(Ipopt.Optimizer, print_level=0))
@variable(polyhedra_distance, x[1:10])                       # Point closest on the first polyhedron
@variable(polyhedra_distance, y[1:10])                       # Point closest on the second polyhedron
@objective(polyhedra_distance, Min, sum((x - y) .* (x - y))) # We minimize the square of the distance here as above
@constraint(polyhedra_distance, A_1 * x .<= b_1)             # Point x must lie on the first polyhedron
@constraint(polyhedra_distance, A_2 * y .<= b_2)             # Point y must lie on the second polyhedron

optimize!(polyhedra_distance)
@show objective_value(polyhedra_distance);


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

placement = Model(with_optimizer(Ipopt.Optimizer, print_level=0))
@variable(placement, p[1:M + N, 1:2])                     # A variable array for the coordinates of each point
@constraint(placement, p[N + 1:N + M, :] .== fixed')      # We had a constraint for the fixed points
dist = A * p                                         # Matrix of differences between coordinates of 2 points with a link
@objective(placement, Min, sum(dist .* dist))            # We minimize the sum of the square of the distances

optimize!(placement)
@show value.(p);
@show objective_value(placement);


# Plotting the points
df = DataFrame()
df.x = value.(p)[:,1]
df.y = value.(p)[:,2]
df.type = vcat(fill("Free points", N), fill("Fixed points", M))
plt = plot(df, x = "x", y = "y", color = "type", Geom.point)
draw(SVG(6inch, 6inch), plt)


n = 5;

Amin = [                                        # We'll try this problem with 4 times with different minimum area constraints
100 100 100 100 100;
 20  50  80 150 200;
180  80  80  80  80;
 20 150  20 200 110]

r = 1

figs=[]

for i = 1:4
    A = Amin[i, :]

    floor_planning = Model(with_optimizer(Ipopt.Optimizer, print_level=0))

    @variable(floor_planning, x[1:n] >= r)
    @variable(floor_planning, y[1:n] >= r)
    @variable(floor_planning, w[1:n] >= 0)
    @variable(floor_planning, h[1:n] >= 0)
    @variable(floor_planning, W)
    @variable(floor_planning, H)

    @constraint(floor_planning, x[5] + w[5] + r <= W)    # No rectangles at the right of Rectangle 5
    @constraint(floor_planning, x[1] + w[1] + r <= x[3]) # Rectangle 1 is at the left of Rectangle 3
    @constraint(floor_planning, x[2] + w[2] + r <= x[3]) # Rectangle 2 is at the left of Rectangle 3
    @constraint(floor_planning, x[3] + w[3] + r <= x[5]) # Rectangle 3 is at the left of Rectangle 5
    @constraint(floor_planning, x[4] + w[4] + r <= x[5]) # Rectangle 4 is at the left of Rectangle 5
    @constraint(floor_planning, y[4] + h[4] + r <= H)    # No rectangles on top of Rectangle 4
    @constraint(floor_planning, y[5] + h[5] + r <= H)    # No rectangles on top of Rectangle 5
    @constraint(floor_planning, y[2] + h[2] + r <= y[1]) # Rectangle 2 is below Rectangle 1
    @constraint(floor_planning, y[1] + h[1] + r <= y[4]) # Rectangle 1 is below Rectangle 4
    @constraint(floor_planning, y[3] + h[3] + r <= y[4]) # Rectangle 3 is below Rectangle 4
    @constraint(floor_planning, w .<= 5*h)               # Aspect ratio constraint
    @constraint(floor_planning, h .<= 5*w)               # Aspect ratio constraint
    @constraint(floor_planning, A .<= h .*  w)           # Area constraint

    @objective(floor_planning, Min, W + H)

    optimize!(floor_planning)

    @show objective_value(floor_planning);

    D = DataFrame(x = value.(x), y = value.(y), x2 = value.(x) .+ value.(w), y2 = value.(y) .+ value.(h))
    plt = plot(D, xmin = :x, ymin = :y, xmax = :x2, ymax = :y2, Geom.rect)
    push!(figs, plt)
end


draw(SVG(6inch, 6inch), vstack(hstack(figs[1], figs[2]), hstack(figs[3], figs[4])))

