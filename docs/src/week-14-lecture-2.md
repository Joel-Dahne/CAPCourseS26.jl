# Week 14 Lecture 2: IntervalArithmetic.jl documentation

!!! note "Remark"
    Due to travel, there is no in-class meeting for this lecture.
    These notes are therefore intended to be read outside of class.

The goal of this lecture is to take a brief look at the documentation
for the IntervalArithmetic.jl package.

A good starting point is to read through the
[Overview](https://juliaintervals.github.io/IntervalArithmetic.jl/stable/intro/).

The
[Philosophy](https://juliaintervals.github.io/IntervalArithmetic.jl/stable/philosophy/)
part of the documentation gives rationale for some of the design
decisions made in the writing of the library. This can be helpful to
understand not just how something works, but also why it is
implemented like that. Many of these design decisions are different
from Arblib.jl, for example how comparisons are handled (which we
discussed in [Week 9 Lecture
2](https://dahne.eu/CAPCourseS26.jl/dev/week-9-lecture-2/#Predicates)).

You can read about the interface between Arblib.jl and
IntervalArithmetic.jl in [this
part](https://juliaintervals.github.io/IntervalArithmetic.jl/stable/interfaces/arblib/)
of the documentation.

There are also some parts of the library we haven't talked about, such
as [Piecewise
functions](https://juliaintervals.github.io/IntervalArithmetic.jl/stable/manual/usage/#Piecewise-functions).
