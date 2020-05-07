
using JuMP
using ECOS
using LinearAlgebra
using Random

Random.seed!(1234);

@testset "Test SecondOrderCone formulations" begin
    u0 = rand(10)
    p = rand(10)
    q = rand();

    optimal_value_soc = 0.7413476010760025
    @testset "Primal formulation" begin
        model = Model(optimizer_with_attributes(ECOS.Optimizer, "printlevel" => 0))
        @variable(model, u[1:10])
        @variable(model, t)
        @objective(model, Min, t)
        @constraint(model, [t, (u - u0)...] in SecondOrderCone())
        @constraint(model, u' * p == q)
        optimize!(model)
        @test JuMP.termination_status(model) == MOI.OPTIMAL
        @test objective_value(model) ≈ optimal_value_soc atol=1e-6
    end
    @testset "Dual formulation" begin
        e1 = [1, zeros(10)...]
        dual_model = Model(optimizer_with_attributes(ECOS.Optimizer, "printlevel" => 0))
        @variable(dual_model, y1 <= 0)
        @variable(dual_model, y2[1:11])
        @objective(dual_model, Max, q * y1 + dot(vcat(0, u0), y2))
        @constraint(dual_model, e1 - [0, p...] .* y1 - y2 .== 0)
        @constraint(dual_model, y2 in SecondOrderCone())
        optimize!(dual_model)
        @test JuMP.termination_status(model) == MOI.OPTIMAL
        @test objective_value(dual_model) ≈ optimal_value_soc atol=1e-6
    end
end

@testset "Test RotatedSecondOrderCone formulation" begin
    u0 = rand(10)
    p = rand(10)
    q = rand();
    model = Model(optimizer_with_attributes(ECOS.Optimizer, "printlevel" => 0))
    @variable(model, u[1:10])
    @variable(model, t)
    @objective(model, Min, t)
    @constraint(model, [t, 0.5, (u - u0)...] in RotatedSecondOrderCone())
    @constraint(model, u' * p == q)
    optimize!(model)
    @test JuMP.termination_status(model) == MOI.OPTIMAL
    @test objective_value(model) ≈ 0.5495962595148015 atol=1e-6
end

@testset "Test ExponentialCone formulations" begin
    n = 15;
    m = 10;
    A = randn(m, n);
    b = rand(m, 1);

    model = Model(optimizer_with_attributes(ECOS.Optimizer, "printlevel" => 0))
    @variable(model, t[1:n])
    @variable(model, x[1:n])
    @objective(model, Max, sum(t))
    @constraint(model, sum(x) == 1)
    @constraint(model, A * x .<= b )
    # Cannot use the exponential cone directly in JuMP, hence we use MOI to specify the set.
    @constraint(model, con[i = 1:n], [t[i], x[i], 1.0] in MOI.ExponentialCone())

    optimize!(model);
    @test objective_value(model) ≈ 2.708050207925179
    @test JuMP.termination_status(model) == MOI.OPTIMAL
end

