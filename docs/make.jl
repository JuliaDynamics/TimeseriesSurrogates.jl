using Documenter, TimeseriesSurrogates
#```julia
#push!(LOAD_PATH,"../src/")
#```
ENV["GKSwstype"] = "100"

makedocs(
    format = :html,
    sitename = "TimeseriesSurrogates.jl",
    modules = [TimeseriesSurrogates],
    pages = [
        "Overview" => "index.md",
        "What is a surrogate?" => "man/whatisasurrogate.md",
        "Surrogate algorithms" => [
            "Random shuffle (RS)" => "constrained/randomshuffle.md",
            "Fourier transform (FT)" => "constrained/fourier_surrogates.md",
            "Amplitude adjusted Fourier (AAFT)" => "constrained/amplitude_adjusted.md"
        ],
        "Visualising surrogate realizations and creating gifs" => "plots/visualize_surrogate.md"
    ],
    # Use clean URLs, unless built as a "local" build
    html_prettyurls = !("local" in ARGS),
    html_canonical = "https://kahaaga.github.io/TimeseriesSurrogates.jl/latest/"
)

deploydocs(
    repo   = "github.com/kahaaga/TimeseriesSurrogates.jl.git",
    julia  = "0.6",
    osname = "linux"
)
