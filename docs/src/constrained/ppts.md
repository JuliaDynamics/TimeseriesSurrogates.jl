# Pseudo-periodic twin surrogates

```@example
using TimeseriesSurrogates, Plots, DynamicalSystems

# Example system from the original paper
n, Δt = 500, 0.05
f₁, f₂ = sqrt(3), sqrt(5)
x = [8*sin(2π*f₁*t) + 4*sin(2π*f₂*t) for t = 0:Δt:Δt*n]

# Embedding parameter, neighbor threshold and noise radius
d, τ = 2, 6
δ = 0.15
ρ = noiseradius(x, d, τ, 0.02:0.02:0.5)
method = PseudoPeriodicTwin(d, τ, δ, ρ)

# Generate the surrogate, which is a `d`-dimensional dataset.
surr_orbit = surrogate(x, method)

# Get scalar surrogate time series from first and second column.
s1, s2 = columns(surr_orbit)

# Scalar time series versus surrogate time series
p_ts = plot(xlabel = "Time", ylabel = "Value")
plot!(s1, label = "", c = :red)
plot!(x, label = "", c = :black)

# Embedding versus surrogate embedding
X = embed(x, d, τ)
px = plot(xlabel=  "x(t)", ylabel = "x(t-$τ)", label = "")
plot!(X[:, 1], X[:, 2], label = "", c = :black)
scatter!(X[:, 1], X[:, 2], label = "", c = :black)

ps = plot(xlabel=  "s(t)", ylabel = "s(t-$τ)", label = "")
plot!(s1, s2, label = "", c = :red)
scatter!(s1, s2, label = "", c = :red)

plot(layout = grid(2, 1),
    p_ts,
    plot(px, ps, aspect_ratio = 1, ms = 1, lw = 0.7))
```
