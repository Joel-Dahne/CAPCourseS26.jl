# Week 12 Lab: Some rigorous numerics

The goal of this lab is to apply some of the methods we have
learned in the course to solve some self-contained problems.

## Problem 1: Enclosing a singular integral

Our task is to compute an enclosure of the integral

``` math
I = \int_1^\infty \frac{\sin(x + \cos(x))}{x^8}\, dx
```

which is accurate to approximately 20 digits. For this, we will use
the function `Arblib.integrate`, which computes rigorous enclosures
of integrals.

However, in our case, the integral is over an infinite domain, which
`Arblib.integrate` cannot handle. Instead, we will have to split the
integral into two parts: a finite interval where we can use
`Arblib.integrate` and an infinite tail where we can compute an
explicit bound. If we let ``R > 1``, then we can split the integral as

``` math
I = \int_1^R \frac{\sin(x + \cos(x))}{x^8}\, dx + \int_R^\infty \frac{\sin(x + \cos(x))}{x^8}\, dx.
```

### Task 1: Compute an enclosure up to ``R``

Take some ``R > 1``. Your task is to compute an enclosure of

``` math
\int_1^R \frac{\sin(x + \cos(x))}{x^8}\, dx
```

using `Arblib.integrate`. You can use the following as references:

- The description of `Arblib.integrate` from Week 9 Lecture 1.
- The Julia documentation for `Arblib.integrate`. You can either read
  this directly from Julia, or in the [documentation for
  Arblib.jl](https://kalmarek.github.io/Arblib.jl/stable/interface-integration/).
- You can also read the documentation of
  [acb_calc.h](https://flintlib.org/doc/acb_calc.html#integration),
  which is the underlying Flint method.

Hint 1: `Arblib.integrate` returns an `Acb` value. Since the integral
is real-valued, you can extract the result as an `Arb` by taking the
real part of the `Acb` value.

Hint 2: If you take ``R = 10`` and print the resulting enclosure to 20
digits (using `string(res, digits = 20)`), then the last 5 digits
should be ``63152`` (or possibly ``63153`` due to rounding).

### Task 2: Compute a bound of the tail

Take some ``R > 1``. Your task is to compute a bound of

``` math
\int_R^\infty \frac{\sin(x + \cos(x))}{x^8}\, dx
```

Hint: It's useful to note that ``|\sin(x + \cos(x))| \leq 1``.

### Task 3: Combine the results

Given the enclosure from Task 1 and the bound from Task 2, compute an
enclosure of the integral ``I``. How large must ``R`` be to get 20
digits of accuracy?

Hint: The function `add_error` might be useful.

Bonus: Can you get 30 digits of accuracy? How about 40?

## Problem 2: Enclosing critical points

For this problem, our task is to enclose all critical points of the
function

``` math
f(x) = J_0(x) + \sin(2x)
```

on the interval ``[5, 10]``. This, of course, corresponds to isolating
the roots of ``f'(x)``.

### Task 1: Enclosing ``f'(x)``

Implement a function for computing ``f'(x)``. For example, you can call
this function `f_dx`.

Hint 1: To use the Bessel function, you first need to load
SpecialFunctions.jl. You can then evaluate ``J_0(x)`` with
`besselj0(x)`.

Hint 2: You can either differentiate ``f(x)`` by hand (the derivative
is fairly simple), or you can do it automatically using Taylor
arithmetic (i.e., `ArbSeries`). If you want to use Taylor arithmetic,
you first need to load ArbExtras.jl, since `ArbSeries` support for
`besselj0` is not implemented in Arblib.jl.

Hint 3: If you evaluate ``f'(7)``, you should get an enclosure given by
`[0.278157259898013021 +/- 4.44e-19]` (possibly with fewer or more
digits depending on the precision you use).

### Task 2: Isolating the roots of ``f'(x)``

Use the methods discussed in Week 7 Lecture 2 for isolating the roots
of ``f'`` on the interval ``[5, 10]``. Recall that the first step of
this is to split ``[5, 10]`` into many smaller subintervals and then
evaluate ``f'`` on each subinterval. You can then either write code to
isolate the regions with zeros, or you can look at the plot and
manually isolate them.

Your result should be a list of `Arb` values enclosing the potential
roots.

Hint 1: The example from Week 7 Lecture 2 uses IntervalArithmetic.jl
for most of the computations. However, IntervalArithmetic.jl doesn't
support Bessel functions. One option is to switch the entire approach
to use `Arb` values. Another option is to only convert to `Arb` values
when evaluating ``f'``.

Hint 2: In IntervalArithmetic.jl, an interval can be subdivided using
the `mince` function. Unfortunately, there is no similarly convenient
way to do this in Arblib.jl. The simplest approach is probably just
to run `Arb.(mince(interval(5, 10), N))`, where `N` is the number of
subintervals.

Hint 3: Similar to Week 7 Lecture 2, you will have to merge
subintervals that are adjacent to each other.

Hint 4: The function has 3 critical points on ``[5, 10]``. Therefore,
you should take enough subintervals to ensure you find three isolated
parts that are candidates for roots.

### Task 3: Prove existence and uniqueness

The next task is to prove that each root isolated in the previous step
indeed corresponds to a unique root of ``f'``. You can follow the
approach discussed in Week 7 Lecture 2 for proving existence and
uniqueness.

Hint 1: To prove uniqueness, you will need to evaluate the derivative
of the function; in this case, this means evaluating ``f''``. For
computing ``f''``, you can again either explicitly compute the
derivative or use Taylor arithmetic. Note that if you use Taylor
arithmetic, you will have to multiply the coefficient by ``2`` (more
accurately, by ``2!``) to get the second derivative! If you compute
``f''(7)``, you should get an enclosure given by `[-4.26317766808222909
+/- 1.42e-18]` (possibly with fewer or more digits depending on
precision).

Hint 2: If the enclosures you get for ``f''`` are not good enough to
conclude that the root is unique, you might have to split into smaller
subintervals when isolating the roots in the previous step.

### Bonus: Refine the enclosures

As a bonus, you can refine the enclosures of the roots using either
bisection or the interval Newton method.
