# Overview

# TODO: add example figure here.

If you are new to this method of [surrogate time series](https://en.wikipedia.org/wiki/Surrogate_data_testing), feel free to read the [What is a surrogate?](@ref) page.

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
