# Amplitude adjusted Fourier transform surrogates

Different variants of the AAFT and iterated AAFT algorithms.


## Amplitude adjusted Fourier transform (AAFT)

```@docs
TimeseriesSurrogates.aaft
```

### Example of AAFT

```@example
using TimeseriesSurrogates
ts = AR1() # create a realization of a random AR(1) process
surrogate = aaft(ts)

surrplot(ts, surrogate)
```


## Iterated AAFT (AAFT)

The IAAFT surrogates add an iterative step to the AAFT algorithm improve convergence.

```@docs
TimeseriesSurrogates.iaaft
```


### Example of IAAFT

```@example
using TimeseriesSurrogates
ts = AR1() # create a realization of a random AR(1) process
surrogate = iaaft(ts)

surrplot(ts, surrogate)
```
