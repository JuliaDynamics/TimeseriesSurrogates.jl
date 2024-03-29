export WLS, RandomCascade
using Wavelets, Statistics

"""
    WLS(shufflemethod::Surrogate = IAAFT();
        f::Union{Nothing, Function} = Statistics.cor,
        rescale::Bool = true,
        wt::Wavelets.WT.OrthoWaveletClass = Wavelets.WT.Daubechies{16}())

A wavelet surrogate generated by the following procedure:

1. Compute the wavelet transform of the signal. This results in a set of 
    detail coefficients over a set of dyadic scales. As in Keylock (2006), 
    we here use the maximal overlap discrete wavelet transform, or MODWT,
    so that the number of coefficients at each scale are the same.
2. Shuffle the detail coefficients at each dyadic scale using the 
    provided `shufflemethod`. See "Shuffling methods" below for alternatives.
3. Apply the inverse wavelet transform to the shuffled detail coefficients 
    to obtain a surrogate time series.

## Shuffling methods

You may choose to use any surrogate from this package to perform the 
randomization of the detail coefficients at each dyadic scale.

The following methods have been discussed in the literature (more may exist): 

- Random permutations of wavelet coefficients within each scale (Breakspear et al., 2003). To get this behaviour, use `WLS(x, RandomShuffle(), rescale = false, f = nothing)`.
- Cyclic rotation of wavelet coefficients within each scale (Breakspear et al., 2003).  To get this behaviour, use `WLS(x, Circshift(1:length(x)), rescale = false, f = nothing)`.
- Block resampling of wavelet coefficients within each scale (Breakspear et al., 2003). To get this behaviour, use `WLS(x, BlockShuffle(nblocks, randomize = true), rescale = false, f = nothing)`.
- IAAFT resampling of wavelet coefficients within each scale (Keylock, 2006). To get this behaviour, use `WLS(x, IAAFT(), rescale = true, f = Statistics.cor)`.
    This method preserves the local mean and variance structure of the signal, but 
    randomises nonlinear properties of the signal (i.e. Hurst exponents)[^Keylock2006]. 
    These surrogates can therefore be used to test for changes in nonlinear properties 
    of the original signal. In contrast to IAAFT surrogates, the IAAFT-wavelet surrogates 
    also preserves nonstationarity. Using other `shufflemethod`s does not necessarily
    preserve nonstationarity. To deal with nonstationary signals, Keylock (2006) recommends 
    using a wavelet with a high number of vanishing moments. Thus, our default is to
    use a Daubechies wavelet with 16 vanishing moments. *Note: The iterative procedure after 
    the rank ordering step (step [v] in [^Keylock2006]) is not performed in 
    this implementation.*

The default method and parameters replicate the behaviour of Keylock (2006)'s IAAFT 
wavelet surrogates.

## Error minimization 

For the [`IAAFT`](@ref) approach introduced in Keylock (2006), detail coefficients 
at each level are circularly rotated to minimize an error function. The methods 
introduced in Breakspear et al. (2003) do not apply this error minimization.

In our implementation, you can turn this option on/off using the `f` parameter of 
the `WLS` constructor. If `f = nothing` turns off error minization. If `f` is set 
to a two-argument function that computes some statistic, for example 
`f = Statistics.cor`, then detail coefficients at each scale are circularly 
rotated until that function is maximized (and hence the "error" minimized). 
If you want to *minimize* some error function, then instead provide an appropriate 
transform of your function. For example, if using the root mean squared deviation,
define `rmsd_inv(x, y) = 1 - StatsBase.rmsd(x, y)` and set `f = rmsd_inv`.

## Rescaling 

If `rescale == true`, then surrogate values are mapped onto the 
values of the original time series, as in the [`AAFT`](@ref) algorithm.
If `rescale == false`, surrogate values are not constrained to the 
original time series values. If [`AAFT`](@ref) or [`IAAFT`](@ref) shuffling 
is used, `rescale` should be set to `true`. For other methods, it does not 
necessarily need to be.

[^Breakspear2003]: Breakspear, M., Brammer, M., & Robinson, P. A. (2003). Construction of multivariate surrogate sets from nonlinear data using the wavelet transform. Physica D: Nonlinear Phenomena, 182(1-2), 1-22.
[^Keylock2006]: C.J. Keylock (2006). "Constrained surrogate time series with preservation of the mean and variance structure". Phys. Rev. E. 73: 036707. doi:10.1103/PhysRevE.73.036707.
"""
struct WLS{WT <: Wavelets.WT.OrthoWaveletClass, S <: Surrogate, E <: Union{Nothing, Function}} <: Surrogate
    shufflemethod::Surrogate # should preserve values of the original series
    rescale::Bool
    f::E
    wt::WT

    function WLS(method::S = IAAFT(); rescale::Bool = true, wt::WT = Wavelets.WT.Daubechies{16}(), f::E = Statistics.cor) where {S <: Surrogate, WT <: Wavelets.WT.OrthoWaveletClass, E <: Union{Nothing, Function}}
        new{WT, S, E}(method, rescale, f, wt)
    end
