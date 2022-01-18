*Changelog is kept with respect to version 1.0. This software follows SymVer2.0*
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
