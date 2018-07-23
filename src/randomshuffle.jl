"""
    randomshuffle(ts)

Generate a random constrained surrogate for `ts`. Destroys any linear correlation in the
signal, but preserves its amplitude distribution.

**`ts`** Is the time series for which to generate an AAFT surrogate realization.
"""
function randomshuffle(ts)
    n = length(ts)
    ts[sample(1:n, n, replace = false)]
end
