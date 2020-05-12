# Fourier surrogates

Fourier surrogates are a form of constrained surrogates created by taking the Fourier
transform of a time series, then shuffling either the phase angles or the amplitudes of the resulting complex numbers. Then, we take the inverse Fourier transform, yielding a surrogate time series.

## Random phase surrogates


```@example
using TimeseriesSurrogates
ts = AR1() # create a realization of a random AR(1) process
phases = true
s = surrogate(ts, RandomFourier(phases))

surrplot(ts, s)
```

## Random amplitude surrogates

```@example
using TimeseriesSurrogates
ts = AR1() # create a realization of a random AR(1) process
phases = false
s = surrogate(ts, RandomFourier(phases))

surrplot(ts, s)
```
