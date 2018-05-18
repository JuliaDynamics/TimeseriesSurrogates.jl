# Random shuffle surrogates

## Shuffling time indices

The easiest way of constructing a constrained surrogate is just shuffling the time indices of the original time series.

```@docs
TimeseriesSurrogates.randomshuffle
```

### Example of surrogate generation by shuffling time indices

```@example
using TimeseriesSurrogates
ts = AR1()
surrogate = randomshuffle(ts)

surrplot(ts, surrogate) # Visualize the surrogate
```
