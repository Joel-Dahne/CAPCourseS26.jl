# Week 9 Lab: Performance comparisons between Arblib.jl and IntervalArithmetic.jl

In this lab we will see how Arblib.jl and IntervalArithmetic.jl
compare when it comes to performance. In the process we will also look
at how to perform different types of computations in the two packages.

We will compare the performance for:

1. Basic arithmetic
2. Elementary functions
3. Linear algebra

We will do the comparisons between `Interval{Float64}` and `Arb` with
53 bits of precision as well as between `Interval{BigFloat}` and
`Arb`, both with 256 bits of precision.

Since IntervalArithmetic.jl doesn't support any special functions nor
does it have any routines for polynomials, we can't make any
comparisons for that.

See `lab-9.jl` in the `notebooks` directory for more details. You can
also find "solutions" in `lab-9-solutions.jl`. If you want to see the
results but not run the code yourself you can open the file
`lab-9-solutions.html` in your browser.
