# Week 13 Lecture 1: Solving in sequence space - the radii polynomial approach

A common approach in rigorous numerics for solving differential
equations is to transfer the problem from physical space to some
sequence space. There is a large literature on these type of methods,
see for example:

- [Rigorous numerics for analytic solutions of differential equations:
  the radii polynomial approach](https://doi.org/10.1090/mcom/3046)
  Allan Hungria, Jean-Philippe Lessard and J. D Mireles James (2016)
- [Rigorous Computation of Solutions of Semilinear PDEs on Unbounded
  Domains via Spectral Methods](https://doi.org/10.1137/23M1607507)
  Matthieu Cadiot, Jean-Philippe Lessard, and Jean-Christophe Nave
  (2024)
- [Constructive existence proofs and stability of stationary solutions
  to parabolic PDEs using Gegenbauer
  polynomials](https://arxiv.org/abs/2603.27198) Maxime Breden,
  Matthieu Cadiot, and Antoine Zurek (2026)

and many more. There is also a Julia package
[RadiiPolynomial.jl](https://github.com/OlivierHnt/RadiiPolynomial.jl)
for doing these type of computations.

!!! notes "Remark"
    Most of the things we have discussed in the course so far I have
    extensive practical experience with. This is not the case for the
    methods we will discuss here. While I'm familiar with the methods
    from papers and talks I don't have any practical experience with
    using them.

## Equations in sequence space

Our running example for this lecture will be the logistic equation

``` math
u'(t) = u(t)(1 - u(t)),
```

with initial data ``u(0) = 1 / 2``. See [this
example](https://olivierhnt.github.io/RadiiPolynomial.jl/stable/examples/infinite_dimensional_proofs/ode/logistic_ivp/)
in the documentation for RadiiPolynomial.jl. Our goal will be to find
a solution ``u(t)`` to this equation given in terms of a Taylor series

``` math
u(t) = \sum_{n = 0}^\infty u_n t^n.
```

Inserting this ansatz into equation we get ``u_0 = 1 / 2`` and for ``n
\geq 1`` we have the recurrence relation

``` math
nc_{n} = (u(1 - u))_{n - 1}.
```

Here ``(u(1 - u))_{n - 1}`` denotes the Taylor coefficient of index
``n - 1`` for the function ``u(1 - u)``.

To make it easier to work with these equations it is generally a good
idea to switch to some explicit sequence space. For analytic functions
a natural choice of sequence space is

``` math
\ell_\nu^1 = \{c = \{c_n\}_{n = 0}^\infty : \|c\|_\nu < \infty\},
```

with the norm

``` math
\|c\|_\nu = \sum_{n = 0}^\infty |c_n|\nu^n,
```

for some ``\nu > 0``. In this case

``` math
\sum_{n = 0}^\infty c_n t^n
```

defines an analytic function with radius of convergence at least
``\nu``. We also let ``\ast: \ell_\nu^1 \times \ell_\nu^1 \to
\ell_\nu^1`` denote the Cauchy product

``` math
a \ast b = \left\{\sum_{m = 0}^n a_{n - m}b_m\right\}_{n = 0}^\infty.
```

Note that this product corresponds to multiplication in physical space
and makes ``\ell_\nu^1`` a Banach algebra.

We can now write the logistic equation in the space ``\ell_\nu^1``.
For this we let ``F: \ell_\nu^1 \to \ell_\nu^1`` be given
component-wise by

``` math
(F(c))_n =
\begin{cases}
  c_0 - 1 / 2 & n = 0,\\
  nc_n - (c \ast (1 - c))_{n - 1} & n \geq 1.
\end{cases}
```

A zero of ``F`` then corresponds to a solution to the logistic
equation. We have thus reduced the problem of solving the ODE to
finding the zero of a mapping on the sequence space ``\ell_\nu^1``.

!!! note "Remark"
    In this example the sequence space considered was given by a
    Taylor expansion. Similar approaches can be used in other
    settings, for example for Fourier, Chebyshev or Gegenbauer
    expansions. The calculations involved do however tend to be
    simpler for Taylor expansions.

## The radii polynomial approach

We have reduced the problem to finding a zero of ``F: \ell_\nu^1 \to
\ell_\nu^1``. We have discussed how to find zeros of functions using
rigorous numerics, in this case the function is, however, posed in an
infinite space. To handle the infinite domain we will make use of a
generalization of the interval Newton method. For this we introduce
the operator ``T: \ell_\nu^1 \to \ell_\nu^1`` given by

``` math
T(c) = c - AF(c),
```

where ``A: \ell_\nu^1 \to \ell_\nu^1`` is an injective linear
operator. A zero of ``F`` then corresponds to a fixed point of ``T``.
For this to work well the operator ``A`` should be taken to be an
approximation of ``DF(\overline{c})^{-1}`` for some ``\overline{c}``
close to the zero.

The goal is then to prove the existence of a fixed point of ``T``.
This method for this is based on the [Newton-Kantorovich
theorem](https://en.wikipedia.org/wiki/Kantorovich_theorem) or, for
the formulation we will make use of here, the radii polynomial
theorem.

!!! note "Theorem (Radii Polynomial Theorem)"
    Let ``X`` be a Banach space and ``U`` an open subset of ``X``.
    Consider an operator ``T \in C^1(U, X)``, a point ``\overline{x} \in
    U`` and ``R > 0`` such that ``\text{cl}(B_R(\overline{x})) \subset U``
    (here ``\text{cl}`` denotes the closure).

    (First order) Suppose ``Y`` and ``Z_1`` satisfy

    ``` math
    \begin{align}
      \|T(\overline{x}) - \overline{x}\| &\leq Y,\\
      \sup_{x \in \text{cl}(B_R(\overline{x}))} \|DT(x)\|_{X \to X} &\leq Z_{1}.
    \end{align}
    ```

    Define the **radii polynomial** by ``p(r) = Y + (Z_1 - 1)r``. If there
    exists a radius ``r \in [0, R]`` such that ``p(r) \leq 0`` and ``Z_1 <
    1``, then ``T`` has a unique fixed-point ``x^* \in
    \text{cl}(B_R(\overline{x}))``.

    (Second order) Suppose ``Y``, ``Z_1`` and ``Z_2`` satisfy

    ``` math
    \begin{align}
      \|T(\overline{x}) - \overline{x}\| &\leq Y,\\
      \|DT(\overline{x})\|_{X \to X} &\leq Z_{1},\\
      \|DT(x) - DT(\overline{x})\|_{X \to X} &\leq Z_2 \|x - \overline{x}\|_X \text{ for all } x \in \text{cl}(B_R(\overline{x})).
    \end{align}
    ```

    Define the **radii polynomial** by ``p(r) = Y + (Z_1 - 1)r +
    \frac{Z_2}{2} r^2``. If there exists a radius ``r \in [0, R]`` such
    that ``p(r) \leq 0`` and ``Z_1 + Z_2 r < 1``, then ``T`` has a unique
    fixed-point ``x^* \in \text{cl}(B_R(\overline{x}))``.

!!! note "Remark"
    For the approach to work ``Y`` needs to be small. This means that the
    point ``\overline{x}`` should be a good approximation of a fixed
    point.

    If ``T \in C^2(X, X)``, then the last bound for the second order
    version can be replaced with

    ``` math
    \sup_{x \in \text{cl}(B_R(\overline{x}))} \|D^2T(x)\|_{X \to X} \leq Z_{2}.
    ```

## Applying the radii polynomial approach

To apply the radii polynomial approach to our problem we need to:

1. Compute an approximate solution ``\overline{c} =
   \{\overline{c}_n\}_{n = 0}^\infty``.
2. Compute an approximate inverse ``A`` of ``DF(\overline{c})``.
3. Compute bounds for ``Y``, ``Z_1`` and ``Z_2``.

In the next lecture we will look closer at how to do this.
