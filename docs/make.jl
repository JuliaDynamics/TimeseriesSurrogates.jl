cd(@__DIR__)
using TimeseriesSurrogates

pages = [
    "Documentation" => "index.md",
    "man/whatisasurrogate.md",
    "Example applications" => [
        "Shuffle-based" => "methods/randomshuffle.md",
        "Fourier-based" => "methods/fourier_surrogates.md",
        "Wavelet-based" => "methods/wls.md",
        "Pseudo-periodic" => "methods/pps.md",
        "Pseudo-periodic twin" => "methods/ppts.md",
        "Multidimensional surrogates" => "methods/multidim.md",
        "Surrogates for irregular timeseries" => "collections/irregular_surrogates.md",
        "Surrogates for nonstationary timeseries" => "collections/nonstationary_surrogates.md"
    ],
    "man/exampleprocesses.md",
    "contributor_guide.md"
]

import Downloads
Downloads.download(
    "https://raw.githubusercontent.com/JuliaDynamics/doctheme/master/build_docs_with_style.jl",
    joinpath(@__DIR__, "build_docs_with_style.jl")
)
include("build_docs_with_style.jl")

build_docs_with_style(pages, TimeseriesSurrogates;
    expandfirst = ["index.md"],
    authors = "Kristian Agasøster Haaga, George Datseris",
)
