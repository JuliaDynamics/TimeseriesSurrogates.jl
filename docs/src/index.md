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
RandomShuffle
BlockShuffle
RandomFourier
TFTS
AAFT
TAAFT
IAAFT
PseudoPeriodic
```

### Utils

```@docs
noiseradius
```

## Visualization

TimeseriesSurrogates.jl provides the function `surroplot(x, s)`, which comes into scope when `using Plots`. This function is used in the example applications.
