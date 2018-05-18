
function surrplot(ts, surrogate; n_windows_periodogram = 100, gfs = 8, lfs = 6)
    p1 = Plots.plot(ts, label = ""); asurr = surrogate
    Plots.plot!(p1, surrogate, label = "")

    p2 = Plots.plot(autocor(ts), label = "")
    Plots.plot!(p2, autocor(surrogate), label = "")
    p, psurr = DSP.mt_pgram(ts), DSP.mt_pgram(surrogate)

    p3 = Plots.plot(intp([x for x in p.freq], p.power, n_windows_periodogram), label = "")
    Plots.plot!(p3, intp([x for x in psurr.freq], psurr.power, n_windows_periodogram), label = "")

    p4 = Plots.histogram(ts, label = "Original")
    Plots.histogram!(p4, surrogate, label = "Surrogate")

    Plots.xlabel!(p1, "Time step")
    Plots.ylabel!(p1, "Value")

    Plots.xlabel!(p2, "Lag")
    Plots.ylabel!(p2, "Autocorrelation")

    Plots.xlabel!(p3, "Binned frequency")
    Plots.ylabel!(p3, "Power")

    Plots.xlabel!(p4, "Binned value")
    Plots.ylabel!(p4, "Frequency")

    l = @layout [a{0.3h}; b{0.25h}; c{0.25h}; d{0.2h}]
    Plots.plot(p1, p2, p3, p4,
                layout = l,
                guidefont = (gfs, gfs, gfs, gfs),
                legendfont = (lfs, lfs, lfs, lfs)
                )
end

export surrplot
