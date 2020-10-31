using DSP, Random

lpcmethod = LPCLevinson()

struct AutoRegressive{M} <: Surrogate
    n::Int
    m::M
end
AutoRegressive(n::Int, m::M = LPCLevinson()) where {M} = AutoRegressive{M}(n, m)

function surrogenerator(x, method::AutoRegressive)
    φ, e = lpc(D, 12, lpcmethod)
    init = (σ = std(x), φ = φ)
    return SurrogateGenerator(method, x, init)
end

function (sg::SurrogateGenerator{<:AutoRegressive})()
    # code
end
