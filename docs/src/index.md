# Overview

# TODO: add example figure here.

If you are new to this method of [surrogate time series](https://en.wikipedia.org/wiki/Surrogate_data_testing), feel free to read any of the following:
1. [The method of surrogate testing](@ref)
2. [What is a surrogate time series?](@ref)
3. [Types of surrogate realizations](@ref)

## API

TimeseriesSurrogates.jl exports two main functions. Both of them dispatch on the chosen method, a subtype of `Surrogate`.

```@docs
surrogate
surrogenerator
```

## Surrogate methods

```@docs
RandolShuffle
RandomFourier
AAFT
PseudoPeriodic
```

### Utils

```@docs
noiseradius
```

## I want to visualize my surrogate realizations

TimeseriesSurrogates.jl provides some convenient plotting routines that'll make it easy to
check if your surrogates are successfully capturing your target null hypothesis.
To use the plotting functionality you need to install `Plots` (and a plotting backend).
Once you load it, via `using Plots`, the following two links are relevant for you:

1. [Autocorrelation / periodogram panels](@ref). Check out the [Examples](@ref) to get started.
2. [Animate panels (and export to .gif)](@ref). This allows you to check properties of an ensemble of surrogate realizations.
