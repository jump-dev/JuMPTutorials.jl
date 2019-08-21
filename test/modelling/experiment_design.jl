
using JuMP
using SCS
using LinearAlgebra

q = 4 # dimension of estimate space
p = 8 # number of experimental vectors
nmax = 3 # upper bound on lambda
n = 12 

V = randn(q, p)

eye = Matrix{Float64}(I, q, q);


aOpt = Model(with_optimizer(SCS.Optimizer, verbose = 0))
@variable(aOpt, np[1:p], lower_bound = 0, upper_bound = nmax)
@variable(aOpt, u[1:q], lower_bound = 0)

@constraint(aOpt, sum(np) <= n)
for i = 1:q
    @SDconstraint(aOpt, [V * diagm(0 => np ./ n) * V' eye[:, i]; eye[i, :]' u[i]] >= 0)
end

@objective(aOpt, Min, sum(u))

optimize!(aOpt)

@show objective_value(aOpt);
@show value.(np);


eOpt = Model(with_optimizer(SCS.Optimizer, verbose = 0))
@variable(eOpt, np[1:p], lower_bound = 0, upper_bound = nmax)
@variable(eOpt, t)

@SDconstraint(eOpt, V * diagm(0 => np ./ n) * V' - (t .* eye) >= 0)
@constraint(eOpt, sum(np) <= n)

@objective(eOpt, Max, t)

optimize!(eOpt)

@show objective_value(eOpt);
@show value.(np);


dOpt = Model(with_optimizer(SCS.Optimizer, verbose = 0))
@variable(dOpt, np[1:p], lower_bound = 0, upper_bound = nmax)
@variable(dOpt, t)
@objective(dOpt, Max, t)
@constraint(dOpt, sum(np) <= n)
E = V * diagm(0 => np ./ n) * V'
@constraint(dOpt, [t, 1, (E[i, j] for i in 1:q for j in 1:i)...] in MOI.LogDetConeTriangle(q))

optimize!(dOpt)

@show objective_value(dOpt);
@show value.(np);

