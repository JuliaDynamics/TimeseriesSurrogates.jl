using TimeseriesSurrogates.StatsBase
using TimeseriesSurrogates.DSP

"""
    surroplot(x, s; kwargs...) → fig

Plot a timeseries `x` along with its surrogate realization `s`, and compare the
power spectrum and histogram of the two time series.

## Keyword arguments
- `cx` and `cs`: Colors of the original and the surrogate time series, respectively.
- `nbins`: The number of bins for the histograms.
- `resolution`: A tuple giving the resolution of the figure.
"""
function surroplot(x, s;
        cx = "#1B1B1B", cs = ("#2DB9C5", 0.9), resolution = (500, 500),
        nbins = 50,
    )

    t = 1:length(x)
    fig = Makie.Figure(resolution = resolution)

    # Time series
    ax1, _ = Makie.lines(fig[1,1], t, x; color = cx)
    Makie.lines!(ax1, t, s; color = cs)

    # Binned multitaper periodograms
    p, psurr = DSP.mt_pgram(x), DSP.mt_pgram(s)
    ax3 = Makie.Axis(fig[2,1]; yscale = log10)
    Makie.lines!(ax3, p.freq, p.power; color = cx)
    Makie.lines!(ax3, psurr.freq, psurr.power; color = cs)

    # Histograms
    ax4 = Makie.Axis(fig[3,1])
    Makie.hist!(ax4, x; label = "original", bins = nbins, color = cx)
    Makie.hist!(ax4, s; label = "surrogate", bins = nbins, color = cs)
    Makie.axislegend(ax4)

    ax1.xlabel = "time step"
    ax1.ylabel = "value"
    ax3.xlabel = "frequency"
    ax3.ylabel = "power"
    ax4.xlabel = "binned value"
    ax4.ylabel = "histogram"
    return fig
end
export surroplot