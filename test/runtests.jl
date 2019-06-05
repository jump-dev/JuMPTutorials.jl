using JuMPTutorials
using Test

@testset "JuMPTutorials.jl" begin
include("introduction/an_introduction_to_julia.jl")
include("introduction/getting_started_with_JuMP.jl")
include("introduction/variables_constraints_objective.jl")
include("introduction/solvers_and_solutions.jl")
end
