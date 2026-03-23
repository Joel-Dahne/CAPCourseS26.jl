# Week 9 Lecture 1: Overview of FLINT and Arblib.jl

We have now covered many of the basic ideas in interval arithmetic and
rigorous numerics. There are, however, still lots of things we haven't
talked about. The goal of this week is to get a broad overview of all
the capabilities that FLINT/Arblib.jl and IntervalArithmetic.jl have,
starting with FLINT/Arblib.jl today.

Our primary references for today are the [FLINT documentation for real
and complex
numbers](https://flintlib.org/doc/#real-and-complex-numbers) as well
as the [Arblib.jl
documentation](https://kalmarek.github.io/Arblib.jl/stable/).

## FLINT vs Arblib.jl

Arblib.jl is a wrapper of the FLINT C-library. It doesn't implement
any functionality by itself, but simply wraps the FLINT functions in a
way that makes them convenient to use from Julia.

The Arblib.jl interface is split into two parts, a high level
interface that works well with general Julia code, and a low level
interface that gives more control. The low level interface wraps
almost all of the functionality of FLINT, whereas the high level
interface only wraps some parts of it.

## Types

So far we have primarily made use of the `Arb` type, representing a
ball with a midpoint and a radius, and the `ArbSeries` type,
representing a truncated Taylor expansion with coefficients given by
`Arb` balls. Let us take a look at the other relevant FLINT types.

There are 8 basic types in FLINT that are relevant for us. In the list
below we give both the FLINT name for the type, as well as the name
they have in Arblib.jl.

- `mag_t` / `Mag`: Low-level type used to represent the radius of an
  `Arb` ball. It's a fixed (31-bit) precision floating point that only
  supports positive numbers. It has very limited functionality by
  itself.
- `arf_t` / `Arf`: Low-level type used to represent the midpoint of an
  `Arb` ball. It's an arbitrary precision floating point. Similar to
  `Mag` it has very limited functionality by itself.
- `arb_t` / `Arb`: This is, for us, the most fundamental type. It
  consists of an `Arf` midpoint and a `Mag` radius. It implements a
  lot of functionality and, unless otherwise specified, all operations
  are fully rigorous.
- `acf_t` / `Acf`: This represents a complex number and consists of a
   pair of `Arf` values, representing the real and imaginary parts.
   Similar to `Arf` it has very limited functionality by itself.
- `acb_t` / `Acb`: This represents a complex number and consists of a
  pair of `Arb` values, representing the real and imaginary parts.
  Note that this is not a proper complex ball, but instead represents
  a rectangular region. In many cases it is however referred to as a
  complex ball. Similar to `Arb` it implements a lot of functionality
  and, unless otherwise specified, all operations are fully rigorous.
- `arb_poly_t` / `ArbPoly`: Represents a polynomial with coefficients
  given by `Arb` values. In particular this is also the type used to
  represent truncated Taylor series. Unless otherwise specified,
  operations are rigorous.
- `acb_poly_t` / `AcbPoly`: Similar to `ArbPoly`, but the coefficients
  are `Acb` values.
- `arb_mat_t` / `ArbMatrix`: Represents a matrix with coefficients
  given by `Arb` values. It implements a limited set of linear algebra
  routines, more about that later. Unless otherwise specified,
  operations are rigorous.
- `acb_mat_t` / `AcbMatrix`: Similar to `ArbMatrix`, but the
  coefficients are `Acb` values.

The `ArbSeries` type (and also the `AcbSeries` type) in Arblib.jl does
not have a direct correspondence in FLINT. It consists of an `ArbPoly`
together with an integer specifying the degree of the expansion. In
FLINT these values are kept separate, so functions will take the
polynomial and the degree as two separate arguments.

FLINT also has a type `nfloat_t` for representing n-word floating
points. This type is relatively new and has yet to be wrapped in
Arblib.jl. In general the operations with `nfloat_t` are not rigorous,
so it is also less relevant for computer-assisted proofs.

Here are some examples of constructing these types and performing
basic arithmetic on them.

``` @repl 1
using Arblib

setprecision(Arb, 64)

Mag(1)

Mag(1) + Mag(3) # Note that this is rounded upwards!

Arf(1) / Arf(3)

sin(Arf(1)) # Most functions are not implemented for Arf

Arb(1 // 3) # Arb we have already worked with a lot!

Acb(1, π)

exp(Acb(1, π))

ArbPoly([1, 2, 3])

ArbPoly([1, 2, 3])^5

AcbPoly([Acb(1, 2), Acb(3, 4), Acb(5, 6)])

AcbPoly([Acb(1, 1 // 3), Acb(3, 4), Acb(5, 6)])^2

ArbMatrix(2, 3) # Zero matrix of size 3 x 3

ArbMatrix([1 2 3; 4 5 6; 7 8 9])

ArbMatrix([1 2 3; 4 5 6; 7 8 9])^2

AcbMatrix(2, 3) # Zero matrix of size 3 x 3

AcbMatrix([1 2 (3 + 2im); 4 5 6; 7 8 9])

AcbMatrix([1 2 (3 + 2im); 4 5 6; 7 8 9])^2
```

## FLINT documentation

For each of the types discussed above, there is an associated page in
the FLINT documentation. For example, take a look at the following
pages:

- [mag.h](https://flintlib.org/doc/mag.html)
- [arf.h](https://flintlib.org/doc/arf.html)
- [arb.h](https://flintlib.org/doc/arb.html)
- [acb.h](https://flintlib.org/doc/acb.html)

## Functionality

Let us take a look at some of the functionality that FLINT implements.
Some of the most important groups are:

1. Special functions, including support for Taylor arithmetic
2. Linear algebra routines
3. Polynomial routines
4. Rigorous integration
5. Basic root finding
6. FFT

### Special functions

This is the largest class of functionality and the documentation is
spread out over many different pages. For example, the ``\zeta``
function is described in the documentation for
[arb.h](https://flintlib.org/doc/arb.html#zeta-function) and
[acb.h](https://flintlib.org/doc/acb.html#zeta-function), whereas
hypergeometric functions have their own documentation in
[acb_hypgeom.h](https://flintlib.org/doc/acb_hypgeom.html). There are
also separate modules for elliptic integrals
([acb_elliptic.h](https://flintlib.org/doc/acb_elliptic.html)),
modular forms
([acb_modular.h](https://flintlib.org/doc/acb_modular.html)) theta
functions ([acb_theta.h](https://flintlib.org/doc/acb_theta.html)) and
Dirichlet functions
([acb_dirichlet.h](https://flintlib.org/doc/acb_dirichlet.html)).

In many cases, there are implementations for direct evaluation of the
value as well as computing series expansions. For some functions,
evaluation of the series expansion is however not implemented.

The high level Arblib.jl interface wraps all functions that are also
in the Julia package
[SpecialFunctions.jl](https://github.com/JuliaMath/SpecialFunctions.jl).
FLINT does however implement many more special functions, these can
only be accessed through the low level interface.

``` @repl 1
using SpecialFunctions

gamma(Arb(0.5)) # This is accessible in the high level interface
gamma(AcbSeries((1 + 2im, 1)))

Arblib.dirichlet_lerch_phi!(Acb(), Acb(1), Acb(2), Acb(3)) # This needs the low level interface
```

### Linear algebra routines

These are documented in
[arb_mat.h](https://flintlib.org/doc/arb_mat.html) and
[acb_mat.h](https://flintlib.org/doc/acb_mat.html). It implements
solvers for linear systems (which also allows for computation of
inverses and determinants) and computation of eigenvalues.

Most of these routines are accessible from the high level interface,
though the low level interface can give more control. For eigenvalues,
only `AcbMatrix` is supported.

``` @repl 1
using LinearAlgebra

M = ArbMatrix([1 2; 3 4])
v = ArbMatrix([1, 2])
M \ v

det(M)

A = AcbMatrix(M)
eigvals(A)
```

### Polynomial routines

These are documented in
[arb_poly.h](https://flintlib.org/doc/arb_poly.html) and
[acb_poly.h](https://flintlib.org/doc/acb_poly.html). It implements
evaluation (including multipoint evaluation), composition,
interpolation and root finding.

Some of these are available from the high level interface, others
require the low level interface.

``` @repl 1
p = ArbPoly([1, 2, 3, 4])

p(Arb(1 // 3))

Arblib.compose(p, p)

Arblib.evaluate_vec_fast!(ArbVector(4), p, ArbVector([7, 8, 9, 10]))
```

### Rigorous integration

This is documented in
[acb_calc.h](https://flintlib.org/doc/acb_calc.html#integration). It
implements rigorous integration of holomorphic functions. It can deal
with non-holomorphic functions as well, but with **much** slower
convergence in the regions where they are not holomorphic.

This is available through the high level interface.

``` @repl 1
Arblib.integrate(x -> sin(exp(x)), Arb(0), Arb(8))

Arblib.integrate(x -> besselj(Acb(0), x)^2 + sin(2x), Acb(1 + im), Acb(7im))
```

Handling functions which are not meromorphic requires a bit of extra
work. The documentation of `Arblib.integrate` has more details.

### Basic root finding

This is documented in
[arb_calc.h](https://flintlib.org/doc/arb_calc.html). It implements
root finding using bisection and Newton iterations.

This is not directly accessible through either the high level or low
level interface. It requires passing functions as arguments, which
needs extra work in Julia. For my use case I primarily use similar
methods implemented in
[ArbExtras.jl](https://github.com/Joel-Dahne/ArbExtras.jl).

### FFT

This is documented in
[acb_dft.h](https://flintlib.org/doc/acb_dft.html). Most of the
documentation is very abstract, talking about discrete Fourier
transforms over general Abelian groups. But it does implement the
usual FFT with
[acb_dft](https://flintlib.org/doc/acb_dft.html#c.acb_dft).

This is only available from the low level interface. Currently the
wrapping doesn't support precomputations.

``` @repl 1
n = 16
xs = range(Arb(0), 2Arb(π), n + 1)[1:end-1]
ys = exp.(im * xs) + 3exp.(2im * xs) + 2im * exp.(3im * xs)
Arblib.dft!(AcbVector(n), AcbVector(ys))
```
