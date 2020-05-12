# Visualizing surrogates

Notice that the functionality of this page only becomes available once you do `using Plots`.

## Autocorrelation / periodogram panels

Visualizing a surrogate realization is easy, and it is based on the Plots.jl ecosystem.


Let's say we want to generate an IAAFT surrogate and visualize the time series and surrogate time series, together with the corresponding periodograms,  autocorrelation functions and histograms. This can be done as follows:

```@example
using TimeseriesSurrogates, Plots
ts = diff(rand(300))
IAAFT_plot(ts)
```

Here, the blue lines correspond to the original time series, while orange lines correspond to the surrogate time series. In this particular case, it seems that the IAAFT surrogate well reproduced the autocorrelation of the original time series.

All surrogate functions come have complementary functions that also plots a panel
showing the autocorrelation function and periodogram of the time series and its surrogate realization:

- `RandomShuffle` has `RandomShuffle_plot`
- `BlockShuffle` has `BlockShuffle_plot`
- `RandomFourier` has `RandomFourier_plot`
- `AAFT` has `AAFT_plot`
- `IAAFT` has `IAAFT_plot`
- `PseudoPeriodic` has `PseudoPeriodic_plot`

## Animate panels (and export to .gif/.mov)

Say you want to examine which surrogate method is suited for a particular dataset. It would then be useful to visualize multiple surrogate realizations for that time series.

For this purpose, each surrogate function comes with corresponding animation functions 

- `RandomShuffle` has `RandomShuffle_plot`
- `BlockShuffle` has `BlockShuffle_plot`
- `RandomFourier` has `RandomFourier_plot`
- `AAFT` has `AAFT_plot`
- `IAAFT` has `IAAFT_plot`
- `PseudoPeriodic` has `PseudoPeriodic_plot`

gif creation functions, 

- `RandomShuffle` has `RandomShuffle_gif`
- `BlockShuffle` has `BlockShuffle_gif`
- `RandomFourier` has `RandomFourier_gif`
- `AAFT` has `AAFT_gif`
- `IAAFT` has `IAAFT_gif`
- `PseudoPeriodic` has `PseudoPeriodic_gif`

and mp4 video creation functions 

- `RandomShuffle` has `RandomShuffle_mp4`
- `BlockShuffle` has `BlockShuffle_mp4`
- `RandomFourier` has `RandomFourier_mp4`
- `AAFT` has `AAFT_mp4`
- `IAAFT` has `IAAFT_mp4`
- `PseudoPeriodic` has `PseudoPeriodic_mp4`

You can either generate the gif/mp4 file directly, or create a `Plots.animation` instance containing the animation. 

Supply the keyword `filename` (e.g. `filename = somegif.gif`) to save the file to a specified path if creating gif or mp4 files.

Here's some examples:

```julia
using TimeseriesSurrogates
ts = diff(rand(300))

# Creating a gif directly

# Create a gif using the default number (15) surrogates
IAAFT_gif(ts)
IAAFT_gif(ts, fps = 3) # specify frame rate

# Specify that we want 100 different surrogate realizations
IAAFT_gif(ts, n_iters = 100)
IAAFT_gif(ts, n_iters = 100, fps = 1) # specify frame rate
```

If you for some reason don't want a gif directly, then you could do

```julia
# Use the `gif` function from `Plots.jl` to create a gif
anim = IAAFT_anim(ts, n_iters = 50) # create an animation
gif(anim)
gif(anim, fps = 3) # specifying frame rate
```
