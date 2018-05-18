"""
    randomamplitudes(ts)

Create a random amplitude surrogate for `ts`.

A modification of the random phases surrogates (from J. Theiler et al., Physica D *58*
(1992) 77-94 (1992)) where amplitudes are adjusted instead.

"""
function randomamplitudes(ts)
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
