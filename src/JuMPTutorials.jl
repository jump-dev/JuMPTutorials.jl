module JuMPTutorials

using Weave

repo_directory = joinpath(@__DIR__,"..")

"""
`weave_file(folder::AbstractString, file::AbstractString)`
Checks if the file has been modified since the last Weave and updates the notebook and tests accordingly.
* `folder` = Name of the folder the tutorial is in
* `file` = Name of the tutorial file
"""
function weave_file(folder,file)
    cd(joinpath(repo_directory,"script",folder))
    
    filename = split(file, ".")[1]
    srcpath = joinpath(repo_directory, "script", folder, file)
    testpath = joinpath(repo_directory, "test", folder, file)
    notebookpath = joinpath(repo_directory, "notebook", folder)

    if mtime(srcpath) > mtime(testpath) || mtime(testpath)==0
        @warn "Updating tests for $filename as it has been updated since the last weave."
        tangle(srcpath, out_path=testpath)
    else
        @warn "Skipping tests for $filename as it has not been updated."
    end

    if mtime(srcpath) > mtime(notebookpath) || mtime(notebookpath)==0
        @warn "Weaving $filename to Jupyter Notebook as it has been updated since the last weave."
        notebook(srcpath, notebookpath, -1, "--allow-errors")
    else
        @warn "Skipping Jupyter Notebook for $filename as it has not been updated."
    end

    cd(joinpath(repo_directory,"src"))
end

"""
`weave_file(folder::AbstractString)`
Checks the files present in the specified folder for modifications and updates the notebook and tests accordingly.
* `folder` = Name of the folder to check
"""
function weave_folder(folder)
    for file in readdir(joinpath(repo_directory,"script",folder))
        println("")
        println("Building $(joinpath(folder,file))")
        try
            weave_file(folder,file)
        catch
        end
        println("")
    end
end

"""
`weave_all()`
Checks every tutorial for modifications and updates the notebook and tests accordingly.
"""
function weave_all()
    for folder in readdir(joinpath(repo_directory,"script"))
        weave_folder(folder)
    end
end

"""
`weave_file_f(folder::AbstractString, file::AbstractString)`
Use Weave to convert the given file irrespective of whether it has been modified or not.
* `folder` = Name of the folder the tutorial is in
* `file` = Name of the tutorial file
"""
function weave_file_f(folder,file)
    cd(joinpath(repo_directory,"script",folder))
    
    srcpath = joinpath(repo_directory, "script", folder, file)
    testpath = joinpath(repo_directory, "test", folder, file)
    notebookpath = joinpath(repo_directory, "notebook", folder)

    tangle(srcpath, out_path = testpath)
    notebook(srcpath, notebookpath, -1, "--allow-errors")

    cd(joinpath(repo_directory,"src"))
end

"""
`weave_file_f(folder::AbstractString, file::AbstractString)`
Use Weave to convert every file in the specified folder irrespective of whether it has been modified or not.
* `folder` = Name of the folder the tutorial is in
"""

function weave_folder_f(folder)
    for file in readdir(joinpath(repo_directory,"script",folder))
        println("")
        println("Building $(joinpath(folder,file))")
        try
            weave_file_f(folder,file)
        catch
        end
        println("")
    end
end

"""
`weave_all_f()`
Use Weave to convert every tutorial irrespective of whether it has been modified or not.
"""
function weave_all_f()
    for folder in readdir(joinpath(repo_directory,"script"))
        weave_folder_f(folder)
    end
end

end