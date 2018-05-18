"""
A nonlinear, nonstationary process given by the stochastic model

``x_t = x_{t-1} + a_t a_{t-1} ``

with ``a_t ~ N(0,1)`` being stationary. The nonlinearity lies in the ``a_t a_{t-1}`` term.
This is, in essence, a nonlinear random walk.

From Lucio et al., Phys. Rev. E *85*, 056202 (2012).
"""
function NLNS(n_steps, x₀)
    a = rand(Uniform(0, 1), n_steps)

    x = Vector{Float64}(n_steps)
    x[1] = x₀
    for i = 2:n_steps
        x[i] = x[i-1] + a[i]*a[i-1]
    end

    x
end

"""
Simple AR(1) model with no static transformation given by

`` x[i] = k*x[i-1] + a[i] ``,

where a[i] is a draw from a normal distribution with zero mean and unit variance.

From Lucio et al., Phys. Rev. E *85*, 056202 (2012).
"""
function AR1(n_steps, x₀, k)
    a = rand(Normal(), n_steps)
    x = Vector{Float64}(n_steps)
    x[1] = x₀
    for i = 2:n_steps
        x[i] = k*x[i-1] + a[i]
    end
    x
end

"""
Cyclostationary AR(2) process.

`` x_t = a₁(t) * x_{t-1} + a₋ x_{t-2} + ϵ\_t ``.

where

`` a₁(t) = 2 cos[2\pi / T(t)] \cdot exp(-1 / τ)``,

`` T(t)  = T_0 + M * sin(2 \pi t / T_{mod}) ``,

`` a₂    = exp(-2 / \tau) ``


From Lucio et al., Phys. Rev. E *85*, 056202 (2012), after J. Timmer, Phys. Rev. E *58*, 5153
(1998).
"""
function NSAR2(n_steps, x₀, x₁)
    T₀ = 50.0
    τ = 10.0
    M = 5.5
    Tmod = 250
    σ₀ = 1.0
    a_1_0 = 2*cos(2*π/T₀)*exp(-1/τ)
    a₂ = -exp(-2 / τ)
    a = rand(Normal(), n_steps)
    x = Vector{Float64}(n_steps)
    x[1], x[2] = x₀, x₁

    for i = 3:n_steps
        T_t = T₀ + M*sin(2*π*i / Tmod)
        a₁_t = 2*cos(2*π/T_t) * exp(-1 / τ)

        σ = σ₀^2/(1 - a_1_0^2 - a₂^2 - (2*(a_1_0^2) * a₂)/(1 - a₂)) *
            (1 - a₁_t - a₂^2 - (2*(a₁_t^2) * a₂)/(1 - a₂))
        x[i] = a₁_t * x[i-1] + a₂*x[i-2] + rand(Normal(0, sqrt(σ)))
    end
    x
end


"""
Linear random walk (AR(1) process with a unit root)

Example of a nonstationary linear process.


From Lucio et al., Phys. Rev. E *85*, 056202 (2012).
"""
function randomwalk(n_steps, x₀)
    a = rand(Normal(), n_steps)

    x = Vector{Float64}(n_steps)
    x[1] = x₀
    for i = 2:n_steps
        x[i] = x[i-1] + a[i]
    end
    x
end


"""
Dynamically linear process transformed by a strongly nonlinear static transformation
(SNLST), given by

`` x(t) = k*x(t-1) + a(t) ``

with the transformation ``s(t) = x(t)^3``.
"""
function SNLST(n_steps, x₀, k)
    a = rand(Normal(), n_steps)
    x = Vector{Float64}(n_steps)
    x[1] = x₀
    for i = 2:n_steps
        x[i] = k*x[i-1] + a[i]
    end
    x.^3
end

# Keyword versions of the functions
AR1(;n_steps = 500, x₀ = rand(), k = rand())    = AR1(n_steps, x₀, k)
NLNS(;n_steps = 500, x₀ = rand())               = NLNS(n_steps, x₀)
SNLST(;n_steps = 500, x₀ = rand(), k = rand())  = SNLST(n_steps, x₀, k)
randomwalk(;n_steps = 500, x₀ = rand())         = randomwalk(n_steps, x₀)
NSAR2(;n_steps = 500, x₀ = rand(), x₁ = rand()) = NSAR2(n_steps, x₀, x₁)

export
    AR1,
    NLNS,
    SNLST,
    randomwalk,
    NSAR2
