# Week 14 Lecture 1: Arblib.jl and Flint documentation

!!! note "Remark"
    Due to travel, there is no in-class meeting for this lecture.
    These notes are therefore intended to be read outside of class.

The goal with this lecture is to build a little bit of familiarity
with the documentation for Arblib.jl and Flint. Reading documentation
is usually an important part in understanding how to make use of a
library. The documentation usually contains description of the
interface, but also often times has more comments about how to make
best use of the software.

We will look at the [Arblib.jl documentation
](https://kalmarek.github.io/Arblib.jl/stable/) as well as the [Flint
documentation](https://flintlib.org/doc/#real-and-complex-numbers)
(specifically the part for real and complex numbers).

Let us start with the documentation for Arblib.jl. Unfortunately, the
documentation is lacking a big picture description of what it can do
and how you can use it. Instead it is split into two parts, one
describing the low level wrapper and one the high level interface.

Without prior familiarity with Flint, the description of the low level
interface can be a bit difficult to read.

- Take a look at the [low-level
  types](https://kalmarek.github.io/Arblib.jl/stable/wrapper-types/).
  How do these compare to the sections in the [Flint
  documentation](https://flintlib.org/doc/#real-and-complex-numbers)?
- The
  [Method](https://kalmarek.github.io/Arblib.jl/stable/wrapper-methods/)
  part of the documentation describes how the Flint functions are
  wrapped. Unfortunately, there is currently very little documentation
  on how to actually make use of this methods.

The documentation of the high level interface is slightly more
complete, though could still use some improvements. Many of these
parts we have talked about in the course. For example, compare the
[documentation of
printing](https://kalmarek.github.io/Arblib.jl/stable/printing/) with
our [Lab
6](https://dahne.eu/CAPCourseS26.jl/dev/week-6-lab/#Printing-2). Some
of them, for example the part about [Mutable
arithmetic](https://kalmarek.github.io/Arblib.jl/stable/interface-mutable/),
we haven't talked about. Some of them are closely related to the Flint
interface. You can compare the Arblib.jl [documentation for
integration](https://kalmarek.github.io/Arblib.jl/stable/interface-integration/)
with the [associated part in the Flint
documentation](https://flintlib.org/doc/acb_calc.html#integration).
