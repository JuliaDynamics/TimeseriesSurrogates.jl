# Pseudoperiodic surrogates

```@example
using TimeseriesSurrogates
ts = NSAR2() # create a realization of an NSAR2 process
phases = true

# Embedding dimension/lag and parameter ρ must be specified
d, τ, ρ = 3, 10, 0.1
method = PseudoPeriodic(d, τ, ρ)
s = surrogate(ts, method)

surrplot(ts, s)
```
