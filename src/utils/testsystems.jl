export NLNS, NSAR2, AR1, randomwalk, SNLST, random_cycles, colored_noise

"""
    AR1(n_steps, x₀, k)

Simple AR(1) model with no static transformation[^1].

## Equations

The system is given by the following map:
```math
x(t+1) = k x(t) + a(t),
```
where ``a(t)`` is a draw from a normal distribution with zero mean and unit
variance. `x₀` sets the initial condition and `k` is the tunable parameter in
the map.

# References

[^1]: Lucio et al., Phys. Rev. E *85*, 056202 (2012). [https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202)
"""
function AR1(n_steps, x₀, k)
    a = rand(Normal(), n_steps)
    x = Vector{Float64}(undef, n_steps)
    x[1] = x₀
    for i = 2:n_steps
        x[i] = k*x[i-1] + a[i]
    end
    x
end

"""
    NSAR2(n_steps, x₀, x₁)

Cyclostationary AR(2) process[^1].

## References

[^1]: Lucio et al., Phys. Rev. E *85*, 056202 (2012). [https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202)
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
    x = Vector{Float64}(undef, n_steps)
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

Linear random walk (AR(1) process with a unit root)[^1].
This is an example of a nonstationary linear process.

# References

[^1]: Lucio et al., Phys. Rev. E *85*, 056202 (2012). [https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202)
"""
function randomwalk(n_steps, x₀)
    a = rand(Normal(), n_steps)

    x = Vector{Float64}(undef, n_steps)
    x[1] = x₀
    for i = 2:n_steps
        x[i] = x[i-1] + a[i]
    end
    x
end


"""
    SNLST(n_steps, x₀, k)

Dynamically linear process transformed by a strongly nonlinear static
transformation (SNLST)[^1].

## Equations
The system is by the following map:
```math
x(t) = k x(t-1) + a(t)
```
with the transformation ``s(t) = x(t)^3``.

# References

[^1]: Lucio et al., Phys. Rev. E *85*, 056202 (2012). [https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202](https://journals.aps.org/pre/abstract/10.1103/PhysRevE.85.056202)
"""
function SNLST(n_steps, x₀, k)
    a = rand(Normal(), n_steps)
    x = Vector{Float64}(undef, n_steps)
    x[1] = x₀
    for i = 2:n_steps
        x[i] = k*x[i-1] + a[i]
    end
    x.^3
end

# Keyword versions of the functions
AR1(;n_steps = 500, x₀ = rand(), k = rand())    = AR1(n_steps, x₀, k)
SNLST(;n_steps = 500, x₀ = rand(), k = rand())  = SNLST(n_steps, x₀, k)
randomwalk(;n_steps = 500, x₀ = rand())         = randomwalk(n_steps, x₀)
NSAR2(;n_steps = 500, x₀ = rand(), x₁ = rand()) = NSAR2(n_steps, x₀, x₁)


"""
    random_cycles(; periods=10 dt=π/20, σ = 0.05, frange = (0.8, 2.0))
Make a timeseries that is composed of `period` full sine wave periods, each with a
random frequency in the range given by `frange`, and added noise with std `σ`.
The sampling time is `dt`.
"""
function random_cycles(rng = Random.default_rng(); periods=10, dt=π/20, σ = 0.05, frange = (1.0, 1.6))
    dt = π/20
    x = Float64[]

    for i in 1:periods
        f = (frange[1]-frange[2])*rand(rng) + frange[1]
        T = 2π/f
        t = 0:dt:T
        append!(x, sin.(f .* t))
    end

    N = length(x)
    x .+= randn(N)/20
    return x
end

"""
     colored_noise(rng = Random.default_rng(); n::Int = 500, ρ, σ = 0.1, transform = true)

 Generate `n` points of colored noise. `ρ` is the desired correlation 
 between adjacent samples. The noise is drawn from a normal distribution
 with zero mean and standard deviation `σ`. If `transform  = true`, then 
 transform data using aquadratic nonlinear static distortion.
 """
 function colored_noise(rng = Random.default_rng(); n::Int = 500, ρ = 0.8, σ = 0.1, transform = true)
     𝒩 = Normal(0, σ)
     x = zeros(n)
     x[1] = rand(rng, 𝒩)
     for i = 2:n
         x[i] = ρ*x[i-1] + sqrt(1 - ρ^2)*rand(rng, 𝒩)
     end
     if transform 
         x .= x .* sqrt.(x .^ 2)
     end

     return x .- mean(x)
 end