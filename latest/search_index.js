var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Overview",
    "title": "Overview",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#TimeseriesSurrogates.jl-1",
    "page": "Overview",
    "title": "TimeseriesSurrogates.jl",
    "category": "section",
    "text": "A Julia package for generating surrogate time series."
},

{
    "location": "index.html#I\'m-new-to-surrogate-testing-1",
    "page": "Overview",
    "title": "I\'m new to surrogate testing",
    "category": "section",
    "text": "Then you might want to check outThe method of surrogate testing\nWhat is a surrogate time series?\nTypes of surrogate realizations"
},

{
    "location": "index.html#I\'m-experienced-with-surrogate-testing-1",
    "page": "Overview",
    "title": "I\'m experienced with surrogate testing",
    "category": "section",
    "text": "Then you\'re probably want to check out what Types of surrogate realizations this package provides. You\'ll find:Random shuffle surrogates (RS), which are just random permutations of the time series.\nFourier surrogates (FS), in the form of either Random amplitude surrogates or Random phase surrogates.\nAmplitude adjusted Fourier transform surrogates. Currently, the Amplitude adjusted Fourier transform (AAFT) and Iterated AAFT (AAFT) methods are implemented."
},

{
    "location": "index.html#I-want-to-visualize-my-surrogate-realizations-1",
    "page": "Overview",
    "title": "I want to visualize my surrogate realizations",
    "category": "section",
    "text": "Then you might save some time by checking out the links below. TimeseriesSurrogates.jl provides some convenient plotting routines that\'ll make it easy to check if your surrogates are successfully capturing your target null hypothesis:Autocorrelation / periodogram panels. Check out the Examples to get started.\nAnimate panels (and export to .gif). This allows you to check properties of an ensemble of surrogate realizations."
},

{
    "location": "man/whatisasurrogate.html#",
    "page": "What is a surrogate?",
    "title": "What is a surrogate?",
    "category": "page",
    "text": ""
},

{
    "location": "man/whatisasurrogate.html#What-is-a-surrogate?-1",
    "page": "What is a surrogate?",
    "title": "What is a surrogate?",
    "category": "section",
    "text": ""
},

{
    "location": "man/whatisasurrogate.html#The-method-of-surrogate-testing-1",
    "page": "What is a surrogate?",
    "title": "The method of surrogate testing",
    "category": "section",
    "text": "The method of surrogate testing [1] is a statistical method for testing properties about a dynamical system whose governing equations is not known. This happens when the only information we have available about the system is a time series.Surrogate testing can be used to test, for example, the following properties about a data set or the underlying process [2]:does the dataset show evidence of nonlinearity?\ndoes the dataset show evidence of low-dimensional chaos?"
},

{
    "location": "man/whatisasurrogate.html#What-is-a-surrogate-time-series?-1",
    "page": "What is a surrogate?",
    "title": "What is a surrogate time series?",
    "category": "section",
    "text": "Let\'s say we have a nontrivial time series, call it X, consisting of n observations. A surrogate time series for X is another time series of n values which (roughly) preserves one or many mathematical/statistical properties of X.The upper panel in the figure below shows an example of a time series (blue) and one surrogate realization that preserves its autocorrelation (orange).  The time series \"look alike\", which is due to the fact the surrogate realization almost exactly preserved the power spectrum and autocorrelation of the time series, as shown in the lower panels.(Image: An iterated amplitude-adjusted Fourier transform surrogate realization for a time series. The surrogate realization preserves its autocorrelation function.)"
},

{
    "location": "man/whatisasurrogate.html#Types-of-surrogate-realizations-1",
    "page": "What is a surrogate?",
    "title": "Types of surrogate realizations",
    "category": "section",
    "text": "The preserved statistical properties can be anything, and must be decided based on which null hypothesis one wants to test for.Following the convention of Theiler and Prichard (1996), there are two main types of surrogates: constrained realizations and typical realizations."
},

{
    "location": "man/whatisasurrogate.html#Constrained-realizations-1",
    "page": "What is a surrogate?",
    "title": "Constrained realizations",
    "category": "section",
    "text": "The values of a constrained surrogate realization of a time series is just a shuffling of the values of the original time series. With TimeseriesSurrogates.jl, you can construct the following types of constrained surrogate realizations:Random shuffle surrogates (RS). Destroys any linear correlation in the signal, but preserves its amplitude distribution.\nFourier surrogates (FS). Have the same linear correlation, or periodogram, as X.\nAmplitude adjusted Fourier transform surrogates. Have the same linear correlation and the amplitude distribution as X."
},

{
    "location": "man/whatisasurrogate.html#Typical-realizations-1",
    "page": "What is a surrogate?",
    "title": "Typical realizations",
    "category": "section",
    "text": "Typical surrogate realizations are not generated by a permutation of the original values of the time series. Rather, they are generated by fitting some model to the data (intented to capture some important property of the system), and then using that model to generate surrogate realizations of the time series."
},

{
    "location": "man/whatisasurrogate.html#Literature-references-1",
    "page": "What is a surrogate?",
    "title": "Literature references",
    "category": "section",
    "text": "Theiler et al., Testing for nonlinearity in time series: the method of surrogate data, Physica D 58 (1992) 77-94.\nTheiler & Prichard, Constrained-realization Monte-Carlo method for hypothesis testing, Physica D 94 (1996) 221-235"
},

{
    "location": "constrained/randomshuffle.html#",
    "page": "Random shuffle (RS)",
    "title": "Random shuffle (RS)",
    "category": "page",
    "text": ""
},

{
    "location": "constrained/randomshuffle.html#TimeseriesSurrogates.randomshuffle",
    "page": "Random shuffle (RS)",
    "title": "TimeseriesSurrogates.randomshuffle",
    "category": "function",
    "text": "randomshuffle(ts)\n\nGenerate a random constrained surrogate for ts. Destroys any linear correlation in the signal, but preserves its amplitude distribution.\n\nts Is the time series for which to generate an AAFT surrogate realization.\n\n\n\n"
},

{
    "location": "constrained/randomshuffle.html#Random-shuffle-surrogates-(RS)-1",
    "page": "Random shuffle (RS)",
    "title": "Random shuffle surrogates (RS)",
    "category": "section",
    "text": "TimeseriesSurrogates.randomshuffleThe easiest way of constructing a constrained surrogate is just shuffling the time indices of the original time series. Here\'s an example:using TimeseriesSurrogates\n\n# Generate a time series. Here, we\'ll use an AR1 process.\nts = AR1()\n\n# Generate a random shuffle surrogate realization\nsurrogate = randomshuffle(ts)\n\n# Plot the surrogate along with the time series it is based on, along with autocorrelation\n# and periodogram plots.\nsurrplot(ts, surrogate)"
},

{
    "location": "constrained/fourier_surrogates.html#",
    "page": "Fourier transform (FT)",
    "title": "Fourier transform (FT)",
    "category": "page",
    "text": ""
},

{
    "location": "constrained/fourier_surrogates.html#Fourier-surrogates-(FS)-1",
    "page": "Fourier transform (FT)",
    "title": "Fourier surrogates (FS)",
    "category": "section",
    "text": "Fourier surrogates are a form of constrained surrogates created by taking the Fourier transform of a time series, then shuffling either the phase angles or the amplitudes of the resulting complex numbers. Then, we take the inverse Fourier transform, yielding a surrogate time series."
},

{
    "location": "constrained/fourier_surrogates.html#TimeseriesSurrogates.randomphases",
    "page": "Fourier transform (FT)",
    "title": "TimeseriesSurrogates.randomphases",
    "category": "function",
    "text": "randomphases(ts)\n\nCreate a random phases surrogate for ts [1]. Surrogate realizations using the phase surrogates have the same linear correlation, or periodogram, as the original data.\n\nts Is the time series for which to generate an AAFT surrogate realization.\n\nLiterature references\n\nJ. Theiler et al., Physica D 58 (1992) 77-94 (1992).\n\n\n\n"
},

{
    "location": "constrained/fourier_surrogates.html#Random-phase-surrogates-1",
    "page": "Fourier transform (FT)",
    "title": "Random phase surrogates",
    "category": "section",
    "text": "TimeseriesSurrogates.randomphasesHere\'s how you would generate a phase surrogate realization of a time series.using TimeseriesSurrogates\n\n# Generate a time series. This time, we\'ll use a NSAR2() process.\nts = NSAR2()\n\n# Generate a random phase surrogate realization\nsurrogate = randomphases(ts)\n\n# Plot the surrogate along with the time series it is based on, along with autocorrelation\n# and periodogram plots.\nsurrplot(ts, surrogate)"
},

{
    "location": "constrained/fourier_surrogates.html#How-do-random-phase-surrogates-vary-across-realizations?-1",
    "page": "Fourier transform (FT)",
    "title": "How do random phase surrogates vary across realizations?",
    "category": "section",
    "text": "Below is a plot showing different phase surrogate realizations (orange) over the same time series (blue). Each frame in the animation is a different surrogate realization. Note that the autocorrelations are roughly similar across realizations.randomphases_NSAR2_gif(n_iters = 30, fps = 5)(Image: 30 random phase surrogates for a single realization of a cyclostationary AR(2) process)In the next animation, the time series (blue) for which we generate surrogates change between frames. One phase surrogate realization (orange) is generated for each of the time series. Notice that, again, the phase surrogates accurately represents the autocorrelation of the different initial time series.randomphases_NSAR2_gif(n_iters = 30, fps = 5, new_realization_every_iter = true)(Image: 30 realizations of a cyclostationary AR(2) process. One random phase surrogate per realization of the time series.)"
},

{
    "location": "constrained/fourier_surrogates.html#TimeseriesSurrogates.randomamplitudes",
    "page": "Fourier transform (FT)",
    "title": "TimeseriesSurrogates.randomamplitudes",
    "category": "function",
    "text": "randomamplitudes(ts)\n\nCreate a random amplitude surrogate for ts.\n\nA modification of the random phases surrogates [1] where amplitudes are adjusted instead of the phases after taking the Fourier transform.\n\nts Is the time series for which to generate an AAFT surrogate realization.\n\nLiterature references\n\nJ. Theiler et al., Physica D 58 (1992) 77-94 (1992))\n\n\n\n"
},

{
    "location": "constrained/fourier_surrogates.html#Random-amplitude-surrogates-1",
    "page": "Fourier transform (FT)",
    "title": "Random amplitude surrogates",
    "category": "section",
    "text": "TimeseriesSurrogates.randomamplitudesThis is how you would generate a random amplitude surrogate realization of a time series.using TimeseriesSurrogates\n\n# Generate a time series. Again, we\'ll use a NSAR2() process.\nts = NSAR2()\n\n# Generate a random amplitude surrogate realization\nsurrogate = randomamplitudes(ts)\n\n# Plot the surrogate along with the time series it is based on, along with autocorrelation\n# and periodogram plots.\nsurrplot(ts, surrogate)"
},

{
    "location": "constrained/fourier_surrogates.html#How-do-random-amplitude-surrogates-vary-across-realizations?-1",
    "page": "Fourier transform (FT)",
    "title": "How do random amplitude surrogates vary across realizations?",
    "category": "section",
    "text": "Below is a plot showing different phase surrogate realizations (orange) over the same time series (blue).randomamplitudes_NSAR2_gif(n_iters = 30, fps = 5)(Image: 30 random phase surrogates for a single realization of a cyclostationary AR(2) process)In the next animation, as above, each frame shows a new time series (blue), which every frame is another unique realization of the NSAR2 process, and one surrogate realization of the time series (orange).randomamplitudes_NSAR2_gif(n_iters = 30, fps = 5,\n                        new_realization_every_iter = true)(Image: 30 realizations of a cyclostationary AR(2) process. One random phase surrogate per realization of the time series.)"
},

{
    "location": "constrained/amplitude_adjusted.html#",
    "page": "Amplitude adjusted Fourier (AAFT)",
    "title": "Amplitude adjusted Fourier (AAFT)",
    "category": "page",
    "text": ""
},

{
    "location": "constrained/amplitude_adjusted.html#Amplitude-adjusted-Fourier-transform-surrogates-1",
    "page": "Amplitude adjusted Fourier (AAFT)",
    "title": "Amplitude adjusted Fourier transform surrogates",
    "category": "section",
    "text": "Different variants of the AAFT and iterated AAFT algorithms."
},

{
    "location": "constrained/amplitude_adjusted.html#TimeseriesSurrogates.aaft",
    "page": "Amplitude adjusted Fourier (AAFT)",
    "title": "TimeseriesSurrogates.aaft",
    "category": "function",
    "text": "aaft(ts)\n\nGenerate a realization of an amplitude adjusted Fourier transform (AAFT) surrogate [1].\n\nts Is the time series for which to generate an AAFT surrogate realization.\n\nLiterature references\n\nJ. Theiler et al., Physica D 58 (1992) 77-94 (1992).\n\n\n\n"
},

{
    "location": "constrained/amplitude_adjusted.html#Amplitude-adjusted-Fourier-transform-(AAFT)-1",
    "page": "Amplitude adjusted Fourier (AAFT)",
    "title": "Amplitude adjusted Fourier transform (AAFT)",
    "category": "section",
    "text": "TimeseriesSurrogates.aaft"
},

{
    "location": "constrained/amplitude_adjusted.html#Example-of-AAFT-1",
    "page": "Amplitude adjusted Fourier (AAFT)",
    "title": "Example of AAFT",
    "category": "section",
    "text": "using TimeseriesSurrogates\nts = AR1() # create a realization of a random AR(1) process\nsurrogate = aaft(ts)\n\nsurrplot(ts, surrogate)"
},

{
    "location": "constrained/amplitude_adjusted.html#TimeseriesSurrogates.iaaft",
    "page": "Amplitude adjusted Fourier (AAFT)",
    "title": "TimeseriesSurrogates.iaaft",
    "category": "function",
    "text": "iaaft(ts; [n_maxiter = 200, tol = 1e-6, n_window = 50 ])\n\nGenerate an iteratively adjusted amplitude adjusted Fourier transform (IAAFT) [1] surrogate realization of ts.\n\nKeywords\n\nts is the time series for which to generate an AAFT surrogate realization.\n\nn_maxiter sets the maximum number of iterations to allow before ending the algorithm (if convergence is slow).\n\ntol is the relative tolerance for deciding if convergence is achieved.\n\nn_window is the number is windows used when binning the periodogram (used for determining convergence).\n\nLiterature references\n\nT. Schreiber; A. Schmitz (1996). \"Improved Surrogate Data for Nonlinearity Tests\". Phys. Rev. Lett. 77 (4): 635–638. doi:10.1103/PhysRevLett.77.635. PMID 10062864.\n\n\n\n"
},

{
    "location": "constrained/amplitude_adjusted.html#Iterated-AAFT-(AAFT)-1",
    "page": "Amplitude adjusted Fourier (AAFT)",
    "title": "Iterated AAFT (AAFT)",
    "category": "section",
    "text": "TimeseriesSurrogates.iaaftThe IAAFT surrogates add an iterative step to the AAFT algorithm improve convergence."
},

{
    "location": "constrained/amplitude_adjusted.html#Example-of-IAAFT-1",
    "page": "Amplitude adjusted Fourier (AAFT)",
    "title": "Example of IAAFT",
    "category": "section",
    "text": "using TimeseriesSurrogates\nts = AR1() # create a realization of a random AR(1) process\nsurrogate = iaaft(ts)\n\nsurrplot(ts, surrogate)"
},

{
    "location": "plots/visualize_surrogate.html#",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "Visualising surrogate realizations and creating gifs",
    "category": "page",
    "text": ""
},

{
    "location": "plots/visualize_surrogate.html#Visualizing-surrogates-1",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "Visualizing surrogates",
    "category": "section",
    "text": ""
},

{
    "location": "plots/visualize_surrogate.html#Autocorrelation-/-periodogram-panels-1",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "Autocorrelation / periodogram panels",
    "category": "section",
    "text": "Visualizing a surrogate realization is easy.Let\'s say we want to generate an IAAFT surrogate and visualize the time series and surrogate time series, together with the corresponding periodograms,  autocorrelation functions and histograms. This can be done as follows:using TimeseriesSurrogates\nts = diff(rand(300))\niaaft_plot(ts)Here, the blue lines correspond to the original time series, while orange lines correspond to the surrogate time series. In this particular case, it seems that the IAAFT surrogate well reproduced the autocorrelation of the original time series.All surrogate functions come have a complementary functions that also plots a panel showing the autocorrelation function and periodogram of the time series and its surrogate realization:randomphases has randomphases_plot\nrandomamplitudes has randomamplitudes_plot\naaft has aaft_plot\niaaft has iaaft_plot"
},

{
    "location": "plots/visualize_surrogate.html#Animate-panels-(and-export-to-.gif)-1",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "Animate panels (and export to .gif)",
    "category": "section",
    "text": "Say you want to examine which surrogate method is suited for a particular dataset. It would then be useful to visualize multiple surrogate realizations for that time series.For this purpose, each surrogate function comes with a corresponding animation functions (randomphases_anim, randomamplitudes_anim, aaft_anim, iaaft_anim) and gif creation functions (randomphases_gif, randomamplitudes_gif, aaft_gif, iaaft_gif).You can either generate the gif file directly, or create a Plots.animation instance containing the animation.Here\'s some examples:using TimeseriesSurrogates\nts = diff(rand(300))\n\n# Creating a gif directly\n\n# Create a gif using the default number (15) surrogates\niaaft_gif(ts)\niaaft_gif(ts, fps = 3) # specify frame rate\n\n# Specify that we want 100 different surrogate realizations\niaaft_gif(ts, n_iters = 100)\niaaft_gif(ts, n_iters = 100, fps = 1) # specify frame rateIf you for some reason don\'t want a gif directly, then you could do# Use the `gif` function from `Plots.jl` to create a gif\nanim = iaaft_anim(ts, n_iters = 50) # create an animation\ngif(anim)\ngif(anim, fps = 3) # specifying frame rate"
},

{
    "location": "plots/visualize_surrogate.html#Examples-1",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "Examples",
    "category": "section",
    "text": ""
},

{
    "location": "plots/visualize_surrogate.html#IAAFT-realizations-of-an-AR1-process-1",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "IAAFT realizations of an AR1 process",
    "category": "section",
    "text": "iaaft_AR1_gif(n_iters = 20, fps = 2)(Image: 20 IAAFT surrogate realizations for an AR(1) process.)"
},

{
    "location": "plots/visualize_surrogate.html#IAAFT-realizations-of-a-NSAR2-process-1",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "IAAFT realizations of a NSAR2 process",
    "category": "section",
    "text": "iaaft_NSAR2_gif(n_iters = 100, fps = 10)(Image: 100 IAAFT surrogate realizations for a cyclostationary AR(2) process.)"
},

{
    "location": "plots/visualize_surrogate.html#Random-phase-realizations-of-a-random-walk-1",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "Random phase realizations of a random walk",
    "category": "section",
    "text": "randomphases_randomwalk_gif(n_iters = 10, fps = 1, new_realization_every_iter = true)(Image: 10 random phase surrogate realizations for a random walk.)"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.randomshuffle_plot",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.randomshuffle_plot",
    "category": "function",
    "text": "    `TimeseriesSurrogates.randomshuffle_plot(ts)`\n\nVisualize a `TimeseriesSurrogates.randomshuffle` surrogate.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.randomamplitudes_plot",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.randomamplitudes_plot",
    "category": "function",
    "text": "    `TimeseriesSurrogates.randomamplitudes_plot(ts)`\n\nVisualize a `TimeseriesSurrogates.randomamplitudes` surrogate.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.randomphases_plot",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.randomphases_plot",
    "category": "function",
    "text": "    `TimeseriesSurrogates.randomphases_plot(ts)`\n\nVisualize a `TimeseriesSurrogates.randomphases` surrogate.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.aaft_plot",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.aaft_plot",
    "category": "function",
    "text": "    `TimeseriesSurrogates.aaft_plot(ts)`\n\nVisualize a `TimeseriesSurrogates.aaft` surrogate.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.iaaft_plot",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.iaaft_plot",
    "category": "function",
    "text": "    `TimeseriesSurrogates.iaaft_plot(ts)`\n\nVisualize a `TimeseriesSurrogates.iaaft` surrogate.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.randomshuffle_anim",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.randomshuffle_anim",
    "category": "function",
    "text": "    `TimeseriesSurrogates.randomshuffle_anim(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.randomshuffle` surrogates for `ts` and animate them. Returns a `Plots.Animation` instance.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.randomamplitudes_anim",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.randomamplitudes_anim",
    "category": "function",
    "text": "    `TimeseriesSurrogates.randomamplitudes_anim(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.randomamplitudes` surrogates for `ts` and animate them. Returns a `Plots.Animation` instance.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.randomphases_anim",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.randomphases_anim",
    "category": "function",
    "text": "    `TimeseriesSurrogates.randomphases_anim(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.randomphases` surrogates for `ts` and animate them. Returns a `Plots.Animation` instance.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.aaft_anim",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.aaft_anim",
    "category": "function",
    "text": "    `TimeseriesSurrogates.aaft_anim(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.aaft` surrogates for `ts` and animate them. Returns a `Plots.Animation` instance.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.iaaft_anim",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.iaaft_anim",
    "category": "function",
    "text": "    `TimeseriesSurrogates.iaaft_anim(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.iaaft` surrogates for `ts` and animate them. Returns a `Plots.Animation` instance.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.randomshuffle_gif",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.randomshuffle_gif",
    "category": "function",
    "text": "    `TimeseriesSurrogates.randomshuffle_gif(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.randomshuffle` surrogates for `ts`, animate them and create\na gif from the animation.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.randomamplitudes_gif",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.randomamplitudes_gif",
    "category": "function",
    "text": "    `TimeseriesSurrogates.randomamplitudes_gif(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.randomamplitudes` surrogates for `ts`, animate them and create\na gif from the animation.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.randomphases_gif",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.randomphases_gif",
    "category": "function",
    "text": "    `TimeseriesSurrogates.randomphases_gif(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.randomphases` surrogates for `ts`, animate them and create\na gif from the animation.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.aaft_gif",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.aaft_gif",
    "category": "function",
    "text": "    `TimeseriesSurrogates.aaft_gif(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.aaft` surrogates for `ts`, animate them and create\na gif from the animation.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#TimeseriesSurrogates.iaaft_gif",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "TimeseriesSurrogates.iaaft_gif",
    "category": "function",
    "text": "    `TimeseriesSurrogates.iaaft_gif(ts; [n_iters::Int])`\n\nCreate `n_iters` `TimeseriesSurrogates.iaaft` surrogates for `ts`, animate them and create\na gif from the animation.\n\n\n\n"
},

{
    "location": "plots/visualize_surrogate.html#Plot/animation/gif-docs-1",
    "page": "Visualising surrogate realizations and creating gifs",
    "title": "Plot/animation/gif docs",
    "category": "section",
    "text": "You can use any of the following functions to generate plots, animations and the animations as gif files.TimeseriesSurrogates.randomshuffle_plot\nTimeseriesSurrogates.randomamplitudes_plot\nTimeseriesSurrogates.randomphases_plot\nTimeseriesSurrogates.aaft_plot\nTimeseriesSurrogates.iaaft_plot\n\nTimeseriesSurrogates.randomshuffle_anim\nTimeseriesSurrogates.randomamplitudes_anim\nTimeseriesSurrogates.randomphases_anim\nTimeseriesSurrogates.aaft_anim\nTimeseriesSurrogates.iaaft_anim\n\nTimeseriesSurrogates.randomshuffle_gif\nTimeseriesSurrogates.randomamplitudes_gif\nTimeseriesSurrogates.randomphases_gif\nTimeseriesSurrogates.aaft_gif\nTimeseriesSurrogates.iaaft_gif"
},

{
    "location": "man/exampleprocesses.html#",
    "page": "Example systems",
    "title": "Example systems",
    "category": "page",
    "text": ""
},

{
    "location": "man/exampleprocesses.html#TimeseriesSurrogates.NLNS",
    "page": "Example systems",
    "title": "TimeseriesSurrogates.NLNS",
    "category": "function",
    "text": "NLNS(n_steps, x₀)\n\nA nonlinear, nonstationary process given by the following stochastic model [1]:\n\nx_t = x_t-1 + a_t a_t-1\n\nwith a_t  N(01) being stationary. The nonlinearity lies in the a_t a_t-1 term. This is, in essence, a nonlinear random walk. x₀ sets the initial condition.\n\nLiterature references\n\nLucio et al., Phys. Rev. E 85, 056202 (2012).\n\n\n\n"
},

{
    "location": "man/exampleprocesses.html#TimeseriesSurrogates.SNLST",
    "page": "Example systems",
    "title": "TimeseriesSurrogates.SNLST",
    "category": "function",
    "text": "SNLST(n_steps, x₀, k)\n\nDynamically linear process transformed by a strongly nonlinear static transformation (SNLST), given by the following map [1]:\n\nx(t) = k*x(t-1) + a(t)\n\nwith the transformation s(t) = x(t)^3.\n\nLiterature references\n\nLucio et al., Phys. Rev. E 85, 056202 (2012).\n\n\n\n"
},

{
    "location": "man/exampleprocesses.html#TimeseriesSurrogates.randomwalk",
    "page": "Example systems",
    "title": "TimeseriesSurrogates.randomwalk",
    "category": "function",
    "text": "randomwalk(n_steps, x₀)\n\nLinear random walk (AR(1) process with a unit root) [1]\n\nThis is an example of a nonstationary linear process.\n\nLiterature references\n\nLucio et al., Phys. Rev. E 85, 056202 (2012).\n\n\n\n"
},

{
    "location": "man/exampleprocesses.html#TimeseriesSurrogates.NSAR2",
    "page": "Example systems",
    "title": "TimeseriesSurrogates.NSAR2",
    "category": "function",
    "text": "NSAR2(n_steps, x₀, x₁)\n\nCyclostationary AR(2) process given by the following map [2]\n\nx_t = a(t) * x_t-1 + a x_t-2 + _t.\n\nwhere\n\na(t) = 2 cos2pi  T(t) * exp(-1  ),\n\nT(t)  = T_0 + M * sin(2 pi t  T_mod),\n\na    = exp(-2  	au),\n\nand x₀ and x₁ sets the initial conditions.\n\nLiterature references\n\nLucio et al., Phys. Rev. E 85, 056202 (2012), after J. Timmer, Phys. Rev. E 58, 5153\n\n(1998).\n\n\n\n"
},

{
    "location": "man/exampleprocesses.html#TimeseriesSurrogates.AR1",
    "page": "Example systems",
    "title": "TimeseriesSurrogates.AR1",
    "category": "function",
    "text": "AR1(n_steps, x₀, k)\n\nSimple AR(1) model with no static transformation given by the following map [1]:\n\nxi = k*xi-1 + ai,\n\nwhere a[i] is a draw from a normal distribution with zero mean and unit variance. x₀ sets the initial condition and k is the tunable parameter in the map.\n\nLiterature references\n\nLucio et al., Phys. Rev. E 85, 056202 (2012).\n\n\n\n"
},

{
    "location": "man/exampleprocesses.html#Example-processes-1",
    "page": "Example systems",
    "title": "Example processes",
    "category": "section",
    "text": "NLNS\nSNLST\nrandomwalk\nNSAR2\nAR1"
},

]}
