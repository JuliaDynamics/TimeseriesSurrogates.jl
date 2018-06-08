using Documenter, TimeseriesSurrogates
ENV["GKSwstype"] = "100"

makedocs(format = :html,
        sitename = "TimeseriesSurrogates docs",
        pages = [
            "Index" => "index.md"
        ])

deploydocs(
    deps   = Deps.pip("pygments", "mkdocs", "mkdocs-material", "python-markdown-math"),
    repo   = "github.com/kahaaga/TimeseriesSurrogates.jl.git",
    julia  = "0.6",
    osname = "linux"
)
