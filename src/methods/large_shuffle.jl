#########################################################################
# BlockSuffle
#########################################################################

export BlockShuffle
"""
    BlockShuffle(n::Int) <: Surrogate

A block shuffle surrogate constructed by dividing the time series
into `n` blocks of roughly equal width at random indices (end
blocks are wrapped around to the start of the time series).

Block shuffle surrogates roughly preserve short-range temporal properties
in the time series (e.g. correlations at lags less than the block length),
but break any long-term dynamical information (e.g. correlations beyond
the block length).

Hence, these surrogates can be used to test any null hypothesis aimed at
comparing short-range dynamical properties versus long-range dynamical
properties of the signal.
"""
struct BlockShuffle <: Surrogate
    n::Int
end

Base.show(io::IO, bs::BlockShuffle) = show(io, "BlockShuffle(n=$(bs.n))")

# Split time series in two by default.
BlockShuffle() = BlockShuffle(2)

function get_uniform_blocklengths(L::Int, n::Int)
     # Compute block lengths
    N = floor(Int, L/n)
    R = L % n
    blocklengths = [N for i = 1:n]
    for i = 1:R
        blocklengths[i] += 1
    end

    return blocklengths
end

function surrogenerator(x::AbstractVector, bs::BlockShuffle)
    L = length(x)
    bs.n < L || error("The number of blocks exceeds number of available points")
    Ls = get_uniform_blocklengths(L, bs.n)
    cs = cumsum(Ls)
    # will hold a rotation version of x
    xrot = similar(x)
    T = eltype(xrot)
    init = NamedTuple{(:L, :Ls, :cs, :xrot),Tuple{Int, Vector{Int}, Vector{Int}, Vector{T}}}((L, Ls, cs, xrot))
    return SurrogateGenerator(bs, x, init)
end

function (bs::SurrogateGenerator{<:BlockShuffle})()
    # TODO: A circular custom array implementation would be much more elegant here
    L = bs.init.L
    Ls = bs.init.Ls
    cs = bs.init.cs
    xrot = bs.init.xrot
    n = bs.method.n
    x = bs.x

    # Just create a temporarily randomly shifted array, so we don't need to mess
    # with indexing twice.
    circshift!(xrot, x, rand(1:L))

    # Block always must be shuffled (so ordered samples are not permitted)
    draw_order = zeros(Int, n)
    while any(draw_order .== 0) || all(draw_order .== 1:n)
       StatsBase.sample!(1:n, draw_order, replace = false)
    end

    # The surrogate.
    # TODO: It would be faster to re-allocate, but blocks may
    # be of different sizes and are shifted, so indexing gets messy.
    # Just append for now.
    T = eltype(x)
    s = Vector{T}(undef, 0)
    sizehint!(s, L)

    startinds = [1; cs .+ 1]
    @inbounds for i in draw_order
        inds = startinds[i]:startinds[i]+Ls[i]-1
        append!(s, xrot[inds])
    end

    return s
end

#########################################################################
# CycleShuffle
#########################################################################

#########################################################################
# Timeshift
#########################################################################
"""
    CircShift(n) <: Surrogate
Surrogates that are circularly shifted versions of the original timeseries.

`n` can be an integer (meaning to shift for `n` indices), or any vector of integers,
which means that each surrogate is shifted by a random entry of `n`.
"""
struct CircShift{N} <: Surrogate
    n::N
end

function surrogenerator(x, sd::CircShift)
    return SurrogateGenerator(sd, x, nothing)
end

function (sg::SurrogateGenerator{<:CircShift})()
    s = random_shift(sg.method.n)
    return circshift(sg.x, s)
end

random_shift(n::Integer) = n
random_shift(n::AbstractVector{<:Integer}) = rand(n)