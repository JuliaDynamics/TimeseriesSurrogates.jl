# API:
export surrogate, surrogenerator
struct SurrogateGenerator{S<:Surrogate, X, A}
    method::S # method with its input parameters
    x::X      # input timeseries
    init::A   # pre-initialized things that speed up process
end

"""
    surrogenerator(x, method::Surrogate, n::Int) → sg::SurrogateGenerator
Initialize a generator that creates surrogates of `x` on demand, based on given `method`.
This is efficient, because for most methods some things can be initialized and reused
for every surrogate.

To generate a surrogate, call `sg` as a function with no arguments, e.g.:
```julia
sg = surrogenerator(x, method)
for i in 1:1000
    s = sg()
    # do stuff with s and or x
    result[i] = stuff
end
```
"""
function surrogenerator end

function Base.show(io::IO, sg::SurrogateGenerator)
    println(io, "Surrogate generator for input timeseries $(summary(sg.x)) with method:")
    show(io, sg.method)
end

"""
    surrogate(x, method::Surrogate) → s
Create a single surrogate timeseries `s` from `x` based on the given `method`.
If you want to generate more than one surrogates, you should use [`surrogenerator`](@ref).
"""
function surrogate(x, method::Surrogate)
    sg = surrogenerator(x, method)
    sg()
end


export PseudoPeriodic
"""
    PseudoPeriodic(d, τ, ρ, shift=true) <: Surrogate
Create surrogates suitable for pseudo-periodic signals. They retain the periodic structure
of the signal, while inter-cycle dynamics that are either deterministic or correlated
noise are destroyed (for appropriate `ρ` choice).
Therefore these surrogates are suitable to test the null hypothesis
that the signal is periodic with uncorrelated noise[^Small2001].

Argumensts `d, τ, ρ` are as in the paper, the embedding dimension, delay time and
noise radius. The method works by performing a delay coordinates ambedding via the
library [DynamicalSystems.jl](https://juliadynamics.github.io/DynamicalSystems.jl/dev/embedding/reconstruction/).
See its documentation for choosing appropriate values for `d, τ`. For `ρ`, we have implemented
the method proposed in the paper in the function [`noiseradius`](@ref).

The argument `shift` is not discussed in the paper, but it is possible to adjust the algorithm
so that there is no phase shift between the periodic component of the original and
surrogate data.

[^Small2001]: Small et al., Surrogate test for pseudoperiodic time series data, [Physical Review Letters, 87(18)](https://doi.org/10.1103/PhysRevLett.87.188101)
"""
struct PseudoPeriodic{T<:Real} <: Surrogate
    d::Int
    τ::Int
    ρ::T
    shift::Bool
end

function surrogenerator(x::AbstractVector, pp::PseudoPeriodic)
    # in the following symbol `y` stands for `s` of the paper
    d, τ = getfield.(Ref(pp), (:d, :τ))
    N = length(x)
    z = embed(x, d, τ)
    Ñ = length(z)
    w = zeros(eltype(z), Ñ-1) # weights vector
    y = Dataset([z[1] for i in 1:N])
    init = (y = y, w = w, z = z)
    return SurrogateGenerator(pp, x, init)
end

function (sg::SurrogateGenerator{<:PseudoPeriodic})()
    y, z, w = getfield.(Ref(sg.init), (:y, :z, :w))
    ρ, shift = getfield.(Ref(sg.method), (:ρ, :shift))
    pseudoperiodic!(y, z, w, ρ, shift)
end
# Low-level method, also used in `noiseradius`
function pseudoperiodic!(y, z, w, ρ, shift)
    N, Ñ = length.((x, z))
    y[1] = shift ? rand(z.data) : z[1]
    @inbounds for i in 1:N-1
        w .= (exp(-norm(z[t] - y[i])/ρ) for t in 1:Ñ-1)
        j = sample(1:Ñ-1, pweights(w))
        y[i+1] = z[j+1]
    end
    return y[:, 1]
end

noiseradius(d::Int, τ, ρs, n = 1) =
noiseradius(surrogenerator(PseudoPeriodic(d, τ, ρs[1])), ρs, n)
function noiseradius(sg::SurrogateGenerator{<:PseudoPeriodic}, ρs, n = 1)
    l2n = zero(ρs) # length-2 number of points existing in both timeseries
    y, z, w = getfield.(Ref(sg.init), (:y, :z, :w))
    @inbounds for _ in 1:n
        for (ℓ, ρ) in enumerate(ρs)
            s = pseudoperiodic!(y, z, w, ρ, shift)
            for i in 1:N-1
                # TODO: This can be optimized heavily: checking x[i+2] already tells us
                # that we shouldn't check x[i+1] on the next iteration.
                l2n[ℓ] += count(j -> s[j]==x[i] && s[j+1]==x[i+1] && s[j+2]!=x[i+2], 1:N-2)
            end
        end
    end
    return l2n
end