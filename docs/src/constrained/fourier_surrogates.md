# Fourier-based

Fourier based surrogates are a form of constrained surrogates created by taking the Fourier
transform of a time series, then shuffling either the phase angles or the amplitudes of the resulting complex numbers. Then, we take the inverse Fourier transform, yielding a surrogate time series.

## Random phase

```@example
using TimeseriesSurrogates, Plots
ts = AR1() # create a realization of a random AR(1) process
phases = true
s = surrogate(ts, RandomFourier(phases))

surroplot(ts, s)
```

## Random amplitude

```@example
using TimeseriesSurrogates, Plots
ts = AR1() # create a realization of a random AR(1) process
phases = false
s = surrogate(ts, RandomFourier(phases))

surroplot(ts, s)
```
