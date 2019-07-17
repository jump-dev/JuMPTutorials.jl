using Documenter, JuMPTutorials

makedocs(;
    modules=[JuMPTutorials],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/barpit20/JuMPTutorials.jl/blob/{commit}{path}#L{line}",
    sitename="JuMPTutorials.jl",
    authors="Arpit Bhatia <arpit16229@iiitd.ac.in>",
    assets=String[],
)

deploydocs(;
    repo="github.com/barpit20/JuMPTutorials.jl",
)
