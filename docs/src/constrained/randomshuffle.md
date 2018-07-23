# Random shuffle surrogates (RS)

```@docs
TimeseriesSurrogates.randomshuffle
```

The easiest way of constructing a constrained surrogate is just shuffling the time indices
of the original time series. Here's an example:

```@example
using TimeseriesSurrogates

# Generate a time series. Here, we'll use an AR1 process.
ts = AR1()

# Generate a random shuffle surrogate realization
surrogate = randomshuffle(ts)

# Plot the surrogate along with the time series it is based on, along with autocorrelation
# and periodogram plots.
surrplot(ts, surrogate)
```
