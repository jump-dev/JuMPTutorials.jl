# JuMPTutorials.jl

[![Powered by NumFOCUS](https://img.shields.io/badge/powered%20by-NumFOCUS-orange.svg?style=flat&colorA=E1523D&colorB=007D8A)](http://numfocus.org)
[![Build Status](https://travis-ci.com/barpit20/JuMPTutorials.jl.svg?branch=master)](https://travis-ci.com/barpit20/JuMPTutorials.jl)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://barpit20.github.io/JuMPTutorials.jl/dev)


This repository contains tutorials on JuMP, a domain-specific modeling language for [mathematical optimization](http://en.wikipedia.org/wiki/Mathematical_optimization) embedded in [Julia](http://julialang.org/). Tutorials can be viewed in the form of webpages, and interactive Jupyter notebooks. This set of tutorials is made to complement the documentation by providing practical examples of the concepts. For more details, please consult the [JuMP documentation](http://www.juliaopt.org/JuMP.jl/v0.19.1/).

These tutorials are currently under development as a part of a Google Summer of Code [project](https://summerofcode.withgoogle.com/projects/#5903911565656064). The current list of tutorials that are planned can be viewed at the following [issue](https://github.com/barpit20/JuMPTutorials.jl/issues/1). If there is a tutorial you would like to request, please add a comment to the above issue. Any other suggestions are welcome as well.

There are also some older notebooks available at [juliaopt-notebooks](https://github.com/JuliaOpt/juliaopt-notebooks) repository. Most of these were built using prior versions of JuMP and may not function correctly, but they can assist in implementing some concepts. There are also some code examples available in the main [JuMP repo](https://github.com/JuliaOpt/JuMP.jl/tree/release-0.19/examples).

## Run Notebooks in the Browser
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/barpit20/JuMPTutorials.jl/master)

To try out any of the tutorials in the browser without downloading Julia, click on the launch binder button above. Note that this functionality only supports open-source solvers which do not have additional requirements (for e.g. BLAS or MATLAB). This is also significantly slower than running them using Jupyter. Thus, you should download and run the notebooks on your PC for the best experience.

## Table of Contents

- Introduction
  - [An Introduction to Julia](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/introduction/an_introduction_to_julia.ipynb)
  - [Getting Started with JuMP](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/introduction/getting_started_with_JuMP.ipynb)
  - [Variables, Constraints and Objective](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/introduction/variables_constraints_objective.ipynb)
  - [Solvers and Solutions](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/introduction/solvers_and_solutions.ipynb)
- Using JuMP
  - [Working with Data Files](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/using_JuMP/working_with_data_files.ipynb) 
  - [Problem Modification](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/using_JuMP/problem_modification.ipynb)
- Optimization Concepts
  - [Integer Programming](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/optimization_concepts/integer_programming.ipynb)
  - [Conic Programming](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/optimization_concepts/conic_programming.ipynb)
- Modelling Examples
  - [Sudoku](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/modelling/sudoku.ipynb)
  - [Problems on Graphs](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/modelling/problems_on_graphs.ipynb)
  - [Network Flows](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/modelling/network_flows.ipynb)
  - [Finance](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/modelling/finance.ipynb)
  - [Geometric Problems](https://nbviewer.jupyter.org/github/barpit20/JuMPTutorials.jl/blob/master/notebook/modelling/geometric_problems.ipynb)