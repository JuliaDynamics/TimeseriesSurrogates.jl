export surrogate, surrogenerator, Surrogate

"""Supertype of all surrogate methods."""
abstract type Surrogate end

struct SurrogateGenerator{S<:Surrogate, X, A}
    method::S # method with its input parameters
    x::X      # input timeseries
    init::A   # pre-initialized things that speed up process
end

"""
    surrogenerator(x, method::Surrogate) → sg::SurrogateGenerator
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
