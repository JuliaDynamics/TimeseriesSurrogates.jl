"""
    randomamplitudes(ts::AbstractArray{T, 1} where T)

Create a random amplitude surrogate for `ts`.

A modification of the random phases surrogates from
[Theiler et al., 1992](https://www.sciencedirect.com/science/article/pii/016727899290102S)
, where amplitudes are adjusted instead of the phases after taking the Fourier
transform.

## Arguments
- ts`**: the time series for which to generate the surrogate realization.

## References

J. Theiler et al., Physica D *58* (1992) 77-94 (1992).
[https://www.sciencedirect.com/science/article/pii/016727899290102S](https://www.sciencedirect.com/science/article/pii/016727899290102S)

"""
function randomamplitudes(ts::AbstractArray{T, 1} where T)
    n = length(ts)

    # Fourier transform
    ft = fft(ts)

    # Polar coordinate representation of the Fourier transform
    r = abs.(ft)    # amplitudes
    ϕ = angle.(ft)  # phase angles

    # To randomise phases, we multiply each complex amplitude by e^(iϕ), with ϕ picked
    # on the interval [0, 2π]. Here, we pick according to a uniform distribution.
    randomised_amplitudes = r .* rand(Uniform(0, 2*pi), n)
    real.(ifft(randomised_amplitudes .* exp.(ϕ .* 1im)))
end
