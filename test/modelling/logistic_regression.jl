
using JuMP
using Random
using ECOS

Random.seed!(2713);

function generate_dataset(n_samples=100, n_features=10; corr=0.0)
    X = randn(n_samples, n_features)
    w = randn(n_features)
    y = sign.(X * w)
    X .+= 0.8 * randn(n_samples, n_features) # add noise
    X .+= corr # this makes it correlated by adding a constant term
    X = hcat(X, ones(n_samples, 1))
    return X, y
end

function softplus(model, t, u)
    z = @variable(model, [1:2], lower_bound=0.0)
    @constraint(model, sum(z) <= 1.0)
    @constraint(model, vec([u - t, 1, z[1]]) in MOI.ExponentialCone())
    @constraint(model, vec([-t, 1, z[2]]) in MOI.ExponentialCone())
end

function build_logit_model(X, y, λ)
    n, p = size(X)
    model = Model()
    @variable(model, θ[1:p])
    @variable(model, t[1:n])
    for i in 1:n
        u = - (X[i, :]' * θ) * y[i]
        softplus(model, t[i], u)
    end
    # Add ℓ2 regularization
    @variable(model, 0.0 <= reg)
    @constraint(model, vec([reg; θ]) in MOI.SecondOrderCone(p+1))
    # Define objective
    @objective(model, Min, sum(t) + λ * reg)
    return model
end

# Be careful here, for large n and p ECOS could fail to converge!
n, p = 2000, 100
X, y = generate_dataset(n, p, corr=1.0);

λ = 10.0
model = build_logit_model(X, y, λ)
JuMP.set_optimizer(model, ECOS.Optimizer)
JuMP.optimize!(model)

function build_sparse_logit_model(X, y, λ)
    n, p = size(X)
    model = Model()
    @variable(model, θ[1:p])
    @variable(model, t[1:n])
    for i in 1:n
        u = - (X[i, :]' * θ) * y[i]
        softplus(model, t[i], u)
    end
    # Add ℓ1 regularization
    @variable(model, 0.0 <= reg)
    @constraint(model, vec([reg; θ]) in MOI.NormOneCone(p+1))
    # Define objective
    @objective(model, Min, sum(t) + λ * reg)
    return model
end

count_nonzero(v::Vector; tol=1e-8) = sum(abs.(v) .<= tol)

λ = 10.0
sparse_model = build_sparse_logit_model(X, y, λ)
JuMP.set_optimizer(sparse_model, ECOS.Optimizer)
JuMP.optimize!(sparse_model)
