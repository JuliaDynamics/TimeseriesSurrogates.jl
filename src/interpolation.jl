"""
Linearly interpolates two vectors x and y on a linear grid consisting of `nsteps`.
"""
function interp(x::Vector, y::Vector, nsteps::Int)
    # Interpolate
    itp = interpolate((x,), y, Gridded(Linear()))
    # Interpolate at the given resolution
    x_fills = LinRange(minimum(x), maximum(x), nsteps)
    y_fills = itp(x_fills)

    return collect(x_fills), y_fills
end

"""
Linearly interpolates two vector x and y on a linear grid consisting of `nsteps`.
"""
function interp(x, y, range::LinRange)
    itp = interpolate((x,), y, Gridded(Linear()))
    
    # Interpolate at the given resolution
    return itp(range)
end