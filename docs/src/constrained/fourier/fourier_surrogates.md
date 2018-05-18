# Fourier surrogates
Create a constrained surrogate by taking the Fourier transform of the time series,
then shuffling either the phase angles or the amplitudes of the complex numbers,
before doing the inverse Fourier transform.


## Random amplitude surrogates

```@docs
TimeseriesSurrogates.randomamplitudes
```

### Example of random amplitude surrogate

```@example
using TimeseriesSurrogates
ts = NSAR2()
surrogate = randomamplitudes(ts)

surrplot(ts, surrogate)
```

### Random amplitude surrogates on the same initial time series

```julia
randomamplitudes_NSAR2_gif(n_iters = 30, fps = 5)
```

![30 random phase surrogates for a single realization of a cyclostationary AR(2) process](../../examples/randomamplitudes_NSAR2.gif)


### Random amplitude surrogates on different initial time series

```julia
randomamplitudes_NSAR2_gif(n_iters = 30, fps = 5,
                        new_realization_every_iter = true)
```

![30 realizations of a cyclostationary AR(2) process. One random phase surrogate per realization of the time series.](../../examples/randomamplitudes_NSAR2_newevery.gif)



## Random phase surrogates
```@docs
TimeseriesSurrogates.randomphases
```

### Example of random phase surrogate

```@example
using TimeseriesSurrogates
ts = NSAR2()
surrogate = randomphases(ts)

surrplot(ts, surrogate)
```

### Random phase surrogates on the same initial time series

```julia
randomphases_NSAR2_gif(n_iters = 30, fps = 5)
```

![30 random phase surrogates for a single realization of a cyclostationary AR(2) process](../../examples/randomphases_NSAR2.gif)


### Random phase surrogates on different initial time series

```julia
randomphases_NSAR2_gif(n_iters = 30, fps = 5,
                        new_realization_every_iter = true)
```

![30 realizations of a cyclostationary AR(2) process. One random phase surrogate per realization of the time series.](../../examples/randomphases_NSAR2_newevery.gif)
