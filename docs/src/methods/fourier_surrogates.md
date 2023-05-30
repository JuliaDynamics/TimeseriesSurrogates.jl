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

Click through the figures below to compare the three algorithms for various values of $\alpha$.

```@raw html
<!DOCTYPE html>
<html>
    <head>
        <title>Image Switcher</title>
        <style>
            #image-container {
                display: flex;
                flex-direction: column;
                justify-content: flex-start;
                align-items: left;
                height: auto;
                width: auto;
            }

            #button-container {
                display: flex;
                justify-content: space-between;
                align-items: center;
                width: 500px; /* match the max-width of the image */
            }

            #image-switcher {
                max-width: 500px;
                height: auto;
            }

            .arrow-button {
                background-color: #f8f8f8;
                border: none;
                cursor: pointer;
                padding: 10px;
                border-radius: 15px; /* make the buttons rounded rectangles */
                margin: 10px;
                font-size: 18px;
                width: calc(50% - 20px); /* make the buttons fill up the entire width of the image */
                text-align: center; /* center the text within the buttons */
            }
        </style>
    </head>
    <body>
        <div id="image-container">
            <div id="button-container">
                <button id="prev-button" class="arrow-button">Previous</button>
                <button id="next-button" class="arrow-button">Next</button>
            </div>
            <img id="image-switcher" src="https://user-images.githubusercontent.com/42064608/241692822-01a6de9e-d78b-4d9c-af58-8a89c68b78fb.png" alt="image" />
        </div>

        <script>
            let images = ['https://user-images.githubusercontent.com/42064608/241692822-01a6de9e-d78b-4d9c-af58-8a89c68b78fb.png', 'https://user-images.githubusercontent.com/42064608/241692835-98279739-a1ba-4536-aa4f-904944a82a12.png', 'https://user-images.githubusercontent.com/42064608/241692845-ce4d197a-9d40-47e3-99be-c5a86b96faf1.png', 'https://user-images.githubusercontent.com/42064608/241692854-d8428ef2-7924-41cc-b911-010eba9e5414.png', 'https://user-images.githubusercontent.com/42064608/241692861-e3d8430b-6c78-425f-ba42-bbe095586073.png', 'https://user-images.githubusercontent.com/42064608/241692869-672415c4-8558-4453-925d-6c0b4a49b754.png', 'https://user-images.githubusercontent.com/42064608/241692882-d26cebff-45ad-4ad8-8aa4-d1e47b992ea8.png', 'https://user-images.githubusercontent.com/42064608/241692891-8db57c85-eee8-442b-a2c6-e09e15f5a0a5.png', 'https://user-images.githubusercontent.com/42064608/241692895-12457e5b-b067-4713-bdf2-7244859692cd.png'];

            let currentImageIndex = 0;

            document.getElementById('next-button').addEventListener('click', function() {
                currentImageIndex = (currentImageIndex + 1) % images.length;
                document.getElementById('image-switcher').src = images[currentImageIndex];
            });

            document.getElementById('prev-button').addEventListener('click', function() {
                currentImageIndex = (currentImageIndex - 1 + images.length) % images.length;
                document.getElementById('image-switcher').src = images[currentImageIndex];
            });
            document.getElementById('image-switcher').addEventListener('click', function() {
            currentImageIndex = (currentImageIndex + 1) % images.length; // this line ensures we loop back to the first image when we've gone through all images
            this.src = images[currentImageIndex];
            });
        </script>
    </body>
</html>
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
