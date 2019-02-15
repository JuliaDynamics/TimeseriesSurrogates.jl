import UncertainData: UncertainDataset, UncertainIndexDataset, UncertainValueDataset, resample

randomshuffle(x::UncertainDataset) = randomshuffle(resample(x))
randomphases(x::UncertainDataset) = randomphases(resample(x))
randomamplitudes(x::UncertainDataset) = randomamplitudes(resample(x))
aaft(x::UncertainDataset) = aaft(resample(x))
iaaft(x::UncertainDataset, args...; kwargs...) = iaaft(resample(x), args...; kwargs...)

randomshuffle(x::UncertainValueDataset) = randomshuffle(resample(x))
randomphases(x::UncertainValueDataset) = randomphases(resample(x))
randomamplitudes(x::UncertainValueDataset) = randomamplitudes(resample(x))
aaft(x::UncertainValueDataset) = aaft(resample(x))
iaaft(x::UncertainValueDataset, args...; kwargs...) = iaaft(resample(x), args...; kwargs...)

randomshuffle(x::UncertainIndexDataset) = randomshuffle(resample(x))
randomphases(x::UncertainIndexDataset) = randomphases(resample(x))
randomamplitudes(x::UncertainIndexDataset) = randomamplitudes(resample(x))
aaft(x::UncertainIndexDataset) = aaft(resample(x))
iaaft(x::UncertainIndexDataset, args...; kwargs...) = iaaft(resample(x), args...; kwargs...)