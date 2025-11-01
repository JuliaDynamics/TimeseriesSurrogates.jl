# API

TimeseriesSurrogates.jl API is composed by four names: [`surrogate`](@ref), [`surrogenerator`](@ref), [`SurrogateTest`](@ref), and [`pvalue`](@ref). They dispatch on the method to generate surrogates, which is a subtype of [`Surrogate`](@ref).

It is recommended to standardize the signal before using doing any surrogate analysis, i.e. subtract mean and divide by standard deviation. The function `standardize` does this.

## Generating surrogates

```@docs
surrogate
surrogenerator
```

## Hypothesis testing

```@docs
SurrogateTest
fill_surrogate_test!
pvalue(::SurrogateTest)
```

# Surrogate methods

```@docs
Surrogate
```

```@index
Order = [:type]
```

## Shuffle-based

```@docs
RandomShuffle
BlockShuffle
CycleShuffle
CircShift
```

## Fourier-based

```@docs
RandomFourier
TFTDRandomFourier
PartialRandomization
PartialRandomizationAAFT
RelativePartialRandomization
RelativePartialRandomizationAAFT
SpectralPartialRandomization
SpectralPartialRandomizationAAFT
AAFT
TAAFT
IAAFT
```

## Non-stationary

```@docs
TFTS
TFTD
TFTDAAFT
TFTDIAAFT
```

## Pseudo-periodic

```@docs
PseudoPeriodic
PseudoPeriodicTwin
```

## Wavelet-based

```@docs
WLS
RandomCascade
```

## Other

```@docs
AutoRegressive
ShuffleDimensions
IrregularLombScargle
```

## Utilities

```@docs
noiseradius
```

# Visualization

TimeseriesSurrogates.jl has defined a simple function `surroplot(x, s)`.
This comes into scope when `using Makie` (you also need a plotting backend).
This functionality requires you to be using Julia 1.9 or later versions.

```@docs
surroplot
```

Example:

```@example MAIN
using TimeseriesSurrogates
using CairoMakie
x = AR1() # create a realization of a random AR(1) process
fig = surroplot(x, AAFT())
save("surroplot.png", fig); # hide
```