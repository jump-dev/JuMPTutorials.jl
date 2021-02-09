
using Interpolations, Plots
using JuMP, Ipopt  # , KNITRO


# Global variables
const w  = 203000.0  # weight (lb)
const g₀ = 32.174    # acceleration (ft/sec^2)
const m  = w / g₀    # mass (slug)

# Aerodynamic and atmospheric forces on the vehicle
const ρ₀ =  0.002378
const hᵣ =  23800.0
const Rₑ =  20902900.0
const μ  =  0.14076539e17
const S  =  2690.0
const a₀ = -0.20704
const a₁ =  0.029244
const b₀ =  0.07854
const b₁ = -0.61592e-2
const b₂ =  0.621408e-3
const c₀ =  1.0672181
const c₁ = -0.19213774e-1
const c₂ =  0.21286289e-3
const c₃ = -0.10117249e-5

# Initial conditions
const hₛ = 2.6          # altitude (ft) / 1e5
const ϕₛ = deg2rad(0)   # longitude (rad)
const θₛ = deg2rad(0)   # latitude (rad)
const vₛ = 2.56         # velocity (ft/sec) / 1e4
const γₛ = deg2rad(-1)  # flight path angle (rad)
const ψₛ = deg2rad(90)  # azimuth (rad)
const αₛ = deg2rad(0)   # angle of attack (rad)
const βₛ = deg2rad(0)   # banck angle (rad)
const tₛ = 1.00         # time step (sec)

# Final conditions, the so-called Terminal Area Energy Management (TAEM)
const hₜ = 0.8          # altitude (ft) / 1e5
const vₜ = 0.25         # velocity (ft/sec) / 1e4
const γₜ = deg2rad(-5)  # flight path angle (rad)

# Number of mesh points (knots) to be used
const n = 2009

# Integration scheme to be used for the dynamics
const integration_rule = "rectangular"


user_options_ipopt = (
    "mu_strategy" => "monotone",
    "linear_solver" => "ma27",  # For the best results, it is advised to experiment different linear solvers.
                                # If Ipopt is not compiled with MA27/MA57, it may fallback to 'MUMPS'.
                                # In general, the linear solver MA27 is much faster than MUMPS.
)

# user_options_knitro = (
#     "algorithm" => KNITRO.KN_ALG_BAR_DIRECT,
#     "bar_murule" => KNITRO.KN_BAR_MURULE_QUALITY,
#     "linsolver" => KNITRO.KN_LINSOLVER_MA27,
# )

# Create JuMP model, using Ipopt as the solver
model = Model(optimizer_with_attributes(Ipopt.Optimizer, user_options_ipopt...))
# model = Model(optimizer_with_attributes(KNITRO.Optimizer, user_options_knitro...))

@variables(model, begin
               0 ≤ scaled_h[1:n]                # altitude (ft) / 1e5
                          ϕ[1:n]                # longitude (rad)
    deg2rad(-89) ≤        θ[1:n] ≤ deg2rad(89)  # latitude (rad)
            1e-4 ≤ scaled_v[1:n]                # velocity (ft/sec) / 1e4
    deg2rad(-89) ≤        γ[1:n] ≤ deg2rad(89)  # flight path angle (rad)
                          ψ[1:n]                # azimuth (rad)
    deg2rad(-90) ≤        α[1:n] ≤ deg2rad(90)  # angle of attack (rad)
    deg2rad(-89) ≤        β[1:n] ≤ deg2rad( 1)  # banck angle (rad)
    #        0.5 ≤       Δt[1:n] ≤ 1.5          # time step (sec)
                         Δt[1:n] == 1.0         # time step (sec)
end)

# Fix initial conditions
fix(scaled_h[1], hₛ; force=true)
fix(       ϕ[1], ϕₛ; force=true)
fix(       θ[1], θₛ; force=true)
fix(scaled_v[1], vₛ; force=true)
fix(       γ[1], γₛ; force=true)
fix(       ψ[1], ψₛ; force=true)

# Fix final conditions
fix(scaled_h[n], hₜ; force=true)
fix(scaled_v[n], vₜ; force=true)
fix(       γ[n], γₜ; force=true)

# Initial guess: linear interpolation between boundary conditions
xₛ = [hₛ, ϕₛ, θₛ, vₛ, γₛ, ψₛ, αₛ, βₛ, tₛ]
xₜ = [hₜ, ϕₛ, θₛ, vₜ, γₜ, ψₛ, αₛ, βₛ, tₛ]
interp_linear = LinearInterpolation([1, n], [xₛ, xₜ])
initial_guess = mapreduce(transpose, vcat, interp_linear.(1:n))
set_start_value.(all_variables(model), vec(initial_guess))

# Functions to restore `h` and `v` to their true scale
@NLexpression(model, h[j = 1:n], scaled_h[j] * 1e5)
@NLexpression(model, v[j = 1:n], scaled_v[j] * 1e4)

# Helper functions
# @NLexpression(model, c_L[j = 1:n], a₀ + a₁ * rad2deg(α[j]))
# @NLexpression(model, c_D[j = 1:n], b₀ + b₁ * rad2deg(α[j]) + b₂ * rad2deg(α[j])^2)
@NLexpression(model, c_L[j = 1:n], a₀ + a₁ * (180 * α[j] / π))
@NLexpression(model, c_D[j = 1:n], b₀ + b₁ * (180 * α[j] / π) + b₂ * (180 * α[j] / π)^2)
@NLexpression(model,   ρ[j = 1:n], ρ₀ * exp(-h[j] / hᵣ))
@NLexpression(model,   D[j = 1:n], 0.5 * c_D[j] * S * ρ[j] * v[j]^2)
@NLexpression(model,   L[j = 1:n], 0.5 * c_L[j] * S * ρ[j] * v[j]^2)
@NLexpression(model,   r[j = 1:n], Rₑ + h[j])
@NLexpression(model,   g[j = 1:n], μ / r[j]^2)

