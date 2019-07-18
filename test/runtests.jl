using JuMPTutorials
using Test

cd("introduction")
@testset "Introduction" begin
include("introduction/an_introduction_to_julia.jl")
include("introduction/getting_started_with_JuMP.jl")
@test objective_value(model) ≈ 205
include("introduction/variables_constraints_objective.jl")
include("introduction/solvers_and_solutions.jl")
end
cd("..")

cd("using_JuMP")
@testset "Using JuMP" begin
include("using_JuMP/working_with_data_files.jl")
include("using_JuMP/problem_modification.jl")
end
cd("..")

cd("optimization_concepts")
@testset "Optimization Concepts" begin
include("optimization_concepts/integer_programming.jl")
include("optimization_concepts/conic_programming.jl")
end
cd("..")

cd("modelling")
@testset "Modelling Examples" begin
include("modelling/finance.jl")
include("modelling/geometric_problems.jl")
include("modelling/network_flows.jl")
include("modelling/problems_on_graphs.jl")
end
cd("..")