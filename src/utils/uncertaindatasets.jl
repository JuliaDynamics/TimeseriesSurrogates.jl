import UncertainData: UncertainDataset, UncertainIndexDataset, UncertainValueDataset, resample

surrogate(x::UncertainDataset, method::Surrogate) = surrogate(resample(x), method)
surrogate(x::UncertainValueDataset, method::Surrogate) = surrogate(resample(x), method)
surrogate(x::UncertainIndexDataset, method::Surrogate) = surrogate(resample(x), method)