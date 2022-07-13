# TimeseriesSurrogates.jl

![](surroplot.png)

`TimeseriesSurrogates` is a Julia package for generating surrogate timeseries. It is part of [JuliaDynamics](https://juliadynamics.github.io/JuliaDynamics/), a GitHub organization dedicated to creating high quality scientific software.

If you are new to this method of [surrogate time series](https://en.wikipedia.org/wiki/Surrogate_data_testing), feel free to read the [What is a timeseries surrogate?](@ref) page.
Please note that timeseries surrogates should not be confused with [surrogate models](https://en.wikipedia.org/wiki/Surrogate_model), such as those provided by [Surrogates.jl](https://github.com/SciML/Surrogates.jl).

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
TFTDRandomFourier
PartialRandomization
PartialRandomizationAAFT
TFTS
TFTD
TFTDAAFT
TFTDIAAFT
AAFT
TAAFT
IAAFT
AutoRegressive
PseudoPeriodic
PseudoPeriodicTwin
WLS
RandomCascade
ShuffleDimensions
IrregularLombScargle
```

### Utilities

```@docs
noiseradius
```

## Visualization

TimeseriesSurrogates.jl has defined a simple function `surroplot(x, s)`.
This comes into scope when `using Makie` (you also need a plotting backend).

To load the function, do:
```@example MAIN
using TimeseriesSurrogates
using CairoMakie, Makie
using TimeseriesSurrogates, CairoMakie, Makie
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, AAFT())
fig = surroplot(ts, s)
save("surroplot.png", fig); # hide
```

## Installation

TimeseriesSurrogates is a registered Julia package. To install the latest version, run the following in your Julia console.

```julia
import Pkg; Pkg.add("TimeseriesSurrogates")
```

