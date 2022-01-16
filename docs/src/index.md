# TimeseriesSurrogates.jl

![](surroplot.png)

`TimeseriesSurrogates` is a Julia package for generating surrogate timeseries. It is part of [JuliaDynamics](https://juliadynamics.github.io/JuliaDynamics/), a GitHub organization dedicated to creating high quality scientific software.

If you are new to this method of [surrogate time series](https://en.wikipedia.org/wiki/Surrogate_data_testing), feel free to read the [What is a surrogate?](@ref) page.

## API

TimeseriesSurrogates.jl exports two main functions. Both of them dispatch on the chosen method, a subtype of `Surrogate`.
It is recommended to standardize the signal before using these functions, i.e. subtract mean and divide by standard deviation.

```@docs
surrogate
surrogenerator
```

## Surrogate methods

```@index
Order   = [:type]
```

```@docs
RandomShuffle
BlockShuffle
CycleShuffle
CircShift
RandomFourier
TFTS
AAFT
TAAFT
IAAFT
AutoRegressive
PseudoPeriodic
PseudoPeriodicTwin
WLS
ShuffleDimensions
```

### Utils

```@docs
noiseradius
```

## Visualization

TimeseriesSurrogates.jl provides the function `surroplot(x, s)`, which comes into scope when `using Plots`. This function is used in the example applications.

## Installation

TimeseriesSurrogates is a registered Julia package. To install the latest version, run the following in your Julia console.

```julia
import Pkg; Pkg.add("TimeseriesSurrogates")
```

