# Notes

## Using Solvers and Other Additional Packages
Certain solvers may require a license or an additional installation. Since we want to test the tutorials using Travis CI and run them in the browser using Binder, we should always try to go for the solver which works out of the box with just a Package install. In case this is not possible, do not add the tutorial to the `runtests.jl` file and add a line that it does not work with Binder. Note that this issue is not specific to solvers and may arise with other Julia packages as well.

## Tangle
We use the tangle feature of Weave.jl to generate files for testing as it allows us extract code from a file. This enables us to skip cetains blocks of code we would not want for tests. These include-
### Deliberate Errors
Tutorials might contain examples of what not to do and hence some code blocks can throw errors on purpose. These blocks cause tests to fail when we run the entire tutorial and hence they are skipped from tangle.
### Installing Packages
THough code that installs packages will not cause tests to fail, it will slow them down. Since we are already adding all the required packages as dependencies, blocks that install packages are skipped from tangle. 

## Citations
Citations are added manually using links in markdown and not through tools like BibTeX. This method works for our use case as the number of citations per tutorial is quite less. Boilerplate code you can use is given below:

```julia
#' Lets add a citation[[1]](#c1).
#' Here's another one[[2]](#c2).

#' ### References
#' <a id='c1'></a>
#' 1. First citation in plain text.
#' <a id='c2'></a>
#' 2. Second citation in plain text.
```

## Graphics in the Notebooks
The `notebook` function in Weave.jl currently does not support Gadfly plot output([116](https://github.com/mpastell/Weave.jl/issues/116)). In case a tutorial has plots, you'll have to open the generated notebook in Jupyter and from the menu select "Cell > Run All".