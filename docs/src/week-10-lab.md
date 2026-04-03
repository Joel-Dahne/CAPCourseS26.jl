# Week 10 Lab: Self-similar blowup

The goal of this lab is to start on the implementation of a
computer-assisted proof for self-similar blowup scenario for the CGL
equation discussed in the last lecture. The paper itself,
[Self-Similar Singular Solutions to the Nonlinear Schrödinger and the
Complex Ginzburg-Landau Equations](https://arxiv.org/abs/2410.05480),
might be useful as a reference in some cases.

## Setup

Recall from last lecture that proving the existence of self-similar
blowup reduces to proving the existence of a solution to the second
order non-linear ODE

``` math
(1 - i\epsilon)\left(Q'' + \frac{d - 1}{\xi}Q'\right) + i\kappa\xi Q'
+ i \frac{\kappa}{\sigma}Q - \omega Q + (1 + i\delta)|Q|^{2\sigma}Q
= 0,
```

with appropriate boundary conditions at zero and infinity.

Using a shooting method approach we introduced the function

``` math
G(\mu, \gamma, \kappa) = \left(
  Q_{0}(\mu, \kappa; \xi_{1}) - Q_{\infty}(\gamma, \kappa; \xi_{1}),
  Q_{0}'(\mu, \kappa; \xi_{1}) - Q_{\infty}'(\gamma, \kappa; \xi_{1})
\right),
```

with ``Q_0`` and ``Q_\infty`` corresponding to solutions satisfying
the boundary conditions at zero and infinity respectively. Proving the
existence of a solution satisfying both boundary conditions then
reduces to proving the existence of a zero of ``G``.

To apply this approach we need to implement an interval arithmetic
version of ``G`` as well as a several-dimensional version of the
interval Newton method to rigorously prove the existence of a zero.
The aim of this lab is to implement a skeleton for this setup. We
won't have the time to properly implement rigorous evaluation of
``Q_0`` or ``Q_\infty``, that will be the content of future
discussions.

## Overview of implementation

A very rough outline of the implementation is given in `lab-10.jl` in
the `notebooks` directory. We will start to fill in parts of this
outline.

For the purposes of this lab we will use the parameters

``` math
\epsilon = 0,\
\delta = 0,\
\sigma = 1,\
d = 3,\
\omega = 1.
```

To simplify the implementation we will hard-code these values in the
code whenever they are used. When looking for a zero of ``G`` we will
use ``\xi_1 = 60`` and the approximate zero ``(\mu_0, \gamma_0,
\kappa_0) = (1.88565, 1.71360 - 1.49179i, 0.91735)`` as an initial
guess.

We split the implementation into four parts

1. Implementation of ``Q_0``
2. Implementation of ``Q_\infty``
3. Implementation of ``G``
4. Implementation of interval Newton

The first part will be to implement a skeleton for the full
computation. For this first step, our implementations of ``Q_0`` and
``Q_\infty`` will simply return zero. The goal will be to get a proper
implementation of everything else. We will follow roughly the
following order:

1. Skeletons of ``Q_0`` and ``Q_\infty``
2. Implementation of ``G``
9. Start implementing interval Newton
3. Skeletons of Jacobian of ``Q_0`` and ``Q_\infty``
4. Implementation of Jacobian of ``G``
5. Finish implementing interval Newton

An important part of the implementation at this point will be to
figure out (and decide) what the input arguments and the type of the
outputs of the functions should be.

The next step is to properly implement ``Q_0`` and ``Q_\infty``, as
well as their Jacobians. If we have time we will start to look at
this. To begin with we will implement non-rigorous version of the
functions, then discuss what is needed to make this fully rigorous.
