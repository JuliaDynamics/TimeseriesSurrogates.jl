"""
Linearly interpolates two vector x and y on a linear grid with binsizes given by `by`.
"""
function intp(x::Vector, y::Vector, nsteps::Int)
    # Interpolate
    itp = interpolate((x,), y, Gridded(Linear()))
    # Interpolate at the given resolution
    x_fills = LinRange(minimum(x), maximum(x), nsteps)
    y_fills = itp[x_fills]

    return collect(x_fills), y_fills
end

export intp