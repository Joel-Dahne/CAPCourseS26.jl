# Week 12 Lecture 2: Glimpse of some papers

!!! note "Remark"
    Due to travel, there is no in-class meeting for this lecture.
    These notes are therefore intended to be read outside of class.

This lecture covers two papers, both related to computer-assisted
proofs but otherwise very different. The first paper gives a version
of the implicit function theorem that is useful for computer-assisted
proofs. The second (very short) paper describes the rigorous numerical
integrator in Flint that we have mentioned earlier in the course.

## A constructive Implicit function theorem

The [Implicit function
theorem](https://en.wikipedia.org/wiki/Implicit_function_theorem) is
used to study equations of the form

``` math
f(x, y) = 0.
```

It essentially tells us that, under some assumptions, we can solve for
``y`` as a function of ``x``. The version with ``f : \mathbb{R}^2 \to
\mathbb{R}`` given on Wikipedia is

!!! note "Theorem (Implicit function theorem)"
    If ``f(x, y)`` is a function that is continuously differentiable in a
    neighbourhood of the point ``(x_0, y_0)``, and ``\frac{\partial
    f}{\partial y}(x_0, y_0) \not = 0``, then there exists a unique
    differentiable function ``\varphi`` such that ``y_0 = \varphi(x_0)``
    and ``f(x, \varphi(x)) = 0`` in a neighbourhood of ``x_0``.

The theorem is non-constructive, in the sense that it doesn't give us
any control over the function ``\varphi``, nor does it tell us in
which neighbourhood of ``x_0`` it is defined.

Under additional assumptions it is possible to adjust the theorem to
also get some control over ``\varphi`` and information about where it
is defined. In addition, one can (under additional assumptions) relax
it to only require that ``f(x, y)`` is small, rather than being
exactly zero.

An abstract version of such a constructive theorem for general Banach
spaces is given in the paper [Validated Saddle-Node Bifurcations and
Applications to Lattice Dynamical
Systems](https://doi.org/10.1137/16M1061011) by Evelyn Sander and
Thomas Wanner. Read through Section 2.1 of that paper. Some remarks:

- The theorem is stated in terms of general Banach spaces. For the
  course we have so far stayed in finite dimensional spaces, but some
  of the results (for example the interval Newton method) can be
  generalized to infinite dimensional spaces as well. The statement in
  the paper gives an indication of how this can be done in some
  settings.
- As an exercise you could try to reformulate the result to be
  specifically for the case ``\mathbb{R}`` and see how it compares to
  the version given above.
- You are by no means expected to fully understand the results in the
  paper, the main goal is that you should have **seen** it.

## Rigorous integration

Take a look at the paper [Numerical integration in arbitrary-precision
ball arithmetic](https://arxiv.org/abs/1806.06725) by Fredrik
Johansson (currently the main developer of Flint). It describes the
implementation of the integration in Flint. This is the method that is
used when calling `Arblib.integrate` from Julia. Some remarks:

- You can try computing some of the integrals in Table 1 yourself in
  Julia.
