# Surrogates for unevenly sampled time series


To derive a surrogate for unevenly sampled time series, we can use surrogate methods which which does not explicitly use the time axis like [`RandomShuffle`](@ref) or [`BlockShuffle`](@ref)
or we need to use algorithms, which take the irregularity of the time axis into account.

## Lomb-Scargle based surrogate

The LS surrogate is a form of a constrained surrogate which takes the Lomb-Scargle periodogram to derive surrogates with similar phase distribution as the original time series.
This function uses the simulated annealing algorithm to minimize the Minkowski distance between the original periodogram and the surrogate periodogram.


```@example
using TimeseriesSurrogates, Plots

# Example data: random AR(1) process with a time axis with unevenly 
# spaced time steps
N = 1000
t = (1:N) - rand(N) 
x = AR1(n_steps = N)

# Generate surrogate
ls = LS(t, tol = 1, n_total = 100000, n_acc = 50000)
s = surrogate(x, ls)

plot()
plot!(t, x, label = "Original signal")
plot!(t, s, label = "Surrogate")
```
