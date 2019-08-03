
using JuMP
using GLPK


# Define some input data about the test system
# Maximum power output of generators
const g_max = [1000, 1000];
# Minimum power output of generators
const g_min = [0, 300];
# Incremental cost of generators 
const c_g = [50, 100];
# Fixed cost of generators
const c_g0 = [1000, 0]
# Incremental cost of wind generators
const c_w = 50;
# Total demand
const d = 1500;
# Wind forecast
const w_f = 200;


# In this cell we create function solve_ed, which solves the economic dispatch problem for a given set of input parameters.
function solve_ed(g_max, g_min, c_g, c_w, d, w_f)
    #Define the economic dispatch (ED) model
    ed = Model(with_optimizer(GLPK.Optimizer))
    
    # Define decision variables    
    @variable(ed, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
    @variable(ed, 0 <= w <= w_f) # wind power injection

    # Define the objective function
    @objective(ed, Min, sum(c_g .* g) + c_w * w)

    # Define the constraint on the maximum and minimum power output of each generator
    @constraint(ed, [i = 1:2], g[i] <= g_max[i]) #maximum
    @constraint(ed, [i = 1:2], g[i] >= g_min[i]) #minimum

    # Define the constraint on the wind power injection
    @constraint(ed, w <= w_f)

    # Define the power balance constraint
    @constraint(ed, sum(g) + w == d)

    # Solve statement
    optimize!(ed)
    
    # return the optimal value of the objective function and its minimizers
    return value.(g), value(w), w_f - value(w), objective_value(ed)
end

# Solve the economic dispatch problem
(g_opt, w_opt, ws_opt, obj) = solve_ed(g_max, g_min, c_g, c_w, d, w_f);

println("\n")
println("Dispatch of Generators: ", g_opt, " MW")
println("Dispatch of Wind: ", w_opt, " MW")
println("Wind spillage: ", w_f - w_opt, " MW") 
println("\n")
println("Total cost: ", obj, "\$")


for c_g1_scale = 0.5:0.1:3.0
    c_g_scale = [c_g[1] * c_g1_scale, c_g[2]] # update the incremental cost of the first generator at every iteration
    g_opt, w_opt, ws_opt, obj = solve_ed(g_max, g_min, c_g_scale, c_w, d, w_f) # solve the ed problem with the updated incremental cost
    
    println("Dispatch of Generators, MW: $(g_opt[:])\n"*
            "Dispatch of Wind, MW: $w_opt\n"*
            "Spillage of Wind, MW: $ws_opt\n"*
            "Total cost, \$: $obj \n")
end


function solve_ed_inplace(c_w_scale)
    start = time()
    obj_out = Float64[]
    w_out = Float64[]
    g1_out = Float64[]
    g2_out = Float64[]
    
    ed = Model(with_optimizer(GLPK.Optimizer))
    
    # Define decision variables    
    @variable(ed, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
    @variable(ed, 0 <= w <= w_f ) # wind power injection

    # Define the objective function
    @objective(ed, Min, sum(c_g .* g) + c_w * w)

    # Define the constraint on the maximum and minimum power output of each generator
    @constraint(ed, [i = 1:2], g[i] <= g_max[i]) #maximum
    @constraint(ed, [i = 1:2], g[i] >= g_min[i]) #minimum

    # Define the constraint on the wind power injection
    @constraint(ed, w <= w_f)

    # Define the power balance constraint
    @constraint(ed, sum(g) + w == d)
    
    optimize!(ed)
    
    for c_g1_scale = 0.5:0.01:3.0
        @objective(ed, Min, c_g1_scale*c_g[1]*g[1] + c_g[2]*g[2] + c_w_scale*c_w*w)
        optimize!(ed)
        push!(obj_out, objective_value(ed))
        push!(w_out, value(w))
        push!(g1_out, value(g[1]))
        push!(g2_out, value(g[2]))
    end
    elapsed = time() - start
    print(string("elapsed time:", elapsed, "seconds"))
    return obj_out, w_out, g1_out, g2_out
end

solve_ed_inplace(2.0);


for demandscale = 0.2:0.1:1.5
    g_opt,w_opt,ws_opt,obj = solve_ed(g_max, g_min, c_g, c_w, demandscale*d, w_f)

    println("Dispatch of Generators, MW: $(g_opt[:])\n"*
            "Dispatch of Wind, MW: $w_opt\n"*
            "Spillage of Wind, MW: $ws_opt\n"*
            "Total cost, \$: $obj \n")
end


# In this cell we introduce binary decision u to the economic dispatch problem (function solve_ed)
function solve_uc(g_max, g_min, c_g, c_w, d, w_f)
    #Define the unit commitment (UC) model
    uc = Model(with_optimizer(GLPK.Optimizer))
    
    # Define decision variables    
    @variable(uc, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
    @variable(uc, u[i = 1:2], Bin) # Binary status of generators
    @variable(uc, 0 <= w <= w_f ) # wind power injection

    # Define the objective function
    @objective(uc, Min, sum(c_g .* g) + c_w * w)

    # Define the constraint on the maximum and minimum power output of each generator
    @constraint(uc, [i = 1:2], g[i] <= g_max[i]) #maximum
    @constraint(uc, [i = 1:2], g[i] >= g_min[i]) #minimum

    # Define the constraint on the wind power injection
    @constraint(uc, w <= w_f)

    # Define the power balance constraint
        @constraint(uc, sum(g) + w == d)

    # Solve statement
    optimize!(uc)
    
    status = termination_status(uc)
    return status, value.(g), value(w), w_f - value(w), value.(u), objective_value(uc)
end

# Solve the economic dispatch problem
status, g_opt, w_opt, ws_opt, u_opt, obj = solve_uc(g_max, g_min, c_g, c_w, d, w_f);

println("\n")
println("Dispatch of Generators: ", g_opt[:], " MW")
println("Commitments of Generators: ", u_opt[:])
println("Dispatch of Wind: ", w_opt, " MW")
println("Wind spillage: ", w_f - w_opt, " MW") 
println("\n")
println("Total cost: ", obj, "\$")


for demandscale = 0.2:0.1:1.5
    status, g_opt, w_opt, ws_opt, u_opt, obj = solve_uc(g_max, g_min, c_g, c_w, demandscale*d, w_f)
 
    if status == MOI.OPTIMAL
        println("Commitment of Generators, MW: $(u_opt[:])\n"*
                "Dispatch of Generators, MW: $(g_opt[:])\n"*
                "Dispatch of Wind, MW: $w_opt\n"*
                "Spillage of Wind, MW: $ws_opt\n"*
                "Total cost, \$: $obj \n")
    else
        println("Status: $status \n")
    end
end

