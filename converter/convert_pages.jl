using Weave
using InteractiveUtils

const main_dir = joinpath(@__DIR__, "..")
const src_dir = joinpath(main_dir, "script")
const notebook_dir = joinpath(main_dir, "notebook")
const test_dir = joinpath(main_dir, "test")

"""
Generates the notebook and lightened source files for test
"""
function generate_output()
    for folder in readdir(src_dir)
        for file in readdir(joinpath(src_dir, folder))
            if endswith(file, ".jl")
                @info("Building $(folder)/$(file)")
                filename = split(file, ".")[1]
                testpath = joinpath(test_dir, folder, "$file")
                notebookpath = joinpath(notebook_dir, folder)
                srcpath = joinpath(src_dir, folder, file)
                try
                    Weave.notebook(srcpath, out_path=notebookpath, timeout=-1, nbconvert_options="--allow-errors")
                    Weave.tangle(srcpath, out_path=testpath)
                catch e
                    @warn("Error weaving $folder/$file:\n$e")
                end
                println("")
            end
        end
    end
end