end

# Initialize without error minimization.
function get_init_noerrorminimize(x, method, rng = Random.default_rng())
    wl = wavelet(method.wt)
    L = length(x)
    x_sorted = sort(x)

    # Wavelet coefficients (step [i] in Keylock)
    W = modwt(x, wl)
    T = eltype(W)
    R = zeros(size(W))

    Nscales = ndyadicscales(L)

    # Will contain surrogate realizations of the wavelet coefficients 
    # at each scale (step [ii] in Keylock). 
    sW = zeros(T, size(W))

    # Surrogate generators for each set of coefficients
    sgs = [surrogenerator(W[:, i], method.shufflemethod, rng) for i = 1:Nscales]

    init = (
        wl = wl, 
        W = W, 
        Nscales = Nscales, 
        sW = sW, 
        sgs = sgs,
        x_sorted = x_sorted,
        R = R,
    )

    return init
end

# Initialize error minimization, as in Keylock (2006).
function get_init_errorminimize(x, method::WLS, rng = Random.default_rng())
    wl = wavelet(method.wt)
    L = length(x)
    x_sorted = sort(x)

    # Wavelet coefficients (step [i] in Keylock)
    W = modwt(x, wl)
    T = eltype(W)
    Nscales = ndyadicscales(L)

    # Will contain surrogate realizations of the wavelet coefficients 
    # at each scale (step [ii] in Keylock). 
    sW = zeros(T, size(W))

    # We will also need a matrix to store the mirror images of the 
    # surrogates (last part of step [ii])
    sWmirr = zeros(T, size(W))

    # Surrogate generators for each set of coefficients
    sgs = [surrogenerator(W[:, i], method.shufflemethod, rng) for i = 1:Nscales]

    # Temporary array for the circular shift error minimizing step 
    circshifted_s = zeros(T, size(W))
    circshifted_smirr = zeros(T, size(W))
    R = zeros(size(W))

    s = similar(x)

    init = (wl = wl, W = W, Nscales = Nscales, L = L, 
            sW = sW, sgs = sgs, sWmirr = sWmirr, 
            circshifted_s = circshifted_s,
            circshifted_smirr = circshifted_smirr,
            x_sorted = x_sorted, R = R,
    )

    return init
end

function surrogenerator(x::AbstractVector{T}, method::WLS, rng = Random.default_rng()) where T
    init = isnothing(method.f) ? 
        get_init_noerrorminimize(x, method, rng) : 
        get_init_errorminimize(x, method, rng)

    s = similar(x)

    return SurrogateGenerator(method, x, s, init, rng)
end

function (sg::SurrogateGenerator{<:WLS})()
    if isnothing(sg.method.f)
        wls_noerrorminimize(sg)
    else
        wls_errorminimize(sg)
    end
end

