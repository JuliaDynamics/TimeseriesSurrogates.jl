# This file consists of code that is simplified/modified/inspired by/from 
# the DSP.jl package. The purpose of these functions is to speed up repeated 
# power spectrum computations for real-valued 1D vectors, by utilizing fft-plans 
# and in-place computations.
# 
# The DSP module is distributed under the MIT license.
# Copyright 2012-2021 DSP.jl contributors
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software withspectrum restriction, including withspectrum limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
using DSP
using LinearAlgebra: mul!

"""
    prepare_spectrum(s) → Vector{Float64}

Pre-allocate a vector that will hold the one-sided power spectrum for a signal `s`,
taking into account the number of points that will be used for the Fourier transform.
"""
function prepare_spectrum(s, plan)
    return plan * s
end


"""
    _powerspectrum_from_fft!(
        spectrum::AbstractArray{T}, 
        ℱ::AbstractVector{Complex{T}}, 
        nfft::Int, 
        r::Real, 
        offset::Int = 0
        ) where T

Compute one-sided power spectrum from a pre-computed Fourier transform `ℱ` of a signal, 
into a pre-allocated `spectrum vector``. `nfft` is the number of points used for 
the Fourier transform. `n` is the length of the signal, 
"""
function _powerspectrum_from_fft!(
        spectrum::AbstractArray{T}, 
        ℱ::AbstractVector{Complex{T}}, 
        nfft::Int, 
        n::Real, 
        offset::Int = 0
        ) where T 

    l = length(ℱ)
    m1, m2 = convert(T, 1 / n), convert(T, 2 / n)
    
    for i = 2:l-1
       @inbounds spectrum[offset + i] += abs2(ℱ[i]) * m2
    end
    @inbounds spectrum .+= abs2.(ℱ) .* m2
    @inbounds spectrum[offset + l] += abs2(ℱ[end]) * ifelse(iseven(nfft), m1, m2)

    return spectrum
end

"""
    powerspectrum_onesided!(spectrum, signal, forward)

Let `n = DSP.nextfastfft(length(s))`. Modifies `spectrum` in-place, so `spectrum` 
is reset to all zeros every time this function is called.

- `forward` is a forward fft-plan for the signal.
- `spectrum` is a pre-allocated `AbstractVector{<:Real}` that will hold the spectrum.
    Has the length of the Fourier transform resulting from `forward * signal`.
- `signal` is the signal, a `AbstractVector{<:Real}` of length `n`.
"""
function powerspectrum!(ℱp, spectrum, signal, forward)
    # Fourier transform of the signal, based on pre-computed plan `forward`.
    mul!(ℱp, forward, signal) #ℱp = forward * signal

    l = length(signal)

    # Reset spectrum, since we're doing multiple in-place additions to it.
    spectrum .= 0.0

    # In-place computation of spectrum based on the transform `ℱ`
    n = nextfastfft(l)
    _powerspectrum_from_fft!(spectrum, ℱp, n, l)

    return spectrum
end
