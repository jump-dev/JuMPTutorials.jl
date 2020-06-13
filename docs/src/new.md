# Adding a New Tutorial

## 1. Write the Tutorial

Tutorials should be written in the form of a `.jl` file and
added to the script folder inside a subfolder of the relevant category.

Lines starting with `#'` are used to denote markdown blocks.
For consistency, we always use `#'` even though Weave supports using `#%%` or `# %%`.
For ease of viewing and reviewing diff code, 
please use [Semantic Line Breaks](https://sembr.org/) in text.

We use a YAML header in the beginning of the input document delimited with "–-" to set the document title.
The author's name is specified in the next line as "Originally Contributed by". 
We use this format as the code in the notebook may be updated in the future based on changes to JuMP or Julia.

[](http://weavejl.mpastell.com/dev/usage/#Tangle-1)

Boilerplate code you can use to get started is given below:

```julia
#' ---
#' title: Notebook Name
#' ---

#' **Originally Contributed by**: John Doe

#' A Markdown Block

print("Hello World")
```

Do have a look at the notes for handling specific cases. 

## 2. Handle Additional Files

In case a tutorial uses additional files (such as for reading data), 
it is recommended to download and add the files to this repository to prevent broken links in the future. 
The files must also be copied into the corresponding folders inside the `notebook` and `test` directories. 
In case of images which are used to be used when the file is converted into a Jupyter Notebook, 
it is sufficient to only have them in the `notebook` directory.

## 3. Use Weave

To generate the Jupyter Notebook and a separate Julia file for testing, run the `weave_file` function. 

```julia
using JuMPTutorials
JuMPTutorials.weave_file("subfolder_name","tutorial_name")
```

## 4. Add Tests

Add the file generated inside the `test` folder to the `runtests.jl` file using 
the [`include`](https://docs.julialang.org/en/v1/base/base/#Base.include) function. 
This tests if the notebook runs without any errors. 
To check if the results produced are correct, add your own tests below the `include` function using the `@test` macro.
It is recommended to use ≈ (\approx) for equality checks due to differences in numerical accuracies of solvers. You'll also need to add dependencies in case you use any new package.

## 5. Add to README

Finally, add the tutorial to the table of contents in the `README.md` file. 
We use nbviewer to render the notebooks as webpages. 
Link the name of the tutorial to a URL of the following form:

`https://nbviewer.jupyter.org/github/jump-dev/JuMPTutorials.jl/blob/master/notebook/subfolder_name/tutorial_name.ipynb`