using CollatzConjecture
using Documenter

DocMeta.setdocmeta!(CollatzConjecture, :DocTestSetup, :(using CollatzConjecture); recursive=true)

makedocs(;
    modules=[CollatzConjecture],
    authors="Rethna Pulikkoonattu et al.",
    sitename="CollatzConjecture.jl",
    format=Documenter.HTML(;
        canonical="https://geekymode.github.io/CollatzConjecture.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/geekymode/CollatzConjecture.jl",
    devbranch="main",
)
