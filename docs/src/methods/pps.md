# Pseudo-periodic

```@example MAIN
using TimeseriesSurrogates
t = 0:0.05:20π
x = @. 4 + 7cos(t) + 2cos(2t + 5π/4)
x .+= randn(length(x))*0.2

# Optimal d, τ values deduced using DynamicalSystems.jl
d, τ = 3, 31

# For ρ you can use `noiseradius`
ρ = 0.11

method = PseudoPeriodic(d, τ, ρ, false)
s = surrogate(x, method)
surroplot(x, s)
```
