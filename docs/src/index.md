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
LS
```

### Utilities

```@docs
noiseradius
```

## Visualization

TimeseriesSurrogates.jl has defined a simple function `surroplot(x, s)`. But this is not exported nor even included in the code. It requires any package of the Makie.jl ecosystem already loaded to work.

To load the function, do:
```@example MAIN
using TimeseriesSurrogates
using CairoMakie # hide
include(surroplot_path())
```

## References
