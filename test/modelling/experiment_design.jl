
using JuMP
using SCS
using LinearAlgebra

q = 4 # dimension of estimate space
p = 8 # number of experimental vectors
n = 12 # 
nmax = 3 # upper bound on lambda

function gen_V(q, p)
    V = Array{Float64}(undef, q, p)
    for i in 1:q, j in 1:p
        v = randn()
        if abs(v) < 1e-2
            v = 0.
        end
        V[i, j] = v
    end
    return V
end

V = gen_V(q, p)

while rank(V) != q
    V = gen_V(q, p)
end

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
@constraint(dOpt, [t, E[:]...] in MOI.LogDetConeSquare(q))

optimize!(dOpt)

@show objective_value(dOpt);
@show value.(np);