function wls_noerrorminimize(sg::SurrogateGenerator{<:WLS}) 
    s = sg.s

    fds = (:wl, :W, :Nscales, :sW, :sgs, :x_sorted, :R)
    wl, W, Nscales, sW, sgs, x_sorted, R = getfield.(Ref(sg.init), fds)

    for λ in 1:Nscales
        sW[:, λ] .= sgs[λ]()
    end

    s .= imodwt(sW, wl)

    if sg.method.rescale
        s[sortperm(s)] .= x_sorted
    end

    return s
end

function wls_errorminimize(sg::SurrogateGenerator{<:WLS})
    s = sg.s

    # Error minimization function (if we reached this function, 
    # f is never `Nothing`), so we can use it safely.
    f = sg.method.f 

    fds = (:wl, :W, :Nscales, :L, :sW, :sgs, :sWmirr, 
        :circshifted_s, :circshifted_smirr,
        :x_sorted, :R)

    wl, W, Nscales, L, sW, sgs, sWmirr, 
        circshifted_s, circshifted_smirr,
        x_sorted, R = getfield.(Ref(sg.init), fds)

    # Create surrogate versions of detail coefficients at each dyadic scale [first part of step (ii) in Keylock]   
    for λ in 1:Nscales
        sW[:, λ] .= sgs[λ]()
    end

    # Mirror the surrogate coefficients [last part of step (ii) in Keylock]   
    sWmirr .= reverse(sW, dims = 1)

    # In the original paper, surrogates and mirror images are matched to original 
    # detail coefficients in a circular manner until some error criterion is 
    # minimized. Then, the surrogate or its mirror image, depending on which provides 
    # the best fit to the original coefficients, is chosen as the representative
    # for a particular dyadic scale. Here, we instead use maximal correlation as 
    # the criterion for matching.
    optimal_shifts = zeros(Int, Nscales)
    optimal_shifts_mirr = zeros(Int, Nscales)
    maxcorrs = zeros(Nscales)
    maxcorrs_mirr = zeros(Nscales)

    for i in 0:L-1
        circshift!(circshifted_s, sW, (i, 0))
        circshift!(circshifted_smirr, sWmirr, (i, 0))

        for λ in 1:Nscales
            origW = W[:, λ]
            c = f(origW, circshifted_s[:, λ])
            if c > maxcorrs[λ]
                maxcorrs[λ] = c
                optimal_shifts[λ] = i
            end

            c_mirr = f(origW, circshifted_smirr[:, λ])
            if c_mirr > maxcorrs_mirr[λ]
                maxcorrs_mirr[λ] = c_mirr
                optimal_shifts_mirr[λ] = i
            end
        end
    end

    # Decide which coefficients are retained (either surrogate or mirror surrogate coefficients)
    for λ in 1:Nscales
        if maxcorrs[λ] >= maxcorrs_mirr[λ]
            R[:, λ] .= circshift(sW[:, λ], optimal_shifts[λ])
        else 
            R[:, λ] .= circshift(sWmirr[:, λ], optimal_shifts_mirr[λ])
        end
    end

    s .= imodwt(R, wl)

    if sg.method.rescale
        s[sortperm(s)] .= x_sorted
    end

    return s
end

"""
    RandomCascade(paddingmode::String = "zeros")

A random cascade multifractal wavelet surrogate (Paluš, 2008)[^Paluš2008].

If the input signal length is not a power of 2, the signal must be 
padded before the surrogate is constructed. `paddingmode` determines 
how the signal is padded. Currently supported padding modes: `"zeros"`.
The final surrogate (constructed from the padded signal) is subset
to match the length of the original signal.

Random cascade surrogate preserve multifractal properties of the input 
time series, that is, interactions among dyadic scales and nonlinear 
dependencies[^Paluš2008].

[^Paluš2008]: Paluš, Milan (2008). Bootstrapping Multifractals: Surrogate Data from Random Cascades on Wavelet Dyadic Trees. Physical Review Letters, 101(13), 134101–. doi:10.1103/PhysRevLett.101.134101
"""
struct RandomCascade{WT <: Wavelets.WT.OrthoWaveletClass} <: Surrogate
    wt::WT
    paddingmode::String

    function RandomCascade(; wt::WT = Wavelets.WT.Daubechies{16}(), paddingmode::String = "zeros") where {WT <: Wavelets.WT.OrthoWaveletClass}
        new{WT}(wt, paddingmode)
    end
