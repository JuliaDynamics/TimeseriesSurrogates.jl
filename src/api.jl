export surrogate, surrogenerator, Surrogate

"""Supertype of all surrogate methods."""
abstract type Surrogate end

struct SurrogateGenerator{S<:Surrogate, Xₓ, Xₛ, A, R<:AbstractRNG}
    method::S # method with its input parameters
    x::Xₓ      # input timeseries
    s::Xₛ      # surrogate (usually same type as `x`, but not always)
    init::A   # pre-initialized things that speed up process
    rng::R    # random number generator object
end

"""
    surrogenerator(x, method::Surrogate [, rng]) → sg::SurrogateGenerator

Initialize a generator that creates surrogates of `x` on demand, based on given `method`.
This is efficient, because for most methods some things can be initialized and reused
for every surrogate. Optionally you can provide an `rng::AbstractRNG` object that will
control the random number generation and hence establish reproducibility of the
generated surrogates. By default `Random.default_rng()` is used.

Notice that the generated surrogates are overwriting an in-place a common
vector container. Use copy if you need to actually store multiple surrogates.

To generate a surrogate, call `sg` as a function with no arguments, e.g.:

```julia
sg = surrogenerator(x, method)
for i in 1:1000
    sg()
    # do stuff with s and or x
    result[i] = stuff(sg.s)
end
```
"""
function surrogenerator end

function Base.show(io::IO, sg::SurrogateGenerator)
    println(io, "Surrogate generator for input timeseries $(summary(sg.x)) with method:")
    show(io, sg.method)
end

"""
    surrogate(x, method::Surrogate [, rng]) → s
Create a single surrogate timeseries `s` from `x` based on the given `method`.
If you want to generate more than one surrogates from `x`, you should use [`surrogenerator`](@ref).
"""
function surrogate(x, method::Surrogate, rng = Random.default_rng())
    sg = surrogenerator(x, method, rng)
    sg()
end
