export WLS
using Wavelets

"""
    WLS(surromethod::Surrogate = IAAFT(), 
        rescale::Bool = true,
        wt::Wavelets.WT.OrthoWaveletClass = Wavelets.WT.Daubechies{16}())

A wavelet surrogate generated by taking the maximal overlap discrete 
wavelet transform (MODWT) of the signal, shuffling detail 
coefficients at each dyadic scale using the provided `surromethod`,
then taking the inverse transform to obtain a surrogate.

## Coefficient shuffling method

In contrast to the original 
implementation where IAAFT is used, you may choose to use any surrogate 
method from this package to perform the randomization of the detail 
coefficients at each dyadic scale. Note: The iterative procedure after 
the rank ordering step (step [v] in [^Keylock2006]) is not performed in 
this implementation.

If `surromethod == IAAFT()`, the wavelet surrogates preserves the local 
mean and variance structure of the signal, but randomises nonlinear 
properties of the signal (i.e. Hurst exponents)[^Keylock2006]. These surrogates
can therefore be used to test for changes in nonlinear properties of the 
original signal.

In contrast to IAAFT surrogates, the IAAFT-wavelet surrogates also 
preserves nonstationarity. Using other `surromethod`s does not necessarily
preserve nonstationarity.

To deal with nonstationary signals, Keylock (2006) recommends using a 
wavelet with a high number of vanishing moments. Thus, the default is to
use a Daubechies wavelet with 16 vanishing moments.


## Rescaling 

If `rescale == true`, then surrogate values are mapped onto the 
values of the original time series, as in the [`AAFT`](@ref) algorithm.
If `rescale == false`, surrogate values are not constrained to the 
original time series values.

[^Keylock2006]: C.J. Keylock (2006). "Constrained surrogate time series with preservation of the mean and variance structure". Phys. Rev. E. 73: 036707. doi:10.1103/PhysRevE.73.036707.
"""
struct WLS{WT <: Wavelets.WT.OrthoWaveletClass, S <: Surrogate} <: Surrogate
    surromethod::Surrogate # should preserve values of the original series
    rescale::Bool
    wt::WT

    function WLS(method::S = IAAFT(), rescale::Bool = true, wt::WT = Wavelets.WT.Daubechies{16}()) where {S <: Surrogate, WT <: Wavelets.WT.OrthoWaveletClass}
        new{WT, S}(method, rescale, wt)
    end
end

function surrogenerator(x::AbstractVector{T}, method::WLS, rng = Random.default_rng()) where T
    wl = wavelet(method.wt)
    L = length(x)
    x_sorted = sort(x)

    # Wavelet coefficients (step [i] in Keylock)
    W = modwt(x, wl)
    Nscales = ndyadicscales(L)

    # Will contain surrogate realizations of the wavelet coefficients 
    # at each scale (step [ii] in Keylock). 
    sW = zeros(T, size(W))

    # We will also need a matrix to store the mirror images of the 
    # surrogates (last part of step [ii])
    sWmirr = zeros(T, size(W))

    # Surrogate generators for each set of coefficients
    sgs = [surrogenerator(W[:, i], method.surromethod, rng) for i = 1:Nscales]

    # Temporary array for the circular shift error minimizing step 
    circshifted_s = zeros(T, size(W))
    circshifted_smirr = zeros(T, size(W))
    R = zeros(size(W))

    init = (wl = wl, W = W, Nscales = Nscales, L = L, 
            sW = sW, sgs = sgs, sWmirr = sWmirr, 
            circshifted_s = circshifted_s,
            circshifted_smirr = circshifted_smirr,
            x_sorted = x_sorted, R = R,
    )
    
    return SurrogateGenerator(method, x, init, rng)
end
 
function (sg::SurrogateGenerator{<:WLS})()
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
            c = cor(origW, circshifted_s[:, λ])
            if c > maxcorrs[λ]
                maxcorrs[λ] = c
                optimal_shifts[λ] = i
            end

            c_mirr = cor(origW, circshifted_smirr[:, λ])
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

    s = imodwt(R, wl)

    if sg.method.rescale
        s[sortperm(s)] = x_sorted
    end

    return s
end


export WLS2
struct WLS2{WT <: Wavelets.WT.OrthoWaveletClass, S <: Surrogate} <: Surrogate
    surromethod::Surrogate # should preserve values of the original series
    rescale::Bool
    wt::WT

    function WLS2(method::S = IAAFT(), rescale::Bool = true, wt::WT = Wavelets.WT.Daubechies{16}()) where {S <: Surrogate, WT <: Wavelets.WT.OrthoWaveletClass}
        new{WT, S}(method, rescale, wt)
    end
end

function surrogenerator(x::AbstractVector{T}, method::WLS2, rng = Random.default_rng()) where T
    wl = wavelet(method.wt)
    L = length(x)
    x_sorted = sort(x)

    # Wavelet coefficients (step [i] in Keylock)
    W = modwt(x, wl)
    Nscales = ndyadicscales(L)

    # Will contain surrogate realizations of the wavelet coefficients 
    # at each scale (step [ii] in Keylock). 
    sW = zeros(T, size(W))

    # We will also need a matrix to store the mirror images of the 
    # surrogates (last part of step [ii])
    sWmirr = zeros(T, size(W))

    # Surrogate generators for each set of coefficients
    sgs = [surrogenerator(W[:, i], method.surromethod, rng) for i = 1:Nscales]

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
    
    return SurrogateGenerator2(method, x, s, init, rng)
end

function (sg::SurrogateGenerator2{<:WLS2})()
    s = sg.s

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
            c = cor(origW, circshifted_s[:, λ])
            if c > maxcorrs[λ]
                maxcorrs[λ] = c
                optimal_shifts[λ] = i
            end

            c_mirr = cor(origW, circshifted_smirr[:, λ])
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

