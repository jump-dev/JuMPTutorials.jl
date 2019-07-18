# JuMPTutorials.jl
This repository contains tutorials on JuMP, a domain-specific modeling language for [mathematical optimization](http://en.wikipedia.org/wiki/Mathematical_optimization) embedded in [Julia](http://julialang.org/).

## Structure

The base file for every tutorial is a regular Julia script 
which is converted into a Jupyter Notebook using Weave.jl for ease of access.
This approach makes it easier to compare diffs and track files in Git compared to entire Jupyter notebooks. 
It also allows us to set up CI testing for the tutorials to ensure that they produce the expected output 
and don’t suffer from bit rot over time.

The base files are present in the script folder inside a subfolder of the relevant category.
Jupyter notebooks generated using Weave.jl are found in the notebook folder. 
The tests folder contains relevant code extracted from the base files for testing and 
the src folder has the Weave.jl utilities used for conversion.

## Contributors

- Arpit Bhatia ([@barpit20](https://github.com/barpit20))
- Chris Coey ([@chriscoey](https://github.com/chriscoey))
- Lea Kapelevich ([@lkapelevich](https://github.com/lkapelevich))
- Joaquim Dias Garcia ([@joaquimg](https://github.com/joaquimg))
- Juan Pablo Vielma ([@juan-pablo-vielma](https://github.com/juan-pablo-vielma))
- Iain Dunning ([@IainNZ](https://github.com/IainNZ))