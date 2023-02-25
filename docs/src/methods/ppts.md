# Pseudo-periodic twin surrogates

```@example MAIN
using TimeseriesSurrogates, CairoMakie

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
fig = Figure()
ax_ts = Axis(fig[1,1:2]; xlabel = "time", ylabel = "value")
lines!(ax_ts, s1; color = :red)
lines!(ax_ts, x; color = :black)

# Embedding versus surrogate embedding
X = embed(x, d, τ)
ax2 = Axis(fig[2, 1]; xlabel = "x(t)", ylabel = "x(t-$τ)")
lines!(ax2, X[:, 1], X[:, 2]; color = :black)
scatter!(ax2, X[:, 1], X[:, 2]; color = :black, markersize = 4)

ps = Axis(fig[2,2]; xlabel=  "s(t)", ylabel = "s(t-$τ)")
lines!(ps, s1, s2; color = :red)
scatter!(ps, s1, s2; color = :black, markersize = 4)

fig
```
