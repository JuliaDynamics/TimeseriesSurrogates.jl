using StatsBase
using DSP

"""
    surroplot(x, s; W = 100, gfs = 8, lfs = 6, 
        cx = :black, cs = :red, size = (400, 600); kwargs...)

Plot a time series along with its surrogate realization `s`, and compare the
periodogram and histogram of the two time series.

## Arguments

- **`x`**: the time series for which to generate a surrogate.

- **`s`** is the surrogate realization of the time series.

## Keyword arguments 

- **`W`**: Sets the number of windows for binning the periodogram.

- **`gfs`** and **`lfs`**: Fontsizes of the guides and legends, respectively.

- **`cx`** and **`cs`**: Colors of the original and the surrogate time series, respectively.

- **`size`**: A tuple giving the size of the assembled plot. 

- **`nbins`**: The number of bins for the histograms. 

- **`kwargs`**: Plots.jl keyword arguments that are supplied to the final `plot` call that assembles the subplots.
"""
function surroplot(x, s; W = 100, gfs = 8, lfs = 6, 
        cx = :black, cs = :red, size = (500, 600), 
        nbins = 50, kwargs...)
    
    # Time series
    p1 = Plots.plot()
    Plots.plot!(x, label = "", c = cx); 
    Plots.plot!(s, label = "", c = cs)

    # Autocorrelation
    p2 = Plots.plot()
    Plots.plot!(autocor(x), label = "", c = cx)
    Plots.plot!(autocor(s), label = "", c = cs)

    # Binned multitaper periodograms
    p, psurr = DSP.mt_pgram(x), DSP.mt_pgram(s)
    p3 = Plots.plot() 
    Plots.plot!(interp([x for x in p.freq], p.power, W), label = "", c = cx, yaxis = :log10)
    Plots.plot!(interp([x for x in psurr.freq], psurr.power, W), label = "", c = cs, yaxis = :log10)

    # Histograms
    p4 = Plots.plot()
    Plots.histogram!(x, label = "Original", alpha = 0.5, nbins = nbins, c = cx)
    Plots.histogram!(s, label = "Surrogate", alpha = 0.5, nbins = nbins, c = cs)

    Plots.xlabel!(p1, "Time step")
    Plots.ylabel!(p1, "Value")

    Plots.xlabel!(p2, "Lag")
    Plots.ylabel!(p2, "Autocorrelation")

    Plots.xlabel!(p3, "Binned frequency")
    Plots.ylabel!(p3, "Power")

    Plots.xlabel!(p4, "Binned value")
    Plots.ylabel!(p4, "Frequency")

    l = Plots.@layout [a{0.3h}; b{0.25h}; c{0.25h}; d{0.2h}]
    Plots.plot(p1, p2, p3, p4;
                layout = l,
                guidefont = Plots.font(gfs),
                legendfont = Plots.font(lfs),
                size = size,
                kwargs...
                )
end

export surroplot
