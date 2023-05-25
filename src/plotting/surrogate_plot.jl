using TimeseriesSurrogates.StatsBase
using TimeseriesSurrogates.DSP

export surroplot!, surroplot

"""
    surroplot(x, s; kwargs...) → fig

In a new figure, plot a timeseries `x` along with its surrogate realization `s`,
and compare the power spectrum and histogram of the two time series.
See [`surroplot!`](@ref).

## Keyword arguments
- `cx` and `cs`: Colors of the original and the surrogate time series, respectively.
- `nbins`: The number of bins for the histograms.
- `resolution`: A tuple giving the resolution of the figure.
"""
function surroplot(x, s; resolution = (500, 500), kwargs...)
    f = Makie.Figure(; resolution)
    ax = [Makie.Axis(f[i, 1]) for i in 1:3]
    surroplot!(ax, x, s; kwargs...)
    return f
end

"""
    surroplot!(ax::AbstractVector{<:Axis}, x, s; kwargs...)

Plot a timeseries `x` along with its surrogate realization `s` in a set of axes as follows:
    - `ax[1]`: The time series, and its surrogate
    - `ax[2]`: The power spectrum of `x` and `s`
    - `ax[3]`: The histograms of `x` and `s`

Also see [`surroplot`](@ref).

## Keyword arguments
- `cx` and `cs`: Colors of the original and the surrogate time series, respectively.
- `nbins`: The number of bins for the histograms.
"""
function surroplot!(ax::AbstractVector{<:Makie.Axis}, x, s;
        cx = "#1B1B1B", cs = ("#2DB9C5", 0.9), nbins = 50)

    t = 1:length(x)

    # Time series
    if length(ax) > 0
        Makie.lines!(ax[1], t, x; color = cx, label = "original")
        Makie.lines!(ax[1], t, s; color = cs, label = "surrogate")
        ax[1].xlabel = "time step"
        ax[1].ylabel = "value"
    end

    # Binned multitaper periodograms
    if length(ax) > 1
        p, psurr = DSP.mt_pgram(x), DSP.mt_pgram(s)
        Makie.lines!(ax[2], p.freq, p.power; color = cx, label = "original")
        Makie.lines!(ax[2], psurr.freq, psurr.power; color = cs, label = "surrogate")
        ax[2].yscale = log10
        ax[2].xlabel = "frequency"
        ax[2].ylabel = "power"
    end

    # Histograms
    if length(ax) > 2
        Makie.hist!(ax[3], x; label = "original", bins = nbins, color = cx)
        Makie.hist!(ax[3], s; label = "surrogate", bins = nbins, color = cs)
        Makie.axislegend(ax[3])
        ax[3].xlabel = "binned value"
        ax[3].ylabel = "histogram"
    end
    return ax
end
