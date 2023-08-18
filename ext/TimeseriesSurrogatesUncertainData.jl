module TimeseriesSurrogatesUncertainData

using TimeseriesSurrogates
import UncertainData: UncertainDataset, UncertainIndexDataset, UncertainValueDataset, resample

TimeseriesSurrogates.surrogate(x::UncertainDataset, method::Surrogate) = surrogate(resample(x), method)
TimeseriesSurrogates.surrogate(x::UncertainValueDataset, method::Surrogate) = surrogate(resample(x), method)
TimeseriesSurrogates.surrogate(x::UncertainIndexDataset, method::Surrogate) = surrogate(resample(x), method)

end