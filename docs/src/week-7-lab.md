# Week 7 Lab: First root of ``J_0(x)``

The goal of this lab is to compute the first root of the Bessel
function ``J_0(x)``.

## Motivation

This exact computation was required in a [recent
paper](https://arxiv.org/abs/2601.16285) of mine. The roots of the
Bessel functions are related to the Dirichlet eigenvalues of the
Laplacian on the unit disc. The equation the eigenvalues is

``` math
\begin{cases}
  -\Delta u = \lambda u &\text{in}\quad \mathbb{D}\\
  u = 0 &\text{on}\quad \partial\mathbb{D}
\end{cases}.
```

Using separation of variables one can show that the eigenfunctions are
given by

``` math
\psi_{n,k}(r, \theta) = J_n(j_{n,k}r) \left( A \cos(n\theta) + B \sin(n\theta) \right)
```

where ``n = 0, 1, \dots`` and ``k = 1, 2, \dots``, with associated
eigenvalues ``\lambda_{n,k} = j_{n,k}``. Here ``j_{n,k}`` is the
``k``th zero of ``J_n``. Note that ``j_{n,k}`` being a zero of ``J_n``
ensures that ``\psi_{n,k}(1, \theta) = 0`` for any ``\theta``, which
is the Dirichlet boundary condition we have.

Computing eigenvalues of the disc hence reduces to computing zeros of
the Bessel function. For the paper mentioned earlier we needed to
compute enclosures of the first two eigevalues, corresponding to
``j_{0,1}`` and ``j_{1,1}``. You can find the code used for computing
the first eigenvalue in the
[repository](https://github.com/Joel-Dahne/SpectralRegularPolygon.jl)
associated to the paper, specifically in the function `λ_disc`
(located in `src/large_N/section_2.jl`). For the second eigenvalue you
can find the code in the Pluto notebook `proofs/lemma_2_21.jl` in the
same repository. For this lab we will focus on computing ``j_{0,1}``,
i.e. the first positive root of ``J_0(x)``. Handling ``j_{1,1}``
requires a little bit extra work.

## Making a plan

Compared to previous labs, this one is less guided. There are two
associated Pluto notebooks. The notebook `lab-7.jl` contains a minimal
skeleton for you to get started, the notebook `lab-7-solution.jl`
contains a worked out solution.

The lab is based on the methods related to computing zeros of
functions that were discussed in the two previous lectures. Recall
that our goal is to compute the first positive root of the Bessel
function``J_0(x)``. You can approach this task in multiple different
ways. For the purposes of this lab it is natural to split it into
three, or possibly four, subtasks. Take a minute to think about how
you would approach this, referring to the previous two lectures if
needed. You can then compare your plan with the one given below.

!!! details "Plan"
    One can split the problem into the following four steps:

    - Step 0: Make a non-rigorous plot of ``J_0(x)`` and check where the
      first zero seems to be. Starting with a non-rigorous computation
      follows the first guideline discussed in Week 3 Lecture 1, that the
      result should be numerically obvious for you to be able to perform a
      computer-assisted proofs.
    - Step 1: Locate the zero: Following the approach of Week 7 Lecture 1
      we can compute an enclosure of the graph on the interval ``[0, b]``
      for some ``b > 0`` large enough for the interval to contain the
      first root. From this we can get an interval in which the first root
      must be contained.
    - Step 2: Prove existence and uniqueness: The goal here is to prove
      the existence and uniqueness of a root in the interval from the
      previous step. For this we can follow the approach from the first
      part of Week 7 Lecture 2 about proving existence and uniqueness.
    - Step 3: Refined the zero: Once we have proved the existence and
      uniqueness in the interval we can proceed to compute a refined
      enclosure of the zero. For this we could use either the bisection
      method or the interval Newton method, both discussed in Week 7
      Lecture 2.

Some more comments to get you started:

- To compute the `J_0(x)` function in Julia you need to load the
  `SpecialFunctions` package. The function is called `besselj0`.

  ``` @repl comment-1
  using SpecialFunctions
  besselj0(1.5)
  ```

  The function is natively supported by Arblib, but not by
  IntervalArithmetic. You can work around this by converting from
  `Interval` to `Arb`, evaluate the function and then convert back.

  ``` @repl comment-1
  using Arblib, IntervalArithmetic
  besselj0(Arb(1.5))
  x = interval(1.5)
  interval(Float64, besselj0(Arb(x)))
  ```
- You can do the computations using either Arblib or
  IntervalArithmetic. Step 1 is likely easier with IntervalArithmetic,
  Arblib doesn't have a `mince` function and there is no
  straightforward way to plot `Arb` values (I usually convert to
  `Interval` for plotting). Step 2 and 3 should work equally well with
  either backend.
- At some point you will need the derivative of ``J_0(x)``, so you
  will have to figure out what it is.
