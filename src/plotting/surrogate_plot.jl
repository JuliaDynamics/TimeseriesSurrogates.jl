
"""
    surroplot(x, s; kwargs...) → fig

Plot a timeseries `x` along with its surrogate realization `s`, and compare the
power spectrum and histogram of the two time series.

## Keyword arguments
- `cx` and `cs`: Colors of the original and the surrogate time series, respectively.
- `nbins`: The number of bins for the histograms.
- `resolution`: A tuple giving the resolution of the figure.
"""
function surroplot end