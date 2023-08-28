*Changelog is kept with respect to version 1.0. This software follows SymVer2.0*

# 2.6.0

- Added surrogate methods: `RelativePartialRandomization`, `SpectralPartialRandomization`, `RelativePartialRandomizationAAFT`, and `SpectralPartialRandomizationAAFT`.
- New function for plotting a comparison between surrogate methods: `surrocompare`. 

# 2.5.0

- Moved to Julia extensions (requiring julia v1.9).

# 2.4
- Calling `pvalue` with `SurrogateTest` is now parallelized over available threads.

# 2.3
- `pvalue` is now correctly overloaded from StatsAPI.jl.

# 2.2
- Implemented API for automating surrogate hypothesis tests using the new exported names `SurrogateTest` and `pvalue`.
- New documentation section with an educative example of surrogate testing.

# 2.1
- Added more padding modes to `RandomCascade`

# 2.0

## API changes
- `SurrogateGenerator`s now have a field `s` into which surrogates are generated, avoiding
    unnecessary memory allocations. The
- The wavelet (`WLS`) surrogate constructor now uses keywords arguments instead of
    positional arguments for some parameters.


## New features
- New surrogate methods: `PartialRandomization`, `PartialRandomizationAAFT`, `TFTDAAFT`,
    `TFTDIAAFT`, and `RandomCascade`.
- Using the `f` keyword, it is now possible to select whether circular shifting at
    each wavelet coefficient level should be performed for `WLS` surrogates.

# 1.3

## New features
- The API now allows random number generator to be specified for all methods, enabling reproducibility
- New surrogate methods: `PseudoPeriodicTwin`, `IrregularLombScargle` and `TFTDRandomFourier`.

## Bug fixes
- Fixed error in `RandomFourier(true)` and `AAFT` surrogates, where phases were not correctly computed, leading to surrogates whose power spectra didn't match the power spectrum of the original signal as well as they should. No other Fourier-based surrogate were affected by this bug.

# 1.2
- New surrogate methods: `AutoRegressive`
# 1.1
- New surrogate methods: `CycleShuffle`, `ShuffleDimensions`, `CircShift`
