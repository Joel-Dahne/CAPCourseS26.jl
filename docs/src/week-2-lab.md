# Week 2 Lab: Julia basics

While the course doesn't directly assume any familiarity with Julia,
we also won't have the time for a thorough introduction of the entire
Julia language. The goal of this lab is to build some familiarity with
the basics of Julia.

Some of the things we will look at in this lab are:

1. Functions
2. Types
3. Loops
4. Plotting

For this we will use the Pluto notebook `lab-2.jl` that you can find
in the `notebooks` directory. You can start this notebook in the same
way as you started the `lab-1.jl` notebook in Lab 1. Navigate to the
`notebooks` directory of this repository and start Julia. You can then
activate the directory project and start Pluto with

``` julia
using Pkg
Pkg.activate(".")
using Pluto
Pluto.run()
```

!!! tip
    If you get an error of the form "Package Pluto not found, but a
    package named Pluto is available from a registry." then you have
    activated the wrong project. Make sure that you start Julia from
    the `notebooks` directory.

## High-level overview of Julia

While not necessary to start using Julia, it can be beneficial to know
some of the things that make Julia what it is. Many of these points
require experience with other programming languages to have something
to compare to.

- Dynamically typed: You don't have to specify the types of variables,
  but you can if you want to. This differs from for example C where
  you always have to specify the types, and Python where you most of
  the time do not specify the type (modern Python has some support for
  types though).
- JIT (Just In Time) compiled: Julia compiles the code before it runs
  it, which allows it to generate optimized code. Compared to many
  other languages the compilation is however not done in a separate
  step, but rather the compilation happens as you are running the
  code. This gives you the performance of a compiled language, but the
  flexibility of a dynamic language. There are of course downsides to
  this as well, the most notable one being that sometimes it can take
  quite some time to compile the code.
- Garbage collected: In some programming languages, most notably C,
  the programmer is in charge of managing the memory that the program
  uses. Most modern languages (with some notable exceptions) defer the
  memory handling to a process known as garbage collection. This is
  convenient when writing the code, but in some cases comes with
  performance issues. We will see some of these issues when working
  with high precision intervals later in the course.
- 1-based indexing: Different programming languages use different
  conventions regarding whether 0 or 1 is the first index in an array.
  Julia, together with for example Matlab and Fortran, uses 1-based
  indexing, meaning that the first index in an array is `1`. Python
  and C (and many other languages) instead use 0-based indexing, where
  the first index is `0`. In mathematics we usually switch indexing
  depending on context, e.g. matrices are indexed starting from 1,
  whereas polynomial coefficients are indexed from 0. For some reason
  [people have strong opinions about
  this](https://discourse.julialang.org/t/whats-the-big-deal-0-vs-1-based-indexing/1102).
- [Multiple
  dispatch](https://en.wikipedia.org/wiki/Multiple_dispatch): An
  important part of what makes Julia Julia is that it makes use of
  multiple dispatch for function overloading. This allows you to
  define multiple versions of a function. Which version is being used
  is determined based on the type of the input arguments. This is in
  particular very useful for rigorous numerics since it makes it
  relatively easy to write code that works for both non-rigorous
  floating point numbers as well as rigorous interval arithmetic. We
  will see more examples of how this works in practice later in the
  course.
