"""
    randomphases(ts::AbstractArray{T, 1} where T)

Create a random phases surrogate for `ts`
    ([Theiler et al., 1992](https://www.sciencedirect.com/science/article/pii/016727899290102S)).
Surrogate realizations using the phase
surrogates have the same linear correlation, or periodogram, as the original data.

## Arguments
- **`ts`**: the time series for which to generate the surrogate realization.

## References

J. Theiler et al., Physica D *58* (1992) 77-94 (1992).
[https://www.sciencedirect.com/science/article/pii/016727899290102S](https://www.sciencedirect.com/science/article/pii/016727899290102S)

"""
function randomphases(ts::AbstractArray{T, 1} where T)
    n = length(ts)

    # Fourier transform
    ft = fft(ts)

    # Polar coordinate representation of the Fourier transform
    r = abs.(ft)    # amplitudes
    ϕ = angle.(ft)  # phase angles

    # Create random phases ϕ on the interval [0, 2π].
    if n % 2 == 0
        midpoint = round(Int, n / 2)
        random_ϕ = rand(Uniform(0, 2*pi), midpoint)
        new_ϕ = [random_ϕ; -reverse(random_ϕ)]
    else
        midpoint = floor(Int, n / 2)
        random_ϕ = rand(Uniform(0, 2*pi), midpoint)
        new_ϕ = [random_ϕ; random_ϕ[end]; -reverse(random_ϕ)]
    end

    # Inverse Fourier transform of the original amplitudes, but with randomised phases.
    real.(ifft(r .* exp.(new_ϕ .* 1im)))
end
