# TimeseriesSurrogates.jl

A Julia package for generating [surrogate time series](https://en.wikipedia.org/wiki/Surrogate_data_testing).

[](examples/iaaft_ex.png)

## I'm new to surrogate testing

Then you might want to check out
1. [The method of surrogate testing](@ref)
2. [What is a surrogate time series?](@ref)
3. [Types of surrogate realizations](@ref)

## I'm experienced with surrogate testing

Then you're probably want to check out what [Types of surrogate realizations](@ref) this package provides. You'll find:

1. [Random shuffle surrogates (RS)](@ref), which are just random permutations of the time series.
2. [Fourier surrogates (FS)](@ref), in the form of either [Random amplitude surrogates](@ref) or [Random phase surrogates](@ref).
3. [Amplitude adjusted Fourier transform surrogates](@ref). Currently, the [Amplitude adjusted Fourier transform (AAFT)](@ref) and [Iterated AAFT (AAFT)](@ref) methods are implemented.


## I want to visualize my surrogate realizations

Then you might save some time by checking out the links below.
TimeseriesSurrogates.jl provides some convenient plotting routines that'll make it easy to
check if your surrogates are successfully capturing your target null hypothesis:

1. [Autocorrelation / periodogram panels](@ref). Check out the [Examples](@ref) to get started.
2. [Animate panels (and export to .gif)](@ref). This allows you to check properties of an ensemble of surrogate realizations.
