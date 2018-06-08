using Documenter, TimeseriesSurrogates
ENV["GKSwstype"] = "100"

makedocs(;
    format = :html,
    sitename = "TimeseriesSurrogates docs",
    modules = [TimeseriesSurrogates],
    pages = ["index.md"]
)

deploydocs(;
    repo   = "github.com/kahaaga/TimeseriesSurrogates.jl.git",
    julia  = "0.6",
    osname = "linux",
    target = "build",
    branch = "gh-pages",
    latest = "master"
)
