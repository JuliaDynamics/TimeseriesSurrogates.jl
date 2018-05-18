using Documenter, TimeseriesSurrogates
#
# makedocs(modules = [TimeseriesSurrogates],
#          doctest = true)
#
# deploydocs(deps = Deps.pip("mkdocs", "python-markdown-math"),
#            repo = "github.com/kahaaga/TimeseriesSurrogates.git",
#            julia  = "0.6",
#            osname = "linux")
ENV["GKSwstype"] = "100"

makedocs(format = :html,
        sitename = "TimeseriesSurrogates docs")

deploydocs(
    #deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo   = "github.com/kahaaga/TimeseriesSurrogates.jl.git",
    julia  = "0.6",
    osname = "linux"
)
