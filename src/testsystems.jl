"""
    NLNS(n_steps, x₀)

A nonlinear, nonstationary process.

## Equations
The systems is given by the following stochastic model:

```math
x(t+1) = x(t) + a(t) a(t-1)
```

with ``a(t) \textasciitilde N(0,1)`` being stationary. The nonlinearity lies in
the ``a(t) a(t-1)`` term.
This is, in essence, a nonlinear random walk. `x₀` sets the initial condition.

This example is from [Lucio et al. (2012)](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202).

## References

Lucio et al., Phys. Rev. E *85*, 056202 (2012), after J. Timmer,
Phys. Rev. E *58*, 5153 (1998). [https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202)

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
    AR1(n_steps, x₀, k)

Simple AR(1) model with no static transformation from [Lucio et al. (2012)](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202).

## Equations
The system is given by the following map [1]:

```math
x(t+1) = k x(t) + a(t),
```

where ``a(t)`` is a draw from a normal distribution with zero mean and unit
variance. `x₀` sets the initial condition and `k` is the tunable parameter in
the map.

# References

Lucio et al., Phys. Rev. E *85*, 056202 (2012). [https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202)
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
    NSAR2(n_steps, x₀, x₁)

Cyclostationary AR(2) process from [Lucio et al. (2012)](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202).

## References

Lucio et al., Phys. Rev. E *85*, 056202 (2012), after J. Timmer,
Phys. Rev. E *58*, 5153 (1998). [https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202)

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
    randomwalk(n_steps, x₀)

Linear random walk (AR(1) process with a unit root) from [Lucio et al. (2012)](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202).
This is an example of a nonstationary linear process.

# References

Lucio et al., Phys. Rev. E *85*, 056202 (2012), after J. Timmer,
Phys. Rev. E *58*, 5153 (1998). [https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202)
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
    SNLST(n_steps, x₀, k)

Dynamically linear process transformed by a strongly nonlinear static
transformation (SNLST), from
[Lucio et al., 2012](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202).

## Equations
The system is by the following map:

```math
x(t) = k x(t-1) + a(t)
```

with the transformation ``s(t) = x(t)^3``.

# References

Lucio et al., Phys. Rev. E *85*, 056202 (2012), after J. Timmer,
Phys. Rev. E *58*, 5153 (1998). 
[https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202)

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
