cd(@__DIR__)
using Pkg
CI = get(ENV, "CI", nothing) == "true" || get(ENV, "GITHUB_TOKEN", nothing) !== nothing
Pkg.activate(@__DIR__)
CI && Pkg.instantiate()

using TimeseriesSurrogates
using DynamicalSystems
using Random
using Distributions
using CairoMakie, Makie
using Documenter
using DocumenterTools: Themes

# %% JuliaDynamics theme.
# download the themes
using DocumenterTools: Themes
for file in ("juliadynamics-lightdefs.scss", "juliadynamics-darkdefs.scss", "juliadynamics-style.scss")
    download("https://raw.githubusercontent.com/JuliaDynamics/doctheme/master/$file", joinpath(@__DIR__, file))
end
# create the themes
for w in ("light", "dark")
    header = read(joinpath(@__DIR__, "juliadynamics-style.scss"), String)
    theme = read(joinpath(@__DIR__, "juliadynamics-$(w)defs.scss"), String)
    write(joinpath(@__DIR__, "juliadynamics-$(w).scss"), header*"\n"*theme)
end
# compile the themes
Themes.compile(joinpath(@__DIR__, "juliadynamics-light.scss"), joinpath(@__DIR__, "src/assets/themes/documenter-light.css"))
Themes.compile(joinpath(@__DIR__, "juliadynamics-dark.scss"), joinpath(@__DIR__, "src/assets/themes/documenter-dark.css"))

# %% Build docs
cd(@__DIR__)
ENV["JULIA_DEBUG"] = "Documenter"

PAGES = [
    "Documentation" => "index.md",
    "What is a surrogate?" => "man/whatisasurrogate.md",
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
    "Utility systems" => "man/exampleprocesses.md",
    "Contributing" => "contributor_guide.md"
]

makedocs(
    modules = [TimeseriesSurrogates, DynamicalSystems],
    format = Documenter.HTML(
        prettyurls = CI,
        assets = [
            asset("https://fonts.googleapis.com/css?family=Montserrat|Source+Code+Pro&display=swap", class=:css),
        ],
        ),
    sitename = "TimeseriesSurrogates.jl",
    authors = "Kristian Agasøster Haaga, George Datseris",
    pages = PAGES,
    expandfirst = ["index.md"], #  this is the first script that loads plotting function
)

if CI
    deploydocs(
        repo = "github.com/JuliaDynamics/TimeseriesSurrogates.jl.git",
        target = "build",
        push_preview = true
    )
end
