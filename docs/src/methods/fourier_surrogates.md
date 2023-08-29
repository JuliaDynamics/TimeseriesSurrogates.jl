# Fourier-based

Fourier based surrogates are a form of constrained surrogates created by taking the Fourier
transform of a time series, then shuffling either the phase angles or the amplitudes of the resulting complex numbers. Then, we take the inverse Fourier transform, yielding a surrogate time series.

## Random phase

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process
phases = true
s = surrogate(ts, RandomFourier(phases))

surroplot(ts, s)
```

## Random amplitude

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process
phases = false
s = surrogate(ts, RandomFourier(phases))

surroplot(ts, s)
```


## Partial randomization

### Without rescaling

[`PartialRandomization`](@ref) surrogates are similar to random phase surrogates, but allow for tuning the "degree" of phase randomization. 
[`PartialRandomization`](@ref) use an algorithm introduced by [^Ortega1998], which draws random phases as:

$$\phi \to \alpha \xi , \quad \xi \sim \mathcal{U}(0, 2\pi),$$

where $\phi$ is a Fourier phase and $\mathcal{U}(0, 2\pi)$ is a uniform distribution.
Tuning the randomization parameter, $\alpha$, produces a set of time series with varying degrees of randomness in their Fourier phases. 

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process

# 50 % randomization of the phases
s = surrogate(ts, PartialRandomization(0.5))

surroplot(ts, s)
```

In addition to [`PartialRandomization`](@ref), we provide two other algorithms for producing partially randomized surrogates, outlined below.

### Relative partial randomization

The [`PartialRandomization`](@ref) algorithm corresponds to assigning entirely new phases to the Fourier spectrum with some degree of randomness, regardless of any deterministic structure in the original phases. As such, even for $\alpha = 0$ the surrogate time series can differ drastically from the original time series.

By contrast, the [`RelativePartialRandomization`](@ref) procedure draws phases as:

$$\phi \to \phi + \alpha \xi, \quad \xi \sim \mathcal{U}(0, 2\pi).$$

With this algorithm, phases are progressively corrupted by higher values of $\alpha$: surrogates are identical to the original time series for $\alpha = 0$, equivalent to random noise for $\alpha = 1$, and retain some of the structure of the original time series when $0 < \alpha < 1$. This procedure is particularly useful for controlling the degree of chaoticity and non-linearity in surrogates of chaotic systems.

### Spectral partial randomization

Both of the algorithms above randomize phases at all frequency components to the same degree.
To assess the contribution of different frequency components to the structure of a time series, the [`SpectralPartialRandomization`](@ref) algorithm only randomizes phases above a frequency threshold.
The threshold is chosen as the lowest frequency at which the power spectrum of the original time series drops below a fraction $1-\alpha$ of its maximum value (such that the power contained above the frequency threshold is a proportion $\alpha$ of the total power, excluding the zero frequency).

See the figure below for a comparison of the three partial randomization algorithms:
```@example MAIN
using DynamicalSystemsBase # hide
function surrocompare(x, surr_types, params; color = ("#7143E0", 0.9), N=1000, linewidth=3, # hide
                    transient=0, kwargs...) # hide
    fig = Makie.Figure(resolution = (1080, 480), fontsize=22, kwargs...) # hide
    for (j, a) in enumerate(surr_types) # hide
        for (i, p) in enumerate(params) # hide
            ax = Makie.Axis(fig[i,j]) # hide
            hidedecorations!(ax) # hide
            ax.ylabelvisible = true # hide
            lines!(ax, surrogate(x, a(p...))[transient+1:transient+N]; color, linewidth) # hide
            j == 1 && (ax.ylabel = "α = $(p)"; ax.ylabelfont = :bold) # hide
            i == 1 && (ax.title = string(a)) # hide
        end # hide
    end # hide
    colgap!(fig.layout, 30) # hide
    rowgap!(fig.layout, 30) # hide
    return fig # hide
end # hide
@inbounds function lorenz_rule!(du, u, p, t) # hide
    σ = p[1]; ρ = p[2]; β = p[3] # hide
    du[1] = σ*(u[2]-u[1]) # hide
    du[2] = u[1]*(ρ-u[3]) - u[2] # hide
    du[3] = u[1]*u[2] - β*u[3] # hide
    return nothing # hide
end # hide
u0 = [0, 10.0, 0] # hide
p0 = [10, 28, 8/3] # hide
diffeq = (; abstol = 1e-9, reltol = 1e-9) # hide
lorenz = CoupledODEs(lorenz_rule!, u0, p0; diffeq) # hide
x = trajectory(lorenz, 1000; Ttr=500, Δt=0.025)[1][:, 1] # hide
surr_types = [PartialRandomization, RelativePartialRandomization, SpectralPartialRandomization] # hide
params = [0.0, 0.1, 0.25] # hide
surrocompare(x, surr_types, params; transient=1000) # hide
```


### With rescaling

[`PartialRandomizationAAFT`](@ref) adds a rescaling step to the [`PartialRandomization`](@ref) surrogates to obtain surrogates that contain the same values as the original time series. AAFT versions of [`RelativePartialRandomization`](@ref) and [`SpectralPartialRandomization`](@ref) are also available.

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process

# 50 % randomization of the phases
s = surrogate(ts, PartialRandomizationAAFT(0.7))

surroplot(ts, s)
```
## Amplitude adjusted Fourier transform (AAFT)


```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, AAFT())

surroplot(ts, s)
```

## Iterative AAFT (IAAFT)

The IAAFT surrogates add an iterative step to the AAFT algorithm to improve similarity
of the power spectra of the original time series and the surrogates.

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process
s = surrogate(ts, IAAFT())

surroplot(ts, s)
```
