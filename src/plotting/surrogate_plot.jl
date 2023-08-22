"""
    surroplot(x, s; kwargs...) → fig
    surroplot(x, method::Surrogate; kwargs...) → fig
    surroplot!(fig_or_gridlayout, x, method::Surrogate)

Plot a timeseries `x` along with its surrogate realization `s`, and compare the
power spectrum and histogram of the two time series. If given a method to generate
surrogates, create a surrogate from `x` and plot it.

## Keyword arguments
- `cx` and `cs`: Colors of the original and the surrogate time series, respectively.
- `nbins`: The number of bins for the histograms.
- `kwargs...`: Propagated to `Makie.Figure`.
- `resolution`: A tuple giving the resolution of the figure.
"""
function surroplot end
function surroplot! end
export surroplot, surroplot!