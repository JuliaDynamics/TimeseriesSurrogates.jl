# Amplitude adjusted Fourier transform surrogates

## AAFT


```@example
using TimeseriesSurrogates, Plots
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, AAFT())

surroplot(ts, s)
```

## IAAFT

The IAAFT surrogates add an iterative step to the AAFT algorithm improve convergence.

```@example
using TimeseriesSurrogates, Plots
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, IAAFT())

surroplot(ts, s)
```
