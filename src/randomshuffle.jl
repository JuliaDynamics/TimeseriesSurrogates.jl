"""
    randomshuffle(ts)

Generate a random constrained surrogate for `ts`.
"""
function randomshuffle(ts)
    n = length(ts)
    ts[sample(1:n, n, replace = false)]
end
