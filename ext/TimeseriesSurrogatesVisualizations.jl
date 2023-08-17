module TimeseriesSurrogatesVisualizations

using TimeseriesSurrogates, Makie

function TimeseriesSurrogates.surroplot(x, s;
        cx = "#191E44", cs = ("#7143E0", 0.9), resolution = (500, 500),
        nbins = 50,
    )

    t = 1:length(x)
    fig = Makie.Figure(resolution = resolution)

    # Time series
    ax1, _ = Makie.lines(fig[1,1], t, x; color = cx, linewidth = 2)
    Makie.lines!(ax1, t, s; color = cs, linewidth = 2)

    # Binned multitaper periodograms
    p, psurr = TimeseriesSurrogates.DSP.mt_pgram(x), TimeseriesSurrogates.DSP.mt_pgram(s)
    ax3 = Makie.Axis(fig[2,1]; yscale = log10)
    Makie.lines!(ax3, p.freq, p.power; color = cx, linewidth = 3)
    Makie.lines!(ax3, psurr.freq, psurr.power; color = cs, linewidth = 3)

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

function TimeseriesSurrogates.surroplot(x, method::Surrogate; kwargs...)
    s = surrogate(x, method)
    return surroplot(x, s; kwargs...)
end

end