using Documenter, JuMPTutorials

makedocs(
    modules = [JuMPTutorials],
    format = Documenter.HTML(),
    sitename = "JuMPTutorials.jl",
    authors  = "Arpit Bhatia",
    pages = [
        "Home" => "index.md",
        "Adding a New Tutorial" => "new.md",
        "Notes" => "notes.md",
        "Future Work" => "future.md",
        "Function Index" => "api.md"
    ]
)

Documenter.deploydocs(repo = "github.com/jump-dev/JuMPTutorials.jl.git")
