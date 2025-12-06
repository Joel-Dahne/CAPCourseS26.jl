# Topics course in computer-assisted proofs Spring 2026
This website, together with the [associated
repository](https://github.com/Joel-Dahne/CAPCourseS26.jl), contains
the material for a topics course in computer-assisted proofs and
rigorous numerics given at University of Minnesota Spring 2026.

The general idea of computer-assisted proofs (in analysis), is to
build on the massive success of numerical methods in applied
mathematics and other sciences and apply them also for mathematical
proofs. Classical numerical methods are however not suitable for
direct use in proofs, since they introduce errors (rounding and
discretization errors). These errors hinder their use in proofs, which
require fully rigorous arguments. The area of **rigorous numerics**
tackles these issues by introducing methods to control the errors in a
fully rigorous way, that allows for the results to be used in proofs.

An early, and by now classical, example of a computer-assisted proof
is the [proof of the existence of the Lorenz
attractor](https://doi.org/10.1016/s0764-4442(99)80439-x) in 1999 by
Tucker. Over the more than two decades since Tucker's proof, there has
been an increase in the adoption of computer assisted proofs in
analysis. An example of a recent breakthrough result building on
computer-assisted proofs is the [proof of blowup for the 3D Euler
equation](https://arxiv.org/abs/2305.05660). **TODO: Expand on this**

The course is split into 3 parts distributed over 15 weeks. The 3
parts are

1. Introduction to computer-assisted proofs (≈ Week 1-4)
2. Introduction to rigorous numerics (≈ Week 5-10)
3. Computer-assisted proofs in practice (≈ Week 11-15)

A rough schedule for the first two parts is given below, the precise
details for the third part are yet to be determined.

| Week | Topic                                    |
|------|------------------------------------------|
| 1    | Introduction to computer-assisted proofs |
| 2    | Discrete problems                        |
| 3    | Continuous problems                      |
| 4    | Formal proofs                            |
| 5    | Floating points and interval arithmetic  |
| 6    | Floating points and interval arithmetic  |
| 7    | Basic rigorous numerics                  |
| 8    | Automatic differentiation                |
| 9    | Improved rigorous numerics               |
| 10   | Improved rigorous numerics               |
| 11   | TBD                                      |
| 12   | TBD                                      |
| 13   | TBD                                      |
| 14   | TBD                                      |
| 15   | TBD                                      |

## Part 1: Introduction to computer-assisted proofs
The first part of the course will be a general introduction to
computer-assisted proofs, from the point of view of rigorous numerics.
We will consider both discrete problems, such as the proof of the
[Four color
theorem](https://en.wikipedia.org/wiki/Four_color_theorem), and
continuous problems, such as the proof of existence of the [Lorenz
attractor](https://en.wikipedia.org/wiki/Lorenz_system).

Computer-assisted proofs are often mixed up with formal proofs, such
as those produced by [Lean](https://lean-lang.org) and
[Rocq](https://rocq-prover.org/about) (previously known as Coq),
indeed some authors use the term computer-assisted proofs to refer to
either. We will take a brief look at formal proofs, with a focus on
the differences and similarities between formal proofs and
computer-assisted proofs.

## Part 2: Introduction to rigorous numerics
The second part focuses on the machinery required for constructing
computer-assisted proofs in analysis, known as **rigorous numerics**.
This introduction will be partially based on the book [Validated
Numerics](https://press.princeton.edu/books/hardcover/9780691147819/validated-numerics)
by Warwick Tucker. At the heart of rigorous numerics lies **interval
arithmetic**, indeed the field of rigorous numerics is sometimes just
referred to as interval arithmetic.

The practical parts will primarily be done in
[Julia](https://julialang.org), using the packages
[Arblib.jl](https://github.com/kalmarek/Arblib.jl) and
[IntervalArithmetic.jl](https://github.com/JuliaIntervals/IntervalArithmetic.jl)
as the base for the interval arithmetic.

Here is an example of how interval arithmetic looks like in practice,
here using IntervalArithmetic.jl.

``` @repl
using IntervalArithmetic
a = interval(1, 2) # The interval [1, 2]
a^2 # Interval gotten from squaring all numbers in [1, 2]
sin(a) # Interval gotten from applying sin to all numbers in [1, 2]
```

The content we will cover includes:

- **Mathematical foundations of floating point arithmetic:** floating
  point formats, rounding
- **Basics of interval arithmetic:** basic arithmetic, elementary
  functions, special functions
- **Basic rigorous numerics:** isolating roots, computing integrals,
  enclosing extrema
- **Automatic differentiation:** forward (and backwards)
  differentiation, Taylor arithmetic
- **Improved rigorous numerics:** isolating roots, computing
  integrals, enclosing extrema


## Part 3: Computer-assisted proofs in practice
In the third and final part of the course we will look at what it
takes to go from what we have learned about interval arithmetic and
rigorous numerics to actually creating a computer-assisted proof. The
list of topics covered would depend on the interests of the
participants in the course. Possible topics would include the use of
computer-assisted proofs in:

- Spectral geometry
- Dynamical systems
- Fluid mechanics
- Analytic combinatorics

One could also dive deeper into different algorithms for
computer-assisted proofs:

- Rigorous integration of ODEs
- Finite element methods
- Spectral methods
- Physics-Informed Neural Networks (PINNs)

Alternatively, one can study the lower level details of interval
arithmetic, more related to the field of computer algebra.
