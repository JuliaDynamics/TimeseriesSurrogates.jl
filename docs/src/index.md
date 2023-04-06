# TimeseriesSurrogates.jl

![](surroplot.png)

`TimeseriesSurrogates` is a Julia package for generating surrogate timeseries. It is part of [JuliaDynamics](https://juliadynamics.github.io/JuliaDynamics/), a GitHub organization dedicated to creating high quality scientific software.

If you are new to this method of surrogate timeseries, feel free to read the [Crash-course into timeseries surrogate tests](@ref) page.

Please note that timeseries surrogates should not be confused with [surrogate models](https://en.wikipedia.org/wiki/Surrogate_model), such as those provided by [Surrogates.jl](https://github.com/SciML/Surrogates.jl).

## Installation

TimeseriesSurrogates.jl is a registered Julia package. To install the latest version, run the following code:

```julia
import Pkg; Pkg.add("TimeseriesSurrogates")
```

## API

TimeseriesSurrogates.jl exports two main functions. Both of them dispatch on the chosen method, a subtype of `Surrogate`.
It is recommended to standardize the signal before using these functions, i.e. subtract mean and divide by standard deviation.

```@docs
surrogate
surrogenerator
```

## Hypothesis testing

```@docs
SurrogateTest
pvalue(::SurrogateTest)
```

## Surrogate methods

```@index
Order = [:type]
```

### Shuffle-based

```@docs
RandomShuffle
BlockShuffle
CycleShuffle
CircShift
```

### Fourier-based

```@docs
RandomFourier
TFTDRandomFourier
PartialRandomization
PartialRandomizationAAFT
AAFT
TAAFT
IAAFT
```

### Non-stationary

```@docs
TFTS
TFTD
TFTDAAFT
TFTDIAAFT
```

### Pseudo-periodic

```@docs
PseudoPeriodic
PseudoPeriodicTwin
```

### Wavelet-based

```@docs
WLS
RandomCascade
```

### Other

```@doc
AutoRegressive
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

## Citing

Please use the following BiBTeX entry, or DOI, to cite TimeseriesSurrogates.jl:

DOI: https://doi.org/10.21105/joss.04414

BiBTeX:

```latex
@article{TimeseriesSurrogates.jl,
    doi = {10.21105/joss.04414},
    url = {https://doi.org/10.21105/joss.04414},
    year = {2022},
    publisher = {The Open Journal},
    volume = {7},
    number = {77},
    pages = {4414},
    author = {Kristian Agasøster Haaga and George Datseris},
    title = {TimeseriesSurrogates.jl: a Julia package for generating surrogate data},
    journal = {Journal of Open Source Software}
}
```