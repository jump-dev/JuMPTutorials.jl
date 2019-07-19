#' 
#' ## Disclaimer
#' This notebook is only working under the versions:
#' 
#' - JuMP 0.19 (unreleased, but currently in master)
#' 
#' - MathOptInterface 0.4.1
#' 
#' - GLPK 0.6.0
#' #' 
#' **Description**: This notebook demonstrates how to formulate basic power systems engineering models in JuMP using a 3 bus example. We will consider basic "economic dispatch" and "unit commitment" models without taking into account transmission constraints.
#' 
#' This notebook was developed for the [Grid Science Winter School](http://www.cvent.com/events/grid-science-winter-school-conference/event-summary-229c17f488194f2ebb5b206820974c71.aspx) held in Santa Fe, NM in January 2015.
#' 
#' Note that the notebook contains many interactive features which do not display correctly on read-only links. For the full experience, run this notebook locally or on [JuliaBox](https://juliabox.org/).
#' 
#' **Authors**: Yury Dvorkin and Miles Lubin
#' 
#' **License**: <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>.
#' #' 
#' ## Illustrative example
#' #' 
#' In the following notes for the sake of simplicity, we are going to use a three bus example mirroring the interface between Western and Eastern Texas. This example is taken from R. Baldick, "[Wind and Energy Markets: A Case Study of Texas](http://dx.doi.org/10.1109/JSYST.2011.2162798)," IEEE Systems Journal, vol. 6, pp. 27-34, 2012. 
#' #' 
#' <img src="http://i57.tinypic.com/2hn530x.png">
#' #' 
#' For this example, we set the following characteristics of generators, transmission lines, wind farms and demands:
#' <table style="width:25%">
#'   <tr>
#'     <td></td>
#'     <td>Generator 1</td> 
#'     <td>Generator 2</td>
#'   </tr>
#'   <tr>
#'     <td>$g_{min}$, MW</td>
#'     <td>0</td> 
#'     <td>300</td> 
#'   </tr>
#'   
#'    <tr>
#'     <td>$g_{max}$, MW</td>
#'     <td>1000</td> 
#'     <td>1000</td> 
#'   </tr>
#'   <tr>
#'     <td>$c^g$, \$/MWh</td>
#'     <td>50</td> 
#'     <td>100</td> 
#'   </tr>
#'   <tr>
#'     <td>$c^{g0}$, \$/MWh</td>
#'     <td>1000</td> 
#'     <td>0</td> 
#'   </tr> 
#' </table>
#' 
#' <table style="width:25%">
#'   <tr>
#'     <td></td>
#'     <td>Line 1</td> 
#'     <td>Line 2</td>
#'   </tr>
#'   <tr>
#'     <td>$f^{max}$, MW</td>
#'     <td>100</td> 
#'     <td>1000</td> 
#'   </tr>
#'   <tr>
#'     <td>x, p.u.</td>
#'     <td>0.001</td> 
#'     <td>0.001</td> 
#'   </tr>
#' </table>
#' 
#' <table style="width:25%">
#'   <tr>
#'     <td></td>
#'     <td>Wind farm 1</td> 
#'     <td>Wind farm 2</td>
#'   </tr>
#'   <tr>
#'     <td>$w^{f}$, MW</td>
#'     <td>150</td> 
#'     <td>50</td> 
#'   </tr>
#'   <tr>
#'   <td>$c^{w}$, \$/MWh</td>
#'     <td>50</td> 
#'     <td>50</td> 
#'   </tr>
#' </table>
#' 
#' <table style="width:25%">
#'   <tr>
#'     <td></td>
#'     <td>Bus 1</td> 
#'     <td>Bus 2</td>
#'     <td>Bus 3</td>
#'   </tr>
#'   <tr>
#'     <td>$d$, MW</td>
#'     <td>0</td> 
#'     <td>0</td> 
#'     <td>15000</td> 
#'     
#'   </tr>
#' </table>
#' #' 
#' ## Economic dispatch
#' #' 
#' Economic dispatch (ED) is an optimization problem that minimizes the cost of supplying energy demand subject to operational constraints on power system assets. In its simplest modification, ED is an LP problem solved for an aggregated load and wind forecast and for a single infinitesimal moment. Mathematically, the ED problem can be written as follows:
#' $$
#' \min \sum_{i \in I} c^g_{i} \cdot g_{i} + c^w \cdot w,
#' $$
#' where $c_{i}$ and $g_{i}$ are the incremental cost ($\$/MWh$) and power output ($MW$) of the $i^{th}$ generator, respectively, and $c^w$ and $w$ are the incremental cost ($\$/MWh$) and wind power injection ($MW$), respectively.
#' 
#' s.t.
#' 
#' <li> Minimum ($g^{\min}$) and maximum ($g^{\max}$) limits on power outputs of generators: </li>
#' $$
#' g^{\min}_{i} \leq g_{i} \leq g^{\max}_{i}.
#' $$
#' <li>Constraint on the wind power injection:</li>
#' $$
#' 0 \leq w \leq w^f, 
#' $$
#' where $w$ and $w^f$ are the wind power injection and wind power forecast, respectively.
#' 
#' <li>Power balance constraint:</li>
#' $$
#' \sum_{i \in I} g_{i} + w = d^f, 
#' $$
#' where $d^f$ is the demand forecast.
#' 
#' Further reading on ED models can be found in A. J. Wood, B. F. Wollenberg, and G. B. Sheblé, "Power Generation, Operation and Control", Wiley, 2013.
#' #' 
#' ## JuMP Implementation of Economic Dispatch 
#' 
#+ 

