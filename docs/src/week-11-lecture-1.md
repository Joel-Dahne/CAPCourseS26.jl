# Week 11 Lecture 1: Self-similar blowup - Enclosing ``Q_0``

Last week we started looking at the paper [Self-Similar Singular
Solutions to the Nonlinear Schrödinger and the Complex Ginzburg-Landau
Equations](https://arxiv.org/abs/2410.05480).

During the lecture we discussed how proving the existence of a
self-similar solution could be reduced to proving that a function

``` math
G(\mu, \gamma, \kappa) = \left(
  Q_{0}(\mu, \kappa; \xi_{1}) - Q_{\infty}(\gamma, \kappa; \xi_{1}),
  Q_{0}'(\mu, \kappa; \xi_{1}) - Q_{\infty}'(\gamma, \kappa; \xi_{1})
\right)
```

had a zero. Here ``Q_0`` was a solution satisfying the boundary
conditions at zero and ``Q_\infty`` was a solution satisfying the
boundary conditions at infinity.

For the lab we set up (most of) the machinery to prove the existence
of a root of ``G`` using the interval Newton method. What we did not
do was to discuss how to actually compute ``Q_0`` and ``Q_\infty``.
The functions that were left to implement were

``` julia
function Q_zero(μ::Arb, κ::Arb, ξ₁::Arb)
	# FIXME: Implement this
    zero(SVector{2,Acb})
end

function Q_zero_jacobian(μ::Arb, κ::Arb, ξ₁::Arb)
	# FIXME: Implement this
    return zero(SMatrix{2,2,Acb})
end

function Q_infty(γ::Acb, κ::Arb, ξ₁::Arb)
	# FIXME: Implement this
    return zero(SVector{2,Acb})
end

function Q_infty_jacobian(γ::Acb, κ::Arb, ξ₁::Arb)
	# FIXME: Implement this
    return zero(SMatrix{2,2,Acb})
end
```

Apart from these four functions, everything else was rigorously
implemented. Though it should be noted the vector `x` that serves as
the initial box on which the interval Newton operator is applied might
need some tuning to work.

During this lecture we will discuss how to implement the functions
`Q_zero` and `Q_zero_jacobian`. In the next lecture we will take a
look at `Q_infty` and `Q_infty_jacobian`.

## Splitting into real and imaginary parts

Recall that ``Q_0`` is the (unique) solution to the initial value
problem

``` math
\begin{split}
  (1 - i\epsilon)\left(Q_{0}'' + \frac{d - 1}{\xi}Q_{0}'\right) + i\kappa\xi Q_{0}'
  + i \frac{\kappa}{\sigma}Q_{0} - \omega Q_{0} + (1 + i\delta)|Q_{0}|^{2\sigma}Q_{0}
  &= 0,\\
  Q_{0}(0) &= \mu,\\
  Q_{0}'(0) &= 0.
\end{split}
```

Since the non-linearity has an absolute value it is beneficial to
split into real and imaginary parts. If we let ``Q_0(\xi) = a(\xi) +
ib(\xi)`` we can write the above ODE as

``` math
\begin{align*}
  a'' + \epsilon b'' + \frac{d - 1}{\xi}(a' + \epsilon b') - \kappa \xi b' - \frac{\kappa}{\sigma}b - \omega a + (a^{2} + b^{2})^{\sigma}a - \delta(a^{2} + b^{2})^{\sigma}b &= 0,\\
  b'' - \epsilon a'' + \frac{d - 1}{\xi}(b' - \epsilon a') + \kappa \xi a' + \frac{\kappa}{\sigma}a - \omega b + (a^{2} + b^{2})^{\sigma}b + \delta(a^{2} + b^{2})^{\sigma}a &= 0,
\end{align*}
```

with initial conditions ``a(0) = \mu``, ``b(0) = 0`` and ``a'(0) =
b'(0) = 0``.

For ``\xi > 0`` this ODE is well behaved and we can use existing
libraries for rigorous integration of ODEs for enclosing the solution.
However, at ``\xi = 0`` the equation has a removable singularity. As
common for interval arithmetic, this removable singularity will
require some semi-manual work. For this reason we split the interval
``[0, \xi_1]`` into two intervals, ``[0, \xi_0]`` and ``[\xi_0,
\xi_1]``. On ``[0, \xi_0]`` we will enclose the solution using a
Taylor series expansion at zero. This solution can then be continued
on the interval ``[\xi_0, \xi_1]`` using a rigorous numerical
integrator.

## Handling the removable singularity at zero

The point ``\xi = 0`` is a regular singular point. One can
systematically study the behavior of the solutions around this point
using the [Frobenius
method](https://en.wikipedia.org/wiki/Frobenius_method). However, for
our purposes we will just make the ansatz that ``a`` and ``b`` are
given by the Taylor expansions ``a = \sum_{n = 0}^{\infty}
a_{n}\xi^{n}`` and ``b = \sum_{n = 0}^{\infty} b_{n}\xi^{n}``. By
inserting this ansatz into the equation and solving for the
coefficients one gets

``` math
a_{n + 2} = \frac{F_{1,n} - \epsilon F_{2,n}}{(n + 2)(n + d)(1 + \epsilon^{2})},\quad
b_{n + 2} = \frac{\epsilon F_{1,n} + F_{2,n}}{(n + 2)(n + d)(1 + \epsilon^{2})}
```

with

``` math
\begin{align*}
  F_{1,n} &= \kappa n b_{n} + \frac{\kappa}{\sigma}b_{n} + \omega a_{n} - u_{1,n} + \delta u_{2,n},\\
  F_{2,n} &= -\kappa n a_{n} - \frac{\kappa}{\sigma}a_{n} + \omega b_{n} - u_{2,n} - \delta u_{1,n}.
\end{align*}
```

Here

``` math
u_{1,n} = \left((a^{2} + b^{2})^{\sigma}a\right)_{n} \text{ and }
u_{2,n} = \left((a^{2} + b^{2})^{\sigma}b\right)_{n}.
```

Using the above recursion with ``a_{0} = \mu``, ``b_{0} = 0`` and
``a_{1} = b_{1} = 0`` it is straightforward to compute Taylor
expansions of arbitrarily high order.

However, to get rigorous enclosures, it does not suffice to just
compute truncated Taylor series. We have to also bound the remainder
term. For this we need some sort of bound on the tail of the series.
In this case, one can show that for sufficiently large ``N`` we have
for ``n > N`` that

``` math
|a_{n}|, |b_{n}| \leq r^{n}
```

for some ``r < 1``. With this bound we can bound the remainder term
for ``0 < \xi < \frac{1}{r}`` as

``` math
\left|\sum_{n = N + 1}^{\infty} a_{n}\xi^{n}\right|,
\left|\sum_{n = N + 1}^{\infty} b_{n}\xi^{n}\right|
\leq \sum_{n = N + 1}^{\infty}(r\xi)^{n}
= \frac{(r\xi)^{N + 1}}{1 - r\xi}.
```

Similarly we can bound the remainder term for the derivative as

``` math
\left|\frac{d}{d\xi}\left(\sum_{n = N + 1}^{\infty} a_{n}\xi^{n}\right)\right|
= \left|\sum_{n = N + 1}^{\infty} na_{n}\xi^{n - 1}\right|
\leq \frac{1}{\xi}\sum_{n = N + 1}^{\infty}n(r\xi)^{n}
= \frac{(r\xi)^{N}(N + 1 - Nr\xi)}{(1 - r\xi)^{2}},
```

with an identical bound for ``b``.

To prove the bound ``|a_{n}|, |b_{n}| \leq r^{n}`` we have the
following lemma. We here specialize to the case ``\sigma = 1``, since
otherwise handling the non-linearity is more difficult.

!!! note "Lemma"

    Let ``\sigma = 1``. Let ``M``, ``N``, ``C`` and ``r`` be such that
    ``N`` is even, ``3M < N``,

    ``` math
    |a_n|, |b_n| \leq C r^n \text{ for } n < M
    ```

    and

    ``` math
    |a_n|, |b_n| \leq r^n \text{ for } M \leq n \leq N.
    ```

    If

    ``` math
    \frac{1 + |\epsilon|}{1 + \epsilon^{2}}\left(
      \frac{|\kappa|}{N + d} + \frac{|\omega|}{(N + 2)(N + d)} + (1 + |\delta|)\left(1 + \frac{6MC^3}{N + d}\right)
    \right) \leq r^2
    ```

    then

    ``` math
    |a_{n}|, |b_{n}| \leq r^{n} \text{ for } n > N.
    ```

We won't go through the proof in detail here, see Lemma 8.1 in the
paper. By induction it reduces the problem to verifying

``` math
|a_{N + 2}|, |b_{N + 2}| \leq r^{N + 2}.
```

The most technical part of the proof is getting bounds for the
non-linearity.

Unfortunately we are not quite done here. While this does give us
control over ``Q_0``, we also need to control the derivatives with
respect to ``\mu`` and ``\kappa``. This essentially boils down to
differentiating the ODE with respect to ``\mu`` and ``\kappa``
respectively and then performing the same analysis as above.

We won't go into the details now, but for the purposes of the next lab
let us nevertheless include some of the final equations. Let us denote
the Taylor expansions of the derivatives by

``` math
a_\mu = \sum_{n = 0}^{\infty} a_{\mu,n}\xi^{n},\quad
b_\mu = \sum_{n = 0}^{\infty} b_{\mu,n}\xi^{n},\quad
a_\kappa = \sum_{n = 0}^{\infty} a_{\kappa,n}\xi^{n} \text{ and }
b_\kappa = \sum_{n = 0}^{\infty} b_{\kappa,n}\xi^{n}.
```

We then get

``` math
a_{\mu,n + 2} = \frac{F_{\mu,1,n} - \epsilon F_{\mu,2,n}}{(n + 2)(n + d)(1 + \epsilon^{2})},\quad
b_{\mu,n + 2} = \frac{\epsilon F_{\mu,1,n} + F_{\mu,2,n}}{(n + 2)(n + d)(1 + \epsilon^{2})},
```

and

``` math
a_{\kappa,n + 2} = \frac{F_{\kappa,1,n} - \epsilon F_{\kappa,2,n}}{(n + 2)(n + d)(1 + \epsilon^{2})},\quad
b_{\kappa,n + 2} = \frac{\epsilon F_{\kappa,1,n} + F_{\kappa,2,n}}{(n + 2)(n + d)(1 + \epsilon^{2})}
```

with

``` math
\begin{align*}
  F_{\mu,1,n} &= \kappa n b_{\mu,n} + \frac{\kappa}{\sigma}b_{\mu,n} + \omega a_{\mu,n} - u_{\mu,1,n} + \delta u_{\mu,2,n},\\
  F_{\mu,2,n} &= -\kappa n a_{\mu,n} - \frac{\kappa}{\sigma}a_{\mu,n} + \omega b_{\mu,n} - u_{\mu,2,n} - \delta u_{\mu,1,n},
\end{align*}
```

and

``` math
\begin{align*}
  F_{\kappa,1,n} &= \kappa n b_{\kappa,n} + n b_{n} + \frac{\kappa}{\sigma}b_{\kappa,n} + \frac{1}{\sigma}b_{n} + \omega a_{\kappa,n} - u_{\kappa,1,n} + \delta u_{\kappa,2,n},\\
  F_{\kappa,2,n} &= -\kappa n a_{\kappa,n} -n a_{n} - \frac{\kappa}{\sigma}a_{\kappa,n} - \frac{1}{\sigma}a_{n} + \omega b_{\kappa,n} - u_{\kappa,2,n} - \delta u_{\kappa,1,n}.
\end{align*}
```

Here

``` math
\begin{align*}
  u_{\mu,1,n}
  &= \left(
    (a^{2} + b^{2})^{\sigma}a_{\mu}
    + 2\sigma(a^{2} + b^{2})^{\sigma - 1}a^{2}a_{\mu}
    + 2\sigma(a^{2} + b^{2})^{\sigma - 1}abb_{\mu}
    \right)_{n},\\
  u_{\mu,2,n}
  &= \left(
    (a^{2} + b^{2})^{\sigma}b_{\mu}
    + 2\sigma(a^{2} + b^{2})^{\sigma - 1}aba_{\mu}
    + 2\sigma(a^{2} + b^{2})^{\sigma - 1}b^{2}b_{\mu}
    \right)_{n}
\end{align*}
```

and

``` math
\begin{align*}
  u_{\kappa,1,n}
  &= \left(
    (a^{2} + b^{2})^{\sigma}a_{\kappa}
    + 2\sigma(a^{2} + b^{2})^{\sigma - 1}a^{2}a_{\kappa}
    + 2\sigma(a^{2} + b^{2})^{\sigma - 1}abb_{\kappa}
    \right)_{n},\\
  u_{\kappa,2,n}
  &= \left(
    (a^{2} + b^{2})^{\sigma}b_{\kappa}
    + 2\sigma(a^{2} + b^{2})^{\sigma - 1}aba_{\kappa}
    + 2\sigma(a^{2} + b^{2})^{\sigma - 1}b^{2}b_{\kappa}
    \right)_{n}.
\end{align*}
```

To bound the remainder terms we in this case have the lemmas

!!! note "Lemma"

    Let ``\sigma = 1``. Let ``M``, ``N``, ``C`` and ``r`` be such that
    ``N`` is even, ``3M < N``,

    ``` math
    |a_{n}|, |b_{n}|, |a_{\mu,n}|, |b_{\mu,n}| \leq C r_{\mu}^n \text{ for } n < M
    ```

    and

    ``` math
    |a_{n}|, |b_{n}|, |a_{\mu,n}|, |b_{\mu,n}| \leq r_{\mu}^n \text{ for } M \leq n \leq N.
    ```

    If

    ``` math
    \frac{1 + |\epsilon|}{1 + \epsilon^{2}}\left(\frac{|\kappa|}{N + d} + \frac{|\omega|}{(N + 2)(N + d)} + 3(1 + |\delta|)\left(1 + \frac{6MC^3}{N + d}\right)\right) \leq r_{\mu}^2
    ```

    then

    ``` math
    |a_{\mu,n}|, |b_{\mu,n}| \leq r_{\mu}^{n} \text{ for } n > N.
    ```

and

!!! note "Lemma"

    Let ``\sigma = 1``. Let ``M``, ``N``, ``C`` and ``r`` be such that
    ``N`` is even, ``3M < N``,

    ``` math
    |a_{n}|, |b_{n}|, |a_{\kappa,n}|, |b_{\kappa,n}| \leq C r_{\kappa}^n \text{ for } n < M
    ```

    and

    ``` math
    |a_{n}|, |b_{n}|, |a_{\kappa,n}|, |b_{\kappa,n}| \leq r_{\kappa}^n \text{ for } M \leq n \leq N.
    ```

    If

    ``` math
    \frac{1 + |\epsilon|}{1 + \epsilon^{2}}\left(\frac{|\kappa| + 1}{N + d} + \frac{|\omega|}{(N + 2)(N + d)} + 3(1 + |\delta|)\left(1 + \frac{6MC^3}{N + d}\right)\right) \leq r_{\kappa}^2
    ```

    then

    ``` math
    |a_{\kappa,n}|, |b_{\kappa,n}| \leq r_{\kappa}^{n} \text{ for } n > N.
    ```

## Rigorous integration away from zero

We are interested in integrating ``Q_0`` from ``\xi_0`` (where the
initial data is computed using the Taylor expansion discussed above)
to ``\xi_1``. In this case we have a compact interval and as long as
``a^2 + b^2`` is non-zero all parts of the ODE are perfectly smooth
with no removable singularities to handle. This is a favorable
situation and there are many existing methods for rigorously computing
solutions.

### CAPD

The method used in the paper is based on the [CAPD
library](https://github.com/CAPDGroup/CAPD). It's a C++ library
developed primarily by a group in Krakow and it has been around for
quite some time (early versions seem to be from 1990s). There is a
somewhat recent [paper](https://doi.org/10.1016/j.cnsns.2020.105578)
describing some of the functionality of the library.

The method (at least the one used for our purposes) is based on Taylor
arithmetic. At each step, a truncated Taylor expansion is computed
together with a bound for the remainder on some interval. This can
then be used to compute the solution at a slightly later point. For
this to work well, in particular in more than one dimension, you have
to be very careful with how you represent your interval enclosures.

Applying this to our ODE doesn't require much more than a 100 lines of
code. The only thing you really need to do is to write down the
equation you are solving as a system of first order ODEs. The library
is even able to automatically compute derivatives with respect to
parameters, so the derivatives with respect to ``\mu`` and ``\kappa``
can be computed with almost no extra code. However, since using the
library requires compiling and running C++ code it is outside of the
scope of this course.

### Spectral methods

Another common method for rigorous integration of ODEs is spectral
methods. In this case you write the solution in some basis, e.g.
Fourier or Chebyshev, and you get a system of equations for the
coefficients. This gives you an infinite system of equations that you
need to solve. This infinite system is then split into a finite part
and an infinite tail. On the tail you prove that the coefficients have
some specified decay and the finite part you handle numerically.

I don't have any personal experience with these methods, so I don't
have a good feeling for how much work they require to implement nor
how they perform. In principle they are simpler than the integrator
used by CAPD, but it seems like they require more work to adapt to
specific problems. If you are implementing it from scratch it would
therefore likely be easier than implementing CAPD from scratch, but
they might require more work than just using the already existing CAPD
library.

Some references:

Fourier:
- [Rigorous numerics for analytic solutions of differential equations:
  the radii polynomial approach](https://doi.org/10.1090/mcom/3046)
  (2016)
- [Introduction to rigorous numerics in dynamics: general functional
  analytic setup and an example that forces
  chaos](https://www.math.vu.nl/~janbouwe/pub/introrignumdyn.pdf)
  (2017)

Chebyshev:
- [Rigorous Numerics for Nonlinear Differential Equations Using
  Chebyshev Series](https://doi.org/10.1137/13090883X)  (2014)
- [Rigorous numerics for ODEs using Chebyshev series and domain
  decomposition](https://doi.org/10.3934/jcd.2021015) (2021)

Gegenbauer:
- [Constructive existence proofs and stability of stationary solutions
  to parabolic PDEs using Gegenbauer
  polynomials](https://arxiv.org/abs/2603.27198) (2026)