# Motion of the vehicle as a differential-algebraic system of equations (DAEs)
@NLexpression(model, δh[j = 1:n], v[j] * sin(γ[j]))
@NLexpression(model, δϕ[j = 1:n], (v[j] / r[j]) * cos(γ[j]) * sin(ψ[j]) / cos(θ[j]))
@NLexpression(model, δθ[j = 1:n], (v[j] / r[j]) * cos(γ[j]) * cos(ψ[j]))
@NLexpression(model, δv[j = 1:n], -(D[j] / m) - g[j] * sin(γ[j]))
@NLexpression(model, δγ[j = 1:n], (L[j] / (m * v[j])) * cos(β[j]) + cos(γ[j]) * ((v[j] / r[j]) - (g[j] / v[j])))
@NLexpression(model, δψ[j = 1:n], (1 / (m * v[j] * cos(γ[j]))) * L[j] * sin(β[j]) + (v[j] / (r[j] * cos(θ[j]))) * cos(γ[j]) * sin(ψ[j]) * sin(θ[j]))

# System dynamics
for j in 2:n
    i = j - 1  # index of previous knot

    if integration_rule == "rectangular"
        # Rectangular integration
        @NLconstraint(model, h[j] == h[i] + Δt[i] * δh[i])
        @NLconstraint(model, ϕ[j] == ϕ[i] + Δt[i] * δϕ[i])
        @NLconstraint(model, θ[j] == θ[i] + Δt[i] * δθ[i])
        @NLconstraint(model, v[j] == v[i] + Δt[i] * δv[i])
        @NLconstraint(model, γ[j] == γ[i] + Δt[i] * δγ[i])
        @NLconstraint(model, ψ[j] == ψ[i] + Δt[i] * δψ[i])
    elseif integration_rule == "trapezoidal"
        # Trapezoidal integration
        @NLconstraint(model, h[j] == h[i] + 0.5 * Δt[i] * (δh[j] + δh[i]))
        @NLconstraint(model, ϕ[j] == ϕ[i] + 0.5 * Δt[i] * (δϕ[j] + δϕ[i]))
        @NLconstraint(model, θ[j] == θ[i] + 0.5 * Δt[i] * (δθ[j] + δθ[i]))
        @NLconstraint(model, v[j] == v[i] + 0.5 * Δt[i] * (δv[j] + δv[i]))
        @NLconstraint(model, γ[j] == γ[i] + 0.5 * Δt[i] * (δγ[j] + δγ[i]))
        @NLconstraint(model, ψ[j] == ψ[i] + 0.5 * Δt[i] * (δψ[j] + δψ[i]))
    else
        @error "Unexpected integration rule '$(integration_rule)'"
    end
end

# Objective: Maximize crossrange
@objective(model, Max, θ[n])

# Solve for the control and state
status = optimize!(model)

# Show final crossrange of the solution
println("Final latitude θ = ", round(objective_value(model) |> rad2deg, digits = 2), "°")


ts = cumsum([0; value.(Δt)])[1:end-1]

plt_altitude = plot(ts, value.(scaled_h), legend = nothing, title = "Altitude (100,000 ft)")
plt_longitude = plot(ts, rad2deg.(value.(ϕ)), legend = nothing, title = "Longitude (deg)")
plt_latitude = plot(ts, rad2deg.(value.(θ)), legend = nothing, title = "Latitude (deg)")
plt_velocity = plot(ts, value.(scaled_v), legend = nothing, title = "Velocity (1000 ft/sec)")
plt_flight_path = plot(ts, rad2deg.(value.(γ)), legend = nothing, title = "Flight Path (deg)")
plt_azimuth = plot(ts, rad2deg.(value.(ψ)), legend = nothing, title = "Azimuth (deg)")

plt = plot(plt_altitude,  plt_velocity, plt_longitude, plt_flight_path, plt_latitude,
           plt_azimuth, layout=grid(3, 2), linewidth=2, size=(700, 700))


function q(h, v, a)
    ρ(h) = ρ₀ * exp(-h / hᵣ)
    qᵣ(h, v) = 17700 * √ρ(h) * (0.0001 * v)^3.07
    qₐ(a) = c₀ + c₁ * rad2deg(a) + c₂ * rad2deg(a)^2 + c₃ * rad2deg(a)^3    
    # Aerodynamic heating on the vehicle wing leading edge
    qₐ(a) * qᵣ(h, v)
end

plt_attack_angle = plot(ts[1:end-1], rad2deg.(value.(α)[1:end-1]), legend=nothing, title="Angle of Attack (deg)")
plt_bank_angle = plot(ts[1:end-1], rad2deg.(value.(β)[1:end-1]), legend=nothing, title="Bank Angle (deg)")
plt_heating = plot(ts, q.(value.(scaled_h)*1e5, value.(scaled_v)*1e4, value.(α)), legend=nothing, title="Heating (BTU/ft/ft/sec)") 

plt = plot(plt_attack_angle, plt_bank_angle, plt_heating, layout=grid(3, 1), linewidth=2, size=(700, 700))


plt = plot(rad2deg.(value.(ϕ)), rad2deg.(value.(θ)), value.(scaled_h),
           linewidth=2, legend=nothing, title="Space Shuttle Reentry Trajectory",
           xlabel="Longitude (deg)", ylabel="Latitude (deg)", zlabel="Altitude (100,000 ft)")

