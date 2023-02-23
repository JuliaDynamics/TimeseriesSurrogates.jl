export PseudoPeriodicTwin

using StatsBase: sample, pweights
using Distances: Euclidean, PreMetric, pairwise
using DelayEmbeddings: embed

"""
    PseudoPeriodicTwin(d::Int, τ::Int, δ = 0.2, ρ = 0.1, metric = Euclidean())
    PseudoPeriodicTwin(δ = 0.2, ρ = 0.1, metric = Euclidean())

A pseudoperiodic twin surrogate[^Miralles2015], which is a fusion of the
twin surrogate[^Thiel2006] and the pseudo-periodic surrogate[^Small2001].

## Input parameters

A delay reconstruction of the input timeseries is constructed using embedding
dimension `d` and embedding delay `τ`. The threshold `δ ∈ (0, 1]` determines which
points are "close" (neighbors) or not, and is expressed as a fraction of the
attractor diameter, as determined by the input data. The authors of the original
twin surrogate paper recommend `0.05 ≤ δ ≤ 0.2`[^Thiel2006].

If you have pre-embedded your timeseries, and timeseries is already a `::Dataset`, use the
three-argument constructor (so that no delay reconstruction is performed).
If you want a surrogate for a scalar-valued timeseries, use the five-argument constructor
to also provide the embedding delay `τ` and embedding dimension `d`.

## Null hypothesis

Pseudo-periodic twin surrogates generate signals similar to the original data if the
original signal is (quasi-)periodic. If the original signal is not
(quasi-)periodic, then these surrogates will have different
recurrence plots than the original signal, but preserve the overall
shape of the attractor. Thus, `PseudoPeriodicTwin` surrogates can be used to test
null hypothesis that the observed timeseries (or orbit) is consistent
with a quasi-periodic orbit[^Miralles2015].

## Returns

A `d`-dimensional surrogate orbit (a `Dataset`) is returned. Sample the first
column of this dataset if a scalar-valued surrogate is desired.

[^Small2001]: Small et al., Surrogate test for pseudoperiodic timeseries data, [Physical Review Letters, 87(18)](https://doi.org/10.1103/PhysRevLett.87.188101)
[^Thiel2006]: Thiel, Marco, et al. "Twin surrogates to test for complex synchronisation." EPL (Europhysics Letters) 75.4 (2006): 535.
[^Miralles2015]: Miralles, R., et al. "Characterization of the complexity in short oscillating timeseries: An application to seismic airgun detonations." The Journal of the Acoustical Society of America 138.3 (2015): 1595-1603.
"""
struct PseudoPeriodicTwin{T<:Real, P<:Real, D<:PreMetric} <: Surrogate
    d::Union{Nothing, Int}
    τ::Union{Nothing, Int}
    δ::T
    ρ::P
    metric::D

    function PseudoPeriodicTwin(d::Int, τ::Int, δ::T = 0.2, ρ::P = 0.1, metric::D = Euclidean()) where {T, P, D}
        new{T, P, D}(d, τ, δ, ρ, metric)
    end

    function PseudoPeriodicTwin(δ::T = 0.2, ρ::P = 0.1, metric::D = Euclidean()) where {T, P, D}
        new{T, P, D}(nothing, nothing, δ, ρ, metric)
    end
end

"""
    _prepare_embed(x::AbstractVector, d, τ) → Dataset
    _prepare_embed(x::Dataset, d, τ) → Dataset

Prepate input data for surrogate generation. If input is a vector, embed it using
the provided parameters. If input as a dataset, we assume it already represents an
orbit.
"""
function _prepare_embed end
_prepare_embed(x::AbstractVector, d, τ) = embed(x, d, τ)
_prepare_embed(x::Dataset, d, τ) = x


function surrogenerator(x::Union{AbstractVector, Dataset}, pp::PseudoPeriodicTwin, rng = Random.default_rng())
    d, τ, δ, metric = getfield.(Ref(pp), (:d, :τ, :δ, :metric))
    ρ = getfield.(Ref(pp), (:ρ))

    pts = _prepare_embed(x, d, τ)

    Nx = length(x)
    Npts = length(pts)

    dists = pairwise(metric, Matrix(pts), dims = 1)
    normalisedδ = δ*maximum(dists)

    T = eltype(pts)
    R = zeros(T, Npts, Npts)

    # Recurrence matrix
    for j = 1:Npts
        for i = 1:Npts
            R[i, j] = normalisedδ - dists[i, j] >= 0 ? 1.0 : 0.0
        end
    end

    # Identify twins
    #println("R contains $(count(R .== 1)/length(R)*100)% black dots")
    twins_i = Vector{Int}(undef, 0)
    twins_j = Vector{Int}(undef, 0)
    for j = 1:Npts
        for i = 1:Npts
            if i !== j && all(R[:, i] .≈ R[:, j])
                push!(twins_i, i)
                push!(twins_j, j)
            end
        end
    end
    #println("Found $(length(twins)) twins")

    twins = Dict{Int,Vector{Int}}()

    # For every point that has a twin, store the indices of all of its twins
    for twi in unique(twins_i)
        twins[twi] = twins_j[findall(twins_i .== twi)]
    end
    for twj in unique(twins_j)
        twins[twj] = twins_i[findall(twins_j .== twj)]
    end

    # Sampling weights (exclude the point itself)
    W = [pweights(exp.(-dists[setdiff(1:Npts, i), i] / ρ)) for i = 1:Npts]

    # The surrogate will be a vector of vectors (if pts is a Dataset, then
    # the eltype is SVector).
    PT = eltype(pts.data)
    s = Vector{PT}(undef, Nx)

    init = (pts = pts, Nx = Nx, Npts = Npts, dists = dists, R = R, twins = twins, W = W)
    return SurrogateGenerator(pp, x, s, init, rng)
end


function (sg::SurrogateGenerator{<:PseudoPeriodicTwin})()
    pts, Nx, Npts, twins, W = getfield.(Ref(sg.init), (:pts, :Nx, :Npts, :twins, :W))
    ρ = getfield.(Ref(sg.method), (:ρ))
    s = sg.s

    # Randomly pick a point from the state space as the starting point for the surrogate.
    n = 1
    i = rand(sg.rng, 1:Npts)
    s[n] = pts[i]

    while n < Nx
        # Look for possible twins of the point xᵢ. If any twin exists, jump to one of them
        # with probability 1/nⱼ, where nⱼ are the number of twins for the point xᵢ.
        if haskey(twins, i)
            # sample uniformly (with probability 1/ntargettwins) over possible target twins
            j = twins[i][rand(sg.rng, 1:length(twins[i]))]
            s[n] = pts[j]
            i = j
            n += 1
        end

        # The orbit moves on from the current point xᵢ to a randomly selected point
        # on the attractor. Closer points are more likely to be selected, and points
        # further away are less likely to be selected. The sampling probability
        # of the next point xⱼ decreases exponentially with increasing distance
        # from the current point xᵢ. Probabilities for jumping from xᵢ to any other
        # point have been pre-computed, and are stored in W[i].
        j = sample(sg.rng, 1:Npts, W[i])
        s[n] = pts[j]
        i = j
        n += 1
    end

    s[Nx] = pts[sample(1:Npts, W[i])[1]]

    return Dataset(s)
end