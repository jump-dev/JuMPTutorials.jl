using Documenter

makedocs(
    format = Documenter.HTML(),
    sitename = "JuMPTutorials.jl",
    authors  = "JuMP-dev",
    pages = [
        "Home" => "index.md",
        "Adding a new tutorial" => "new.md",
        "Notes" => "notes.md",
        "Future work" => "future.md",
    ],
)

Documenter.deploydocs(repo = "github.com/jump-dev/JuMPTutorials.jl.git")

const converter_path = joinpath(@__DIR__, "../converter")

# notebook deployment phase
using Pkg
Pkg.activate(converter_path)
Pkg.instantiate()

include(joinpath(converter_path, "convert_pages.jl"))

Documenter.deploydocs(
    repo = "github.com/jump-dev/JuMPTutorials.jl.git",
    target = "../notebook",
    branch = "notebook",
)
