using JuMPTutorials
using Test

cd("introduction")
@testset "Introduction" begin
include("introduction/an_introduction_to_julia.jl")
include("introduction/getting_started_with_JuMP.jl")
@test objective_value(model) ≈ 205
include("introduction/variables_constraints_objective.jl")
@test objective_value(vector_model) ≈ 4.9230769230769225
include("introduction/solvers_and_solutions.jl")
end
cd("..")

cd("using_JuMP")
@testset "Using JuMP" begin
include("using_JuMP/working_with_data_files.jl")
@test objective_value(model) == 23
@test countryindex == [1, 5, 9, 10, 38, 39, 55, 63, 64, 75, 78, 81, 89, 104, 107, 130, 138, 158, 162, 167, 182, 188, 190]
include("using_JuMP/problem_modification.jl")
end
cd("..")

cd("optimization_concepts")
@testset "Optimization Concepts" begin
include("optimization_concepts/benders_decomposition.jl")
include("optimization_concepts/integer_programming.jl")
include("optimization_concepts/conic_programming.jl")
end
cd("..")

cd("modelling")
@testset "Modelling Examples" begin
include("modelling/sudoku.jl")
@test sol == [
    5  3  4  6  7  8  9  1  2;
    6  7  2  1  9  5  3  4  8;
    1  9  8  3  4  2  5  6  7;
    8  5  9  7  6  1  4  2  3;
    4  2  6  8  5  3  7  9  1;
    7  1  3  9  2  4  8  5  6;
    9  6  1  5  3  7  2  8  4;
    2  8  7  4  1  9  6  3  5;
    3  4  5  2  8  6  1  7  9]
include("modelling/problems_on_graphs.jl")
@test value.(y) == [0.0, 1.0, 1.0, 1.0, 0.0, 0.0]
@test value.(x) == [0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0]
@test value.(m) == [
    0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0;
    0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
    1.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0;
    0.0 1.0 0.0 0.0 0.0 0.0 0.0 0.0;
    0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0;
    0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0]
@test value.(z) == [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0]
@test c == [
    0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
    0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0;
    0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0;
    0.0 0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0 0.0]
include("modelling/network_flows.jl")
@test objective_value(shortest_path) == 55.0
@test value.(x) == [
    0.0 0.0 1.0 0.0 0.0;
    0.0 0.0 0.0 0.0 0.0;
    0.0 0.0 0.0 1.0 0.0; 
    0.0 1.0 0.0 0.0 0.0;
    0.0 0.0 0.0 0.0 0.0]
@test objective_value(assignment) == 20.0
@test value.(y) == [0.0 1.0 0.0 0.0; 0.0 0.0 1.0 0.0; 1.0 0.0 0.0 0.0; 0.0 0.0 0.0 1.0]
@test objective_value(max_flow) == 6.0
@test value.(f) == [
    0.0 3.0 2.0 1.0 0.0 0.0 0.0 0.0; 
    0.0 0.0 0.0 0.0 3.0 0.0 0.0 0.0; 
    0.0 0.0 0.0 0.0 1.0 0.0 1.0 0.0; 
    0.0 0.0 0.0 0.0 0.0 1.0 0.0 0.0; 
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 4.0; 
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0; 
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 1.0; 
    0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0]
include("modelling/finance.jl")
@test objective_value(financing) ≈ 92.49694915254233
@test objective_value(auction) == 21.0
@test value.(y) == [1.0, 1.0, 1.0, 0.0, 0.0, 0.0]
@test objective_value(portfolio) ≈ 22634.41784988414
@test value.(x) ≈ [497.0455298498642, 0.0, 502.95448015948074]
include("modelling/power_systems.jl")
@test g_opt == [1000.0, 300.0]
@test w_opt == 200.0
@test w_f - w_opt == 0
@test obj == 90000.0
include("modelling/geometric_problems.jl")
@test value.(p) ≈ [
     0.44790964261631827    0.0468981793661497; 
    -0.03193526635198919   -0.6706136210384356; 
     0.404335805799056     -0.45130815913688466; 
    -0.39429534726904925   -0.13282535401213758; 
     0.02532703978422118    0.4124207687120701; 
    -0.0016520566419420052 -0.43954821308159137; 
     1.0         1.0; 
     1.0        -1.0; 
    -1.0        -1.0; 
    -1.0         1.0; 
     1.0        -0.5; 
    -1.0        -0.2; 
    -0.2        -1.0; 
     0.1         1.0]
end
cd("..")