using Documenter, TimeseriesSurrogates
ENV["GKSwstype"] = "100"

makedocs(
    format = :html,
    sitename = "TimeseriesSurrogates.jl",
    modules = [TimeseriesSurrogates],
    pages = ["Home" => "index.md"],
    # Use clean URLs, unless built as a "local" build
    html_prettyurls = !("local" in ARGS),
    html_canonical = "https://kahaaga.github.io/TimeseriesSurrogates.jl/stable/"
)

deploydocs(
    repo   = "github.com/kahaaga/TimeseriesSurrogates.jl.git",
    julia  = "0.6",
    osname = "linux"
)
