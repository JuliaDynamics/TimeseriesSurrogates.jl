using Documenter, TimeseriesSurrogates
#
# makedocs(modules = [TimeseriesSurrogates],
#          doctest = true)
#
# deploydocs(deps = Deps.pip("mkdocs", "python-markdown-math"),
#            repo = "github.com/kahaaga/TimeseriesSurrogates.git",
#            julia  = "0.6",
#            osname = "linux")
makedocs(format = :html,
        sitename = "TimeseriesSurrogates docs")

deploydocs(
    repo = "github.com/kahaaga/TimeseriesSurrogates.jl.git"
)

deploydocs(
    #deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo   = "github.com/kahaaga/TimeseriesSurrogates.jl.git",
    julia  = "0.4",
    osname = "osx"
)
