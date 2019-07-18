using Documenter, JuMPTutorials

makedocs(
    modules = [JuMPTutorials],
    format = Documenter.HTML(),
    sitename = "JuMPTutorials.jl",
    authors  = "Arpit Bhatia",
    pages = [
        "Home" => "index.md",
        "API" => "api.md"
    ]
)

Documenter.deploydocs(
    repo = "github.com/barpit20/JuMPTutorials.jl.git",
    target = "build"
)