#push!(Base.LOAD_PATH,"D:\\MOI")


#+ 

using JuMP
using GLPK
using MathOptInterface
const MOI = MathOptInterface
using Interact # used for enabling the slider
#using Gadfly # used for plotting


#+ 

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


#+ 

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

#' 
#' ### Economic dispatch with adjustable incremental costs
#' #' 
#' In the following exercise we adjust the incremental cost of generator G1 and observe its impact on the total cost by using the manipulator
#' 
#+ 

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

#' 
#' #### Impact of the wind generation cost 
#' #' 
#' In the following exercise we introduce a new manipulator to vary the cost of wind generation and observe its impact the total cost, dispatch of generators G1 and G2, utilization of available wind under different values of the incremental cost of generator G1.
#' #' 
#' @manipulate for c_w_scale = 1:0.1:3.5
#'     # Define the vectors of outputs
#'     obj_out = Float64[] 
#'     w_out = Float64[]
#'     g1_out = Float64[]
#'     g2_out = Float64[]
#'     
#'     @time for c_g1_scale = 0.5:0.01:3.0
#'         c_g_scale = [c_g[1]*c_g1_scale, c_g[2]] # update the incremental cost of the first generator at every iteration
#'         g_opt,w_opt,ws_opt,obj = solve_ed(g_max, g_min, c_g_scale, c_w_scale*c_w, d, w_f) # solve the ed problem with the updated incremental cost
#'         # Add the solution of the economic dispatch problem to the respective vectors
#'         push!(obj_out,obj)
#'         push!(w_out,w_opt)
#'         push!(g1_out,g_opt[1])
#'         push!(g2_out,g_opt[2])
#'     end
#'     
#'     # Plot the outputs
#'     # Define the size of the plots
#'     set_default_plot_size(16cm, 30cm)
#'     
#'     vstack(
#'     # Plot the total cost
#'     plot(x=0.5:0.01:3.0,y=obj_out, Geom.line,
#'     Guide.XLabel("c_g1_scale"), Guide.YLabel("Total cost, \$"),
#'     Scale.y_continuous(minvalue=50000, maxvalue=200000)),
#'     # Plot the power output of Generator 1
#'     plot(x=0.5:0.01:3.0,y=g1_out, Geom.line,
#'     Guide.XLabel("c_g1_scale"), Guide.YLabel("Dispatch of  G1, MW"),
#'     Scale.y_continuous(minvalue=0, maxvalue=1100)),
#'     # Plot the power output of Generator 2    
#'     plot(x=0.5:0.01:3.0,y=g2_out, Geom.line,
#'     Guide.XLabel("c_g1_scale"), Guide.YLabel("Dispatch of  G2, MW"),
#'     Scale.y_continuous(minvalue=0, maxvalue=1600)),
#'     # Plot the wind power output
#'     plot(x=0.5:0.01:3.0,y=w_out, Geom.line,
#'     Guide.XLabel("c_g1_scale"), Guide.YLabel("Dispatch of Wind, MW"),
#'     Scale.y_continuous(minvalue=0, maxvalue=250))
#'     )
#' end
#' #' 
#' For further reading on the impact of wind generation costs on dispatch decisions, we refer interested readers to J. M. Morales, A. J. Conejo, and J. Perez-Ruiz, "Economic Valuation of Reserves in Power Systems With High Penetration of Wind Power," IEEE Transactions on Power Systems, vol. 24, pp. 900-910, 2009.
#' #' 
#' ## Modifying the JuMP model in place
#' #' 
#' Note that in the previous exercise we entirely rebuilt the optimization model at every iteration of the internal loop, which incurs an additional computational burden. This burden can be alleviated if instead of re-building the entire model, we modify a specific constraint(s) or the objective function, as it shown in the example below.
#' 
#' Compare the computing time in case of the above and below models. 
#' 
#+ 

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

#' 
#' Adjusting specific constraints and/or the objective function is faster than re-building the entire model.
#' #' 
#' ## A few practical limitations of the economic dispatch model
#' #' 
#' ### Inefficient usage of wind generators
#' #' 
#' The economic dispatch problem does not perform commitment decisions and, thus, assumes that all generators must be dispatched at least at their minimum power output limit. This approach is not cost efficient and may lead to absurd decisions. For example, if $ d = \sum_{i \in I} g^{\min}_{i}$, the wind power injection must be zero, i.e. all available wind generation is spilled, to meet the minimum power output constraints on generators. 
#' 
#' In the following example, we adjust the total demand and observed how it affects wind spillage.
#' 
#' 
#' 
#' 
#' 
#+ 

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

#' 
#' This particular drawback can be overcome by introducing binary decisions on the "on/off" status of generators. This model is called unit commitment and considered later in these notes. 
#' 
#' For further reading on the interplay between wind generation and the minimum power output constraints of generators, we refer interested readers to R. Baldick, "Wind and Energy Markets: A Case Study of Texas," IEEE Systems Journal, vol. 6, pp. 27-34, 2012.
#' #' 
#' ### Transmission-infeasible solution
#' #' 
#' The ED solution is entirely market-based and disrespects limitations of the transmission network. Indeed, the flows in transmission lines would attain the following values:
#' 
#' $$f_{1-2} = 150 MW \leq f_{1-2}^{\max} = 100 MW $$
#' 
#' $$f_{2-3} = 1200 MW \leq f_{2-3}^{\max} = 1000 MW $$
#' 
#' 
#' Thus, if this ED solution was enforced in practice, the power flow limits on both lines would be violated. Therefore, in the following section we consider the optimal power flow model, which amends the ED model with network constraints.
#' 
#' The importance of the transmission-aware decisions is emphasized in E. Lannoye, D. Flynn, and M. O'Malley, "Transmission, Variable Generation, and Power System Flexibility," IEEE Transactions on Power Systems, vol. 30, pp. 57-66, 2015.
#' #' 
#' ## Unit Commitment model 
#' #' 
#' The Unit Commitment (UC) model can be obtained from ED model by introducing binary variable associated with each generator. This binary variable can attain two values: if it is "1", the generator is synchronized and, thus, can be dispatched, otherwise, i.e. if the binary variable is "0", that generator is not synchronized and its power output is set to 0.
#' 
#' To obtain the mathematical formulation of the UC model, we will modify the constraints of the ED model as follows:
#' $$
#' g^{\min}_{i} \cdot u_{t,i} \leq g_{i} \leq g^{\max}_{i} \cdot u_{t,i},
#' $$
#' 
#' where $ u_{i} \in \{0;1\}. $ In this constraint, if $ u_{i} = 0$, then $g_{i}  = 0$. On the other hand, if $ u_{i} = 1$, then $g^{max}_{i} \leq g_{i}   \leq g^{min}_{i}$.
#' 
#' For further reading on the UC problem we refer interested readers to G. Morales-Espana, J. M. Latorre, and A. Ramos, "Tight and Compact MILP Formulation for the Thermal Unit Commitment Problem," IEEE Transactions on Power Systems, vol. 28, pp. 4897-4908, 2013.
#' #' 
#' In the following example we convert the ED model explained above to the UC model.
#' 
#+ 

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

#' 
#' ### Unit Commitment as a function of demand
#' #' 
#' After implementing the UC model, we can now assess the interplay between the minimum power output constraints on generators and wind generation.
#' 
#+ 

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

#' 
#' ### Unit Commitment with different wind availability
#' #' 
#' In the following experiment, we use a manipulator for adjusting demand and observe the different dispatch decisions under different wind generation conditions.
#' #' 
#' @manipulate for demandscale = 0.2:0.05:1.45
#'     w_out = Float64[]
#'     g1_out = Float64[]
#'     g2_out = Float64[]
#'     
#'     for w_f_scale = 0.5:0.05:5
#'         status, g_opt,w_opt,ws_opt, u_opt, obj = solve_uc(g_max, g_min, c_g, c_w, demandscale*d, w_f*w_f_scale)
#'         push!(g1_out,g_opt[1])
#'         push!(g2_out,g_opt[2])
#'         push!(w_out,w_opt)
#'     end
#'     
#'     set_default_plot_size(16cm, 30cm)
#'     
#'     vstack(
#'     # Plot the power output of Generator 1
#'     plot(x=0.5:0.05:2,y=g1_out[1:length(0.5:0.05:2)], Geom.line,
#'     Guide.XLabel("w_f_scale "), Guide.YLabel("Dispatch of  G1, MW")),
#'     # Plot the power output of Generator 2    
#'     plot(x=0.5:0.05:5,y=g2_out, Geom.line,
#'     Guide.XLabel("w_f_scale "), Guide.YLabel("Dispatch of  G2, MW")),
#'     # Plot the wind power output
#'     plot(x=0.5:0.05:5,y=w_out, Geom.line,
#'     Guide.XLabel("w_f_scale "), Guide.YLabel("Dispatch of Wind, MW")),
#'     )  
#' end
#' #' 
#' ### Unit Commitment with no load cost
#' #' 
#' Like power output decisions ($g_i$), binary commitment decisions ($u_i$) can also be priced in the objective function. The physical interpretation of the cost incurred by binary commitment decisions is no-load component of the operating cost.
#' 
#' This is implementing in the following example.
#' 
#+ 

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

#' 
#' Using the model above, we can now assess the sensitivity of the UC solution to demand under different levels of the minimum power output limits.
#' #' 
#' @manipulate for demandscale = 0.2:0.05:1.45
#'     w_out = Float64[]
#'     g1_out = Float64[]
#'     g2_out = Float64[]
#'     
#'     for pmin_scale = 0.0:0.05:3
#'         status, g_opt,w_opt,ws_opt, u_opt, obj = solve_uc_nlc(g_max, pmin_scale*g_min, c_g, c_w, demandscale*d, w_f, c_g0)
#'         push!(g1_out,g_opt[1])
#'         push!(g2_out,g_opt[2])
#'         push!(w_out,w_opt)
#'     end
#'     
#'     
#'     #set_default_plot_size(16cm, 30cm)
#'     #vstack(
#'     ## Plot the power output of Generator 1
#'     #plot(x=0.0:0.05:3,y=g1_out, Geom.line,
#'     #Guide.XLabel("w_f_scale "), Guide.YLabel("Dispatch of  G1, MW")),
#'     ## Plot the power output of Generator 2    
#'     #plot(x=0.0:0.05:3,y=g2_out, Geom.line,
#'     #Guide.XLabel("w_f_scale "), Guide.YLabel("Dispatch of  G2, MW")),
#'     ## Plot the wind power output
#'     #plot(x=0.0:0.05:3,y=w_out, Geom.line,
#'     #Guide.XLabel("w_f_scale "), Guide.YLabel("Dispatch of Wind, MW")),
#'     #)
#'     
#' end
#' 
#+ 


