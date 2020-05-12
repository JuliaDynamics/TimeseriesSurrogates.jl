import TimeseriesSurrogates.SurrogateGenerator

"""
    BlockShuffle(n::Int) <: Surrogate

A block shuffle surrogate constructed by dividing the time series 
into `n` blocks of roughly equal width at random indices (end 
blocks are wrapped around to the start of the time series). 

These surrogates preserves short-term correlations in the 
time series, but breaks any long-term dynamical information.
"""
struct BlockShuffle <: Surrogate 
    n::Int
end

function surrogate(x, rs::BlockShuffle)
    sg = surrogenerator(x, rs)
    sg()
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
    T = eltype(x)
    xrot = zeros(T, L)
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
    s = Vector{}(undef, 0)
    sizehint!(s, L)
    
    startinds = [1; cs .+ 1]
    @inbounds for i in draw_order
        inds = startinds[i]:startinds[i]+Ls[i]-1
        append!(s, xrot[inds])
    end

    return s
end
