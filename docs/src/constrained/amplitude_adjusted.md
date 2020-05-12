# Amplitude adjusted Fourier transform surrogates

## AAFT 


```@example
using TimeseriesSurrogates
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, AAFT())

surrplot(ts, s)
```

## IAAFT 

The IAAFT surrogates add an iterative step to the AAFT algorithm improve convergence.

```@example
using TimeseriesSurrogates
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, IAAFT())

surrplot(ts, s)
```