end

function surrogenerator(x::AbstractVector{T}, method::RandomCascade, rng = Random.default_rng()) where T
    nlevels = ndyadicscales(length(x))
    mode = method.paddingmode

    # Pad input so that input to discrete wavelet transform has length which is a power of 2
    x̃ = zeros(2^(nlevels + 1))
    pad!(x̃, x, mode)

    wl = wavelet(method.wt)

    # Wavelet coefficients (step [i] in Keylock)
    c = dwt(x̃, wl, nlevels)

    # Surrogate coefficients will be partly identical to original coefficients, 
    # so we simply copy them and replace the necessary coefficients later.
    cₛ = copy(c)

    # Multiplication factors and index vectors can be pre-allocated for
    # levels 2:nlevels-1; they are overwritten for each new surrogate.
    Ms = [zeros(dyadicdetailn(j-1)) for j = 2:nlevels-1]
    ixs = [zeros(Int, dyadicdetailn(j-1)) for j = 2:nlevels-1]

    init = (
        wl = wl,
        c = c, 
        cₛ = cₛ,
        nlevels = nlevels,
        s̃ = similar(x̃),
        Ms = Ms,
        ixs = ixs,
    )

    return SurrogateGenerator(method, x, similar(x), init, rng)
end

function (sg::SurrogateGenerator{<:RandomCascade})()
    s, rng = sg.s, sg.rng
    c, cₛ, s̃, wl, nlevels, Ms, ixs = 
        sg.init.c, sg.init.cₛ, sg.init.s̃, sg.init.wl, sg.init.nlevels, sg.init.Ms, sg.init.ixs

    cₛ[dyadicdetailrange(0)] = @view c[dyadicdetailrange(0)]
    cₛ[dyadicdetailrange(1)] = @view c[dyadicdetailrange(1)]

    for (l, j) = enumerate(2:nlevels-1)
        cⱼ₋₁ = @view c[dyadicdetailrange(j - 1)]
        cⱼ = @view c[dyadicdetailrange(j)]

        M = Ms[l]
        ct = 1
        @inbounds for k = 1:length(cⱼ₋₁)
            if k % 2 == 0
                M[ct] = cⱼ[2*k] / cⱼ₋₁[k]
            else 
                M[ct] = cⱼ[2*(k+1)] / cⱼ₋₁[k+1]
            end
            ct += 1
        end

        shuffle!(rng, M)
        new_coeffs!(M, cⱼ₋₁)
        ix = ixs[l]
        sortperm!(ix, M)
        cₛ[dyadicdetailrange(j-1)] .= @view cⱼ₋₁[ix]
    end
    s̃ .= idwt(cₛ, wl, nlevels)

    # Surrogate length must match length of original signal.
    s .= @view s̃[1:length(s)]
    return s
end

function pad!(x̃, x, mode)
    if mode == "zeros"
        copyto!(x̃, x)
    elseif mode == "constant"
        copyto!(x̃, x)
        x̃[length(x)+1:end] .= x[end]
    elseif mode == "linear"
        copyto!(x̃, x)
        for i = length(x)+1:length(x̃)
            x̃[i] = 2*x̃[i-1] - x̃[i-2]
        end
    else
        throw(ArgumentError("""`paddingmode` must be one of ["zeros", "constant", "linear"]"""))
    end
end

function new_coeffs!(M, cⱼ₋₁)
    @inbounds for k = 1:length(cⱼ₋₁)
        M[k] = M[k] * cⱼ₋₁[k]
    end
end
