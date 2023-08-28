"""
    surrocompare(x, A, params; kwargs...) → fig

Plot the surrogates of a timeseries `x` using the Cartesian product of:
- the algorithms in the iterable collection `A` (`eltype(A) <: Surrogate`),
- a list of parameters passed to each algorithm, in `params`.

## Keyword arguments
- `color`: Colors surrogate time series.
- `linewidth`: Width of the surrogate time series.
- `kwargs...`: Propagated to `Makie.Figure`.
- `resolution`: A tuple giving the resolution of the figure.
"""
function surrocompare end
export surrocompare
