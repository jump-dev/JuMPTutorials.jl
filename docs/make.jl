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
