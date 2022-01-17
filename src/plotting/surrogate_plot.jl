using TimeseriesSurrogates.StatsBase
using TimeseriesSurrogates.DSP

"""
    surroplot(x, s; kwargs...)

Plot a timeseries `x` along with its surrogate realization `s`, and compare the
periodogram and histogram of the two time series.

## Keyword arguments 
- `cx` and `cs`: Colors of the original and the surrogate time series, respectively.
- `nbins`: The number of bins for the histograms. 
- `resolution`: A tuple giving the resolution of the figure.
"""
function surroplot(x, s;
        cx = "#1B1B1B", cs = ("#2DB9C5", 0.9), resolution = (500, 600), 
        nbins = 50,
    )
    
    t = 1:length(x)
    fig = Makie.Figure(resolution = resolution)
    
    # Time series
    ax1, _ = Makie.lines(fig[1,1], t, x; color = cx)
    Makie.lines!(ax1, t, s; color = cs)
    # Autocorrelation
    acx = autocor(x)
    ax2, _ = Makie.lines(fig[2,1], 0:length(acx)-1, acx; color = cx)
    Makie.lines!(ax2, 0:length(acx)-1, autocor(s); color = cs)

    # Binned multitaper periodograms
    p, psurr = DSP.mt_pgram(x), DSP.mt_pgram(s)
    ax3 = Makie.Axis(fig[3,1]; yscale = log10)
    Makie.lines!(ax3, p.freq, p.power; color = cx)
    Makie.lines!(ax3, psurr.freq, psurr.power; color = cs)

    # Histograms
    ax4 = Makie.Axis(fig[4,1])
    Makie.hist!(ax4, x; label = "Original", bins = nbins, color = (cx, 0.5))
    Makie.hist!(ax4, s; label = "Surrogate", bins = nbins, color = (cs, 0.5))
    Makie.axislegend(ax4)

    ax1.xlabel = "time step"
    ax1.ylabel = "value"
    ax2.xlabel = "lag"
    ax2.ylabel = "autocor"
    ax3.xlabel = "binned freq."
    ax3.ylabel = "power"
    ax4.xlabel = "binned value"
    ax4.ylabel = "histogram"
    return fig
end
export surroplot