
#push!(Base.LOAD_PATH,"D:\\MOI")


using JuMP
using GLPK
using MathOptInterface
const MOI = MathOptInterface
using Interact # used for enabling the slider
#using Gadfly # used for plotting


# Define some input data about the test system
# Maximum power output of generators
const g_max = [1000,1000];
# Minimum power output of generators
const g_min = [0,300];
# Incremental cost of generators 
const c_g = [50,100];
# Fixed cost of generators
const c_g0 = [1000,0]
# Incremental cost of wind generators
const c_w = 50;
# Total demand
const d = 1500;
# Wind forecast
const w_f = 200;


# In this cell we create  function solve_ed, which solves the economic dispatch problem for a given set of input parameters.
function solve_ed(g_max, g_min, c_g, c_w, d, w_f)
    #Define the economic dispatch (ED) model
    ed=Model(optimizer = GLPK.GLPKOptimizerLP()) 
    
    # Define decision variables    
    @variable(ed, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
    @variable(ed, 0 <= w  <= w_f ) # wind power injection

    # Define the objective function
    @objective(ed,Min,sum(c_g[i] * g[i] for i in 1:2)+ c_w * w)

    # Define the constraint on the maximum and minimum power output of each generator
    for i in 1:2
        @constraint(ed,  g[i] <= g_max[i]) #maximum
        @constraint(ed,  g[i] >= g_min[i]) #minimum
    end

    # Define the constraint on the wind power injection
    @constraint(ed, w <= w_f)

    # Define the power balance constraint
    @constraint(ed, sum(g[i] for i in 1:2) + w == d)

    # Solve statement
    JuMP.optimize(ed)
    
    # return the optimal value of the objective function and its minimizers
    return JuMP.resultvalue.(g), JuMP.resultvalue(w), w_f-JuMP.resultvalue(w), JuMP.objectivevalue(ed)
end

# Solve the economic dispatch problem
(g_opt,w_opt,ws_opt,obj)=solve_ed(g_max, g_min, c_g, c_w, d, w_f);

println("\n")
println("Dispatch of Generators: ", g_opt[i=1:2], " MW")
println("Dispatch of Wind: ", w_opt, " MW")
println("Wind spillage: ", w_f-w_opt, " MW") 
println("\n")
println("Total cost: ", obj, "\$")


# This cell uses the package Interact defined above. 
# In this cell we create a manipulator that solves the economic dispatch problem for different values of c_g1_scale.

#@manipulate 
for c_g1_scale = 0.5:0.1:3.0
    c_g_scale = [c_g[1]*c_g1_scale, c_g[2]] # update the incremental cost of the first generator at every iteration
    g_opt,w_opt,ws_opt,obj = solve_ed(g_max, g_min, c_g_scale, c_w, d, w_f) # solve the ed problem with the updated incremental cost
    
    #HTML("Dispatch of Generators, MW: $(g_opt[:])<br>"*
    #"Dispatch of Wind, MW: $w_opt<br>"*
    #"Spillage of Wind, MW: $ws_opt<br>"*
    #"Total cost, \$: $obj")
    
    println("Dispatch of Generators, MW: $(g_opt[:])\n"*
    "Dispatch of Wind, MW: $w_opt\n"*
    "Spillage of Wind, MW: $ws_opt\n"*
    "Total cost, \$: $obj")
end


function solve_ed_inplace(c_w_scale)
    tic()
    obj_out = Float64[]
    w_out = Float64[]
    g1_out = Float64[]
    g2_out = Float64[]
    
    ed=Model(optimizer = GLPK.GLPKOptimizerLP()) 
    
    # Define decision variables    
    @variable(ed, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
    @variable(ed, 0 <= w  <= w_f ) # wind power injection

    # Define the objective function
    @objective(ed,Min,sum(c_g[i] * g[i] for i in 1:2) + c_w * w)

    # Define the constraint on the maximum and minimum power output of each generator
    for i in 1:2
        @constraint(ed,  g[i] <= g_max[i]) #maximum
        @constraint(ed,  g[i] >= g_min[i]) #minimum
    end


    # Define the constraint on the wind power injection
    @constraint(ed, w <= w_f)

    # Define the power balance constraint
    @constraint(ed, sum(g[i] for i in 1:2) + w == d)
    JuMP.optimize(ed)
    
    for c_g1_scale = 0.5:0.01:3.0
        @objective(ed, Min, c_g1_scale*c_g[1]*g[1] + c_g[2]*g[2] + c_w_scale*c_w*w)
        JuMP.optimize(ed)
        push!(obj_out,JuMP.objectivevalue(ed))
        push!(w_out,JuMP.resultvalue(w))
        push!(g1_out,JuMP.resultvalue(g[1]))
        push!(g2_out,JuMP.resultvalue(g[2]))
    end
    toc()
    return obj_out, w_out, g1_out, g2_out
end
solve_ed_inplace(2.0);


#@manipulate 
for demandscale = 0.2:0.1:1.5
    g_opt,w_opt,ws_opt,obj = solve_ed(g_max, g_min, c_g, c_w, demandscale*d, w_f)
    
    #=html("Dispatch of Generators, MW: $(g_opt[:])<br>"*
    "Dispatch of Wind, MW: $w_opt<br>"*
    "Spillage of Wind, MW: $ws_opt<br>"*
    "Total cost, \$: $obj")
    =#
    println("Dispatch of Generators, MW: $(g_opt[:])\n"*
    "Dispatch of Wind, MW: $w_opt\n"*
    "Spillage of Wind, MW: $ws_opt\n"*
    "Total cost, \$: $obj")
    
end


# In this cell we introduce binary decision u to the economic dispatch problem (function solve_ed)
function solve_uc(g_max, g_min, c_g, c_w, d, w_f)
    #Define the unit commitment (UC) model
    uc=Model(optimizer = GLPK.GLPKOptimizerMIP()) 
    
    # Define decision variables    
    @variable(uc, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
    @variable(uc, u[i=1:2], Bin) # Binary status of generators
    @variable(uc, 0 <= w  <= w_f ) # wind power injection

    # Define the objective function
    @objective(uc,Min,sum(c_g[i] * g[i] for i in 1:2) + c_w * w)

    # Define the constraint on the maximum and minimum power output of each generator
    for i in 1:2
        @constraint(uc,  g[i] <= g_max[i] * u[i]) #maximum
        @constraint(uc,  g[i] >= g_min[i] * u[i]) #minimum
    end

    # Define the constraint on the wind power injection
    @constraint(uc, w <= w_f)

    # Define the power balance constraint
        @constraint(uc, sum(g[i] for i in 1:2) + w == d)

    # Solve statement
    JuMP.optimize(uc)
    
    status = JuMP.terminationstatus(uc)
    return status, JuMP.resultvalue.(g), JuMP.resultvalue(w), w_f-JuMP.resultvalue(w), JuMP.resultvalue.(u), JuMP.objectivevalue(uc)
end

# Solve the economic dispatch problem
status,g_opt,w_opt,ws_opt,u_opt,obj=solve_uc(g_max, g_min, c_g, c_w, d, w_f);

  
println("\n")
println("Dispatch of Generators: ", g_opt[:], " MW")
println("Commitments of Generators: ", u_opt[:])
println("Dispatch of Wind: ", w_opt, " MW")
println("Wind spillage: ", w_f-w_opt, " MW") 
println("\n")
println("Total cost: ", obj, "\$")


#@manipulate 
for demandscale = 0.2:0.1:1.5
    status, g_opt,w_opt,ws_opt, u_opt, obj = solve_uc(g_max, g_min, c_g, c_w, demandscale*d, w_f)
 
    if status == MOI.Success
        #=html("Commitment of Generators, MW: $(u_opt[:])<br>"*
    "Dispatch of Generators, MW: $(g_opt[:])<br>"*
    "Dispatch of Wind, MW: $w_opt<br>"*
    "Spillage of Wind, MW: $ws_opt<br>"*
    "Total cost, \$: $obj")=#
        println("Commitment of Generators, MW: $(u_opt[:])\n"*
    "Dispatch of Generators, MW: $(g_opt[:])\n"*
    "Dispatch of Wind, MW: $w_opt\n"*
    "Spillage of Wind, MW: $ws_opt\n"*
    "Total cost, \$: $obj")
    else
        #html("Status: $status")
        println("Status: $status")
    end
end


# In this cell we redefine the UC model to account for the no-load cost

function solve_uc_nlc(g_max, g_min, c_g, c_w, d, w_f, c_g0)
#Define the unit commitment (UC) model
    uc=Model(optimizer = GLPK.GLPKOptimizerMIP()) 
    
# Define decision variables    
@variable(uc, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
@variable(uc, u[i=1:2], Bin) # Binary status of generators
@variable(uc, 0 <= w  <= w_f ) # wind power injection

# Define the objective function
    @objective(uc,Min,sum(c_g[i] * g[i] for i in 1:2)+ c_w * w + sum(c_g0[i] * u[i] for i in 1:2))

# Define the constraint on the maximum and minimum power output of each generator
for i in 1:2
    @constraint(uc,  g[i] <= g_max[i] * u[i]) #maximum
    @constraint(uc,  g[i] >= g_min[i] * u[i]) #minimum
end


# Define the constraint on the wind power injection
@constraint(uc, w <= w_f)

# Define the power balance constraint
@constraint(uc, sum(g[i] for i in 1:2) + w == d)

# Solve statement
JuMP.optimize(uc)

status = JuMP.terminationstatus(uc)
                
                
return status, JuMP.resultvalue(g), JuMP.resultvalue.(w), w_f-JuMP.resultvalue.(w), JuMP.resultvalue.(u), JuMP.objectivevalue(uc)
end



