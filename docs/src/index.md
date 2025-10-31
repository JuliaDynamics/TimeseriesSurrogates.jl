# TimeseriesSurrogates.jl

![](surroplot.png)

`TimeseriesSurrogates` is a Julia package for generating surrogate timeseries. It is part of [JuliaDynamics](https://juliadynamics.github.io/JuliaDynamics/), a GitHub organization dedicated to creating high quality scientific software.

To learn how to use the package, please follow the [Tutorial](@ref) page.
If you are new to this method of surrogate timeseries, the tutorial also includes a [crash-course in timeseries surrogate testing](@ref crash-course) section.
To see all available surrogate methods, see the [API](@ref) page.

Please note that timeseries surrogates should not be confused with [surrogate models](https://en.wikipedia.org/wiki/Surrogate_model), such as those provided by [Surrogates.jl](https://github.com/SciML/Surrogates.jl).

## Installation

TimeseriesSurrogates.jl is a registered Julia package. To install the latest version, run the following code:

```julia
import Pkg; Pkg.add("TimeseriesSurrogates")
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
