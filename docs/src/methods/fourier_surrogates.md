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

 [`PartialRandomization`](@ref) surrogates are similar to random phase surrogates,
 but allow for tuning the "degree" of phase randomization.

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process

# 50 % randomization of the phases
s = surrogate(ts, PartialRandomization(0.5))

surroplot(ts, s)
```

We provide three algorithms for partially randomizing the Fourier phases.
The `PartialRandomizationAAFT` algorithm[^Ortega1998], ..............


[^Ortega1998]: Ortega, Guillermo J.; Louis, Enrique (1998). Smoothness Implies Determinism in Time Series: A Measure Based Approach. Physical Review Letters, 81(20), 4345–4348. doi:10.1103/PhysRevLett.81.4345

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
            <img id="image-switcher" src="https://user-images.githubusercontent.com/42064608/241539260-e1bae0ef-9be4-4472-b646-b3071d7362ff.png" alt="image" />
        </div>

        <script>
            let images = ['https://user-images.githubusercontent.com/42064608/241539260-e1bae0ef-9be4-4472-b646-b3071d7362ff.png', 'https://user-images.githubusercontent.com/42064608/241539282-8d0e1883-7e8d-4b0e-afb6-1727d553e8a5.png', 'https://user-images.githubusercontent.com/42064608/241539304-b48b7a26-b3ae-4693-ac79-dc32ba000c28.png', 'https://user-images.githubusercontent.com/42064608/241539311-3f460675-c3d9-4519-80d6-d477bf19cd3e.png', 'https://user-images.githubusercontent.com/42064608/241539322-a592154d-7d6f-4a05-83d4-e46fb9b07df9.png', 'https://user-images.githubusercontent.com/42064608/241539331-c3960e4c-8ce1-44cf-a83a-11f7a440a575.png', 'https://user-images.githubusercontent.com/42064608/241539355-2ef11f22-3713-42e3-94d8-b75cc709e12e.png', 'https://user-images.githubusercontent.com/42064608/241539375-211b5ba0-5584-461e-8a95-1167ae9d571c.png', 'https://user-images.githubusercontent.com/42064608/241539394-10f3aa0c-053b-4fc7-a4ac-b30c82f70a14.png'];

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

[`PartialRandomizationAAFT`](@ref) adds a rescaling step to the [`PartialRandomization`](@ref) surrogates to obtain surrogates that contain the same values as the original time
series.

```@example MAIN
using TimeseriesSurrogates, CairoMakie
ts = AR1() # create a realization of a random AR(1) process

# 50 % randomization of the phases
s = surrogate(ts, PartialRandomizationAAFT(0.7))

surroplot(ts, s)
```

<!-- The figure below shows how each partial-randomization algorithm behaves with an added AAFT rescaling step:
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
            <img id="image-switcher" src="https://user-images.githubusercontent.com/42064608/241563410-970283c7-22ad-421e-b480-5d1b29b0c4a4.png" alt="image" />
        </div>

        <script>
            let images = ['https://user-images.githubusercontent.com/42064608/241563410-970283c7-22ad-421e-b480-5d1b29b0c4a4.png', 'https://user-images.githubusercontent.com/42064608/241563412-37799912-a437-44ce-8474-a6e703c551ad.png', 'https://user-images.githubusercontent.com/42064608/241563416-500c75cb-3cb9-4492-984e-8519c6588ab4.png', 'https://user-images.githubusercontent.com/42064608/241563419-2c143ed9-24e7-4a01-b987-ddad72a4c043.png', 'https://user-images.githubusercontent.com/42064608/241563422-ef8dbfd4-07e9-416a-a52b-00a9be7799d6.png', 'https://user-images.githubusercontent.com/42064608/241563425-17dd864f-6018-4f54-955e-76b684b0ae6b.png', 'https://user-images.githubusercontent.com/42064608/241563431-e87d2b52-21d4-4941-9927-ed5fd15e069e.png', 'https://user-images.githubusercontent.com/42064608/241563435-a9f826b1-54be-407e-a6d0-648d2b2ce08d.png', 'https://user-images.githubusercontent.com/42064608/241563437-6b2d3dec-5d08-482f-b916-38a8d24e8d06.png']

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
``` -->

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
