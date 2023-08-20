using DSP, Random
export AutoRegressive

"""
    AutoRegressive(n, method = LPCLevinson())

Autoregressive surrogates of order-`n`. The autoregressive coefficients `φ` are estimated
using `DSP.lpc(x, n, method)`, and thus see the documentation of DSP.jl for possible
`method`s.

While these surrogates are obviously suited to test the null hypothesis whether the data
are coming from a autoregressive process, the Fourier Transform-based surrogates are
probably a better option. The current method is more like an explicit way to
produce surrogates for the same hypothesis by fitting a model.
It can be used as a convenient way to estimate
autoregressive coefficients and automatically generate surrogates based on them.

The coefficients φ of the autoregressive fit can be found by doing
```julia
sg = surrogenerator(x, AutoRegressive(n))
φ = sg.init.φ
```
"""
struct AutoRegressive{M} <: Surrogate
    n::Int
    m::M
end
AutoRegressive(n::Int) = AutoRegressive(n, LPCLevinson())

function surrogenerator(x, method::AutoRegressive, rng = Random.default_rng())
    φ, e = lpc(x, method.n, method.m)
    N, f = length(x), length(φ)
    d = Normal(0, std(x))

    init = (
        d = d, 
        φ = φ,
        N = N,
    )

    # The surrogate
    T = typeof(d).parameters[1]
    s = zeros(T, N + f)

    return SurrogateGenerator(method, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:AutoRegressive})()
    N, φ, d = sg.init.N, sg.init.φ, sg.init.d
    return autoregressive!(sg.s, d, N, φ, sg.rng)
end

function autoregressive!(s, d::Normal{T}, N, φ, rng) where {T}
    f = length(φ)
    @inbounds for i in 1:f; s[i] = rand(rng, d); end
    @inbounds for i in f+1:length(s)
        s̃ = zero(T)
        for j in 1:f
            s̃ += φ[j] * s[i - j]
        end
        s̃ += rand(rng, d)
        s[i] = s̃
    end
    return view(s, f+1:N+f)
end
