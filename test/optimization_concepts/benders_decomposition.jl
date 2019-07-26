
c1 = [-1; -4]
c2 = [-2; -3]

dimX = length(c1)
dimU = length(c2)

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

# Master Problem Description
# --------------------------

master_problem_model = Model(with_optimizer(GLPK.Optimizer))

# Variable Definition 
# ----------------------------------------------------------------
@variable(master_problem_model, 0 <= x[1:dimX] <= 1e6, Int) 
@variable(master_problem_model, t <= 1e6)

# Objective Setting
# -----------------
@objective(master_problem_model, Max, t)
global iter_num = 1

print(master_problem_model)


iter_num = 1

while(true)
    println("\n-----------------------")
    println("Iteration number = ", iter_num)
    println("-----------------------\n")
    println("The current master problem is")
    print(master_problem_model)
     
    optimize!(master_problem_model)
    
    t_status = termination_status(master_problem_model)
    p_status = primal_status(master_problem_model)
    
    if p_status == MOI.INFEASIBLE_POINT
        println("The problem is infeasible :-(")
        break
    end

    if t_status == MOI.INFEASIBLE_OR_UNBOUNDED
        fm_current = M
        x_current = M * ones(dimX)
    end

    if p_status == MOI.FEASIBLE_POINT
        fm_current = value(t)
        x_current = Float64[]
            for i in 1:dimX
            push!(x_current, value(x[i]))
        end
    end

    println("Status of the master problem is", t_status, 
            "\nwith fm_current = ", fm_current, 
            "\nx_current = ", x_current)

    sub_problem_model = Model(with_optimizer(GLPK.Optimizer))

    cSub = b - A1 * x_current

    @variable(sub_problem_model, u[1:dimU] >= 0)

    @constraint(sub_problem_model, constrRefSubProblem[j = 1:size(A2, 2)], sum(A2[i, j] * u[i] for i in 1:size(A2, 1)) >= c2[j])
    # The second argument of @constraint macro, constrRefSubProblem[j=1:size(A2,2)] means that the j-th constraint is
    # referenced by constrRefSubProblem[j]. 
    
    @objective(sub_problem_model, Min, dot(c1, x_current) + sum(cSub[i] * u[i] for i in 1:dimU))

    print("\nThe current subproblem model is \n", sub_problem_model)

    optimize!(sub_problem_model)

    t_status_sub = termination_status(sub_problem_model)
    p_status_sub = primal_status(sub_problem_model)

    fs_x_current = objective_value(sub_problem_model) 

    u_current = Float64[]

    for i in 1:dimU
        push!(u_current, value(u[i]))
    end

    γ = dot(b, u_current)

    println("Status of the subproblem is ", t_status_sub, 
        "\nwith fs_x_current = ", fs_x_current, 
        "\nand fm_current = ", fm_current) 
    
    if p_status_sub == MOI.FEASIBLE_POINT && fs_x_current == fm_current # we are done
        println("\n################################################")
        println("Optimal solution of the original problem found")
        println("The optimal objective value t is ", fm_current)
        println("The optimal x is ", x_current)
                println("The optimal v is ", dual.(constrRefSubProblem))
        println("################################################\n")
        break
    end  
    
    if p_status_sub == MOI.FEASIBLE_POINT && fs_x_current < fm_current
        println("\nThere is a suboptimal vertex, add the corresponding constraint")
        cv = A1' * u_current - c1
        @constraint(master_problem_model, t + sum(cv[i] * x[i] for i in 1:dimX) <= γ)
        println("t + ", cv, "ᵀ x <= ", γ)
    end 
    
    if t_status_sub == MOI.INFEASIBLE_OR_UNBOUNDED
        println("\nThere is an  extreme ray, adding the corresponding constraint")
        ce = A1'* u_current
        @constraint(master_problem_model, sum(ce[i] * x[i] for i in 1:dimX) <= γ)
        println(ce, "ᵀ x <= ", γ)
    end
    
    global iter_num += 1
end

