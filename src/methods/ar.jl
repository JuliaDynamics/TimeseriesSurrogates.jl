using DSP, Random
export AutoRegressive

"""
    AutoRegressive(n, method = LPCLevinson())

Autoregressive surrogates of order-`n`. The autoregressive coefficients `φ` are estimated
using `DSP.lpc(x, n, method)`, and thus see the documentation of DSP.jl for possible
`method`s.

While these surrogates are obviously suited to test the null hypothesis whether the data
are coming from a autoregressive process, the Fourier Transform-based surrogates are
probably a better option. The current method is more like a convient way to estimate
autoregressive coefficients and automatically generate surrogates based on them.
"""
struct AutoRegressive{M} <: Surrogate
    n::Int
    m::M
end
AutoRegressive(n::Int) = AutoRegressive(n, LPCLevinson())

function surrogenerator(x, method::AutoRegressive)
    φ, e = lpc(x, method.n, method.m)
    init = (d = Normal(0, std(x)), φ = φ)
    return SurrogateGenerator(method, x, init)
end

function (sg::SurrogateGenerator{<:AutoRegressive})()
    n, φ, d = length(sg.x), sg.init.φ, sg.init.d
    return autoregressive(d, n, φ)
end

function autoregressive(d::Normal{T}, n, φ) where {T}
    f = length(φ)
    z = zeros(T, n+length(φ))
    @inbounds for i in 1:length(φ); z[i] = rand(d); end
    @inbounds for i in f+1:length(z)
        s = zero(T)
        for j in 1:f
            s += φ[j]*z[i-j]
        end
        s += rand(d)
        z[i] = s
    end
    return view(z, length(φ)+1:n)
end
