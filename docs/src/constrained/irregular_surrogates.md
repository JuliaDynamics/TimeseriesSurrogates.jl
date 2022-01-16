# Surrogates for unevenly sampled time series


To derive a surrogate for unevenly sampled time series, we can use surrogate methods which which does not explicitly use the time axis like [`RandomShuffle`](@ref) or [`BlockShuffle`](@ref)
or we need to use algorithms, which take the irregularity of the time axis into account.

## Lomb-Scargle based surrogate

The LS surrogate is a form of a constrained surrogate which takes the Lomb-Scargle periodogram to derive surrogates with similar phase distribution as the original time series.
This function uses the simulated annealing algorithm to compute a minima of the difference between the original periodogram and the surrogate periodogram.

```@docs
LS
```

```@example
using TimeseriesSurrogates, Plots
N=1000
ts = AR1(n_steps=N) # create a realization of a random AR(1) process
t = (1:length(ts)) - rand(length(ts)) # generate a time axis with unevenly spaced time steps
ls = LS(t, tol=1, N_total=100000, N_acc = 50000)
s = surrogate(ts, ls)
plot(t,ts,label="original data")
plot!(t, s, label="Surrogate data")
```
