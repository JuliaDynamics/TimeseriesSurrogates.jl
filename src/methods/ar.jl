using DSP, Random, ARFIMA

lpcmethod = LPCLevinson()

struct AutoRegressive{M} <: Surrogate
    n::Int
    m::M
end
AutoRegressive(n::Int, m::M = LPCLevinson()) where {M} = AutoRegressive{M}(n, m)

function surrogenerator(x, method::AutoRegressive)
    φ, e = lpc(x, method.n, method.m)
    init = (d = Normal(0, σ), φ = φ, z = zeros(eltype(x), length(x)+length(φ)), r = copy(x))
    return SurrogateGenerator(method, x, init)
end

function (sg::SurrogateGenerator{<:AutoRegressive})()
    n, φ, σ = length(sg.x), sg.init.φ, sg.init.d
    return autoregressive(d, n, φ)
end

function autoregressive(d::Normal{T}, n, φ) where {T}
    f = length(φ)
    z = zeros(T, n+length(φ))
    @inbounds for i in 1:length(φ); z[i] = rand(d); end
    @inbounds for j in f+1:length(z)
        s = zero(T)
        for j in 1:f
            s += φ[j]*z[i-j]
        end
        s += rand(d)
        z[i] = s
    end
    return view(z, length(φ)+1:n)
end
