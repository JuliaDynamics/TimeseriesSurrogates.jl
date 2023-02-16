# Multidimensional surrogates
Multidimensional surrogates operate typically on input `Datasets` (see e.g. [DynamicalSystems.jl](https://juliadynamics.github.io/DynamicalSystems.jl/dev/embedding/dataset/) package) and output the same type.

## Shuffle dimensions
This surrogate was made to distinguish multidimensional data with *structure in the state space* from multidimensional noise.

Here is a simple application that shows that the distinction is successful for a system that we know a-priori is deterministic and has structure in the state space.

```@example  MAIN
using DynamicalSystems, TimeseriesSurrogates, CairoMakie

D = 4
lo = Systems.lorenz96(D, range(0; length = D, step = 0.1); F = 24.0)
X = trajectory(lo, 1000; Δt = 0.1, Ttr = 100.0)

e = 10.0 .^ range(-3, 1, length = 10)
CX = correlationsum(X, e; w = 5)

le = log10.(e)
fig, ax = lines(le, CX, yscale = Makie.pseudolog10)

sg = surrogenerator(X, ShuffleDimensions())
for i in 1:10
    Z = sg()
    CZ = correlationsum(Z, e)
    lines!(ax, le, CZ; color = ("black", 0.8), yscale = Makie.pseudolog10)
end
ax.xlabel = "log(e)"; ax.ylabel = "log(C)"
fig
```
