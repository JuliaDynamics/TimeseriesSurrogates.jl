# Amplitude adjusted Fourier transform surrogates

## AAFT


```@example MAIN
using TimeseriesSurrogates, CairoMakie, Makie
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, AAFT())

surroplot(ts, s)
```

## Iterative AAFT (IAAFT)

The IAAFT surrogates add an iterative step to the AAFT algorithm to improve similarity
of the power spectra of the original time series and the surrogates.

```@example MAIN
using TimeseriesSurrogates, CairoMakie, Makie
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, IAAFT())

surroplot(ts, s)
```
