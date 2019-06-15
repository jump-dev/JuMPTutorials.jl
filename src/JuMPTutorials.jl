module JuMPTutorials

using Weave

repo_directory = joinpath(@__DIR__,"..")

function weave_file(folder,file)
    filename = split(file, ".")[1]
    srcpath = joinpath(repo_directory, "script", folder, file)
    testpath = joinpath(repo_directory, "test", folder, file)
    notebookpath = joinpath(repo_directory, "notebook", folder, string(filename, ".ipynb"))

    if mtime(srcpath) > mtime(testpath) || mtime(testpath)==0
        @warn "Updating tests for $filename as it has been updated since the last weave."
        tangle(srcpath, out_path=testpath)
    else
        @warn "Skipping tests for $filename as it has not been updated."
    end

    if mtime(srcpath) > mtime(htmlpath) || mtime(htmlpath)==0
        @warn "Weaving $filename to HTML as it has been updated since the last weave."
        weave(srcpath, doctype="md2html")
    else
        @warn "Skipping HTML for $filename as it has not been updated."
    end

    if mtime(srcpath) > mtime(pdfpath) || mtime(pdfpath)==0
        @warn "Weaving $filename to PDF as it has been updated since the last weave."
        weave(srcpath, doctype="md2pdf")
    else
        @warn "Skipping PDF for $filename as it has not been updated."
    end

    if mtime(srcpath) > mtime(notebookpath) || mtime(notebookpath)==0
        @warn "Weaving $filename to Jupyter Notebook as it has been updated since the last weave."
        convert_doc(srcpath, notebookpath)
    else
        @warn "Skipping Jupyter Notebook for $filename as it has not been updated."
    end

end

function weave_all()
    for folder in readdir(joinpath(repo_directory,"script"))
        weave_folder(folder)
    end
end

function weave_folder(folder)
    for file in readdir(joinpath(repo_directory,"script",folder))
        println("Building $(joinpath(folder,file))")
        try
            weave_file(folder,file)
        catch
        end
    end
end

end
