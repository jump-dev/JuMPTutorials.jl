
c1 = [-1; -4]
c2 = [-2; -3]

dim_x = length(c1)
dim_u = length(c2)

b = [-2; -3]

A1 = [1 -3;
     -1 -3]
A2 = [1 -2;
     -1 -1]

M = 1000;


# Loading the necessary packages
#-------------------------------
using JuMP 
using GLPK
using LinearAlgebra
using Test


function build_subproblem()
    sub_problem_model = Model(GLPK.Optimizer)
    @variable(sub_problem_model, u[1:dim_u] >= 0)
    @constraint(sub_problem_model, constr_ref_subproblem[j = 1:size(A2, 2)], dot(A2[:, j], u) >= c2[j])
    return (sub_problem_model, u)
end

# Master Problem Description
# --------------------------

master_problem_model = Model(GLPK.Optimizer)
(sub_problem_model, u) = build_subproblem()

# Variable Definition 
# ----------------------------------------------------------------
@variable(master_problem_model, 0 <= x[1:dim_x] <= 1e6, Int) 
@variable(master_problem_model, t <= 1e6)

# Objective Setting
# -----------------
@objective(master_problem_model, Max, t)

print(master_problem_model)


iter_num = 0


function benders_lazy_constraint_callback(cb_data)
    global iter_num
    iter_num += 1
    println("Iteration number = ", iter_num)

    x_current = [callback_value(cb_data, x[j]) for j in eachindex(x)]
    fm_current = callback_value(cb_data, t)
    
    c_sub = b - A1 * x_current
    @objective(sub_problem_model, Min, dot(c1, x_current) + dot(c_sub, u))
    optimize!(sub_problem_model)

    print("\nThe current subproblem model is \n", sub_problem_model)

    t_status_sub = termination_status(sub_problem_model)
    p_status_sub = primal_status(sub_problem_model)

    fs_x_current = objective_value(sub_problem_model) 

    u_current = value.(u)

    γ = dot(b, u_current)
    
    if p_status_sub == MOI.FEASIBLE_POINT && fs_x_current  ≈  fm_current # we are done
        @info("No additional constraint from the subproblem")
        # println("Optimal solution of the original problem found")
        # println("The optimal objective value t is ", fm_current)
        # println("The optimal x is ", x_current)
        # println("The optimal v is ", dual.(constr_ref_subproblem))
    end 
    
    if p_status_sub == MOI.FEASIBLE_POINT && fs_x_current < fm_current
        println("\nThere is a suboptimal vertex, add the corresponding constraint")
        cv = A1' * u_current - c1
        new_optimality_cons = @build_constraint(t + dot(cv, x) <= γ)
        MOI.submit(master_problem_model, MOI.LazyConstraint(cb_data), new_optimality_cons)
    end 
    
    if t_status_sub == MOI.INFEASIBLE_OR_UNBOUNDED
        println("\nThere is an  extreme ray, adding the corresponding constraint")
        ce = A1' * u_current
        new_feasibility_cons = @build_constraint(dot(ce, x) <= γ)
        MOI.submit(master_problem_model, MOI.LazyConstraint(cb_data), new_feasibility_cons)
    end
end

MOI.set(master_problem_model, MOI.LazyConstraintCallback(), benders_lazy_constraint_callback)
     
optimize!(master_problem_model)
    
t_status = termination_status(master_problem_model)
p_status = primal_status(master_problem_model)

if p_status == MOI.INFEASIBLE_POINT
    println("The problem is infeasible :-(")
end

if t_status == MOI.INFEASIBLE_OR_UNBOUNDED
    fm_current = M
    x_current = M * ones(dim_x)
end

if p_status == MOI.FEASIBLE_POINT
    fm_current = value(t)
    x_current = Float64[]
        for i in 1:dim_x
        push!(x_current, value(x[i]))
    end
end

println("Status of the master problem is ", t_status, 
        "\nwith fm_current = ", fm_current, 
        "\nx_current = ", x_current)

@test value(t) ≈ -4



