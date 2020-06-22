# Multidimensional surrogates
Multidimensional surrogates operate typically on input `Datasets` (see e.g. [DynamicalSystems.jl](https://juliadynamics.github.io/DynamicalSystems.jl/dev/embedding/dataset/) package) and output the same type.

## Shuffle dimensions
This surrogate was made to distinguish multidimensional data with *structure in the state space* from multidimensional noise.

Here is a simple application that shows that the distinction is successful for a system that we know a-priori is deterministic and has structure in the state space.

```@example multidim
using DynamicalSystems, TimeseriesSurrogates, Plots

D = 7
lo = Systems.lorenz96(D, range(0; length = D, step = 0.1); F = 8.0)
X = trajectory(lo, 1000, dt = 0.1, Ttr = 100.0)

e = 10.0 .^ range(-4, 1, length = 22)
CX = correlationsum(X, e; w = 5)

le = log10.(e)
plot(le, log10.(CX))

sg = surrogenerator(X, ShuffleDimensions())
for i in 1:10
    Z = sg()
    CZ = correlationsum(Z, e)
    plot!(le, log10.(CZ), alpha = 0.5, lw = 0.5, color = "k", ls = ":")
end
plot!(xlabel = "log(e)", ylabel = "log(C)");
```
