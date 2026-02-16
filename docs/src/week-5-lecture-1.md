# Week 5 Lecture 1: Floating point numbers

This lecture marks the start of our study of rigorous numerics, which
will continue for six weeks. On a high level, these weeks are divided
into five parts.

1. **Mathematical foundations of floating point arithmetic:** floating
   point formats, rounding
2. **Basics of interval arithmetic:** basic arithmetic, elementary
   functions, special functions
3. **Basic rigorous numerics:** isolating roots, computing integrals,
   enclosing extrema
4. **Automatic differentiation:** forward (and backwards)
   differentiation, Taylor arithmetic
5. **Improved rigorous numerics:** isolating roots, computing
   integrals, enclosing extrema

We will start with the basics, floating point numbers, and
progressively work our way up to how rigorous numerics can be used to
solve problems. At every stage we will make sure that we understand
how the computer can perform these computations in a rigorous way.

## Floating point numbers

In rigorous numerics one usually works primarily with intervals and
interval arithmetic, in fact the field of rigorous numerics is often
referred to as just interval arithmetic. The underlying basis of
interval arithmetic is however floating points. To fully understand
how interval arithmetic works we therefore have to start by
understanding how floating point numbers work. For this we will look
at:

- The mathematical definition of floating point numbers
- Actual implementation of floating points
- Arithmetic with floating point numbers
- Rounding

## Definition of floating point numbers

There are several different versions of floating point numbers,
depending on the precise use case. Let us start with the most
mathematical definition.

!!! note "Floating point number"
    A binary floating point number is a rational number of the form
    ``x \cdot 2^y`` where ``x, y \in \mathbb{Z}`` and ``x`` is odd, or
    one of the special values zero, plus infinity, negative infinity
    or NaN (not-a-number).

We use the notation ``\mathbb{F}`` for the set of floating point
numbers, i.e.

``` math
\mathbb{F} = \{x \cdot 2^y: x, y \in \mathbb{Z}, x\ \text{odd}\} \cup \{0, \infty, -\infty, \text{NaN}\}
```

There are a number of equivalent ways of representing a floating
point. Apart from ``x \cdot 2^y`` used above the two most common ones
are

1. ``m \cdot 2^e`` with ``1 \leq |m| < 2``
2. ``m' \cdot 2^{e'}`` with ``0.5 \leq |m'| < 1``

The first one is arguably the most common format and in this case
``m`` is called the mantissa and ``e`` the exponent. Depending on the
context mantissa and exponent could also be used to refer to ``x`` and
``y`` or ``m'`` and ``e'``.

Generally we consider floating points of a specified precision ``p``.
The set of floating point numbers of precision ``p`` is

``` math
\mathbb{F}_p = \{x \cdot 2^y: x, y \in \mathbb{Z}, 1 \leq x < 2^p, x\ \text{odd}\} \cup \{0, \infty, -\infty, \text{NaN}\}.
```

If we write the mantissa in binary it is then of the form

``` math
m = \pm 1.b_1 b_2 \dots b_{p-1}
```

Note that we only need ``p - 1`` bits to store the mantissa since the
first digit is implicitly defined to be a one. In the ``x \cdot 2^y``
representation we also only need ``p - 1`` bits to store ``x`` since
it is always odd and we therefore don't have to store the last bit.

The set ``\mathbb{F}_p`` corresponds to the type `arf` in Flint. In
Julia we can get the representations ``m \cdot 2^e`` using
`significand` and `exponent` and the representation ``m' \cdot
2^{e'}`` using `frexp`.

``` @repl
using Arblib
f = Arf(3 * 2^4)
significand(f), exponent(f)
frexp(f)
```

Most floating point types are however more restrictive than `arf`.
They generally also put restrictions on the range of the exponent.
They correspond to the set

``` math
\mathbb{F}_{p,\check{y},\hat{y}} = \{x \cdot 2^y: x, y \in \mathbb{Z}, 1 \leq x < 2^p, x\ \text{odd}, \check{y} \leq y \leq \hat{y}\} \cup \{0, \infty, -\infty, \text{NaN}\}.
```

Usually the bounds for the exponent are given in terms of ``e``. For
example for `BigFloat` they are ``-2^{62} \leq e \leq 2^{62} - 2`` and for
`Float64` they are ``-1022 \leq e \leq 1023``. We can find this using
Julia as

``` @repl
exponent(floatmax(BigFloat))
2^62 - 2
exponent(floatmin(BigFloat))
-2^62
exponent(floatmax(Float64))
exponent(floatmin(Float64))
```

The definitions we have gone through so far are enough for our study
of floating point numbers. Many common floating point types, primarily
`Float64`, do however have a few more details that in some cases are
important:

- **Signed zero:** The value zero can also have a sign, meaning that
  `0` and `-0` are distinct values. This is useful in some cases, but
  mathematically it can give some odd behavior. We will in general not
  consider signed zeros.

  ``` @repl
  0.0
  -0.0
  0.0 == -0.0
  isequal(0.0, -0.0)
  ```

- **Subnormal numbers:** In general the mantissa satisfies ``1 \leq
  |m| < 2``. For the numbers closest to zero it however allows
  representations where ``|m| < 1``. We won't care about this at all.
- **NaN with payload:** The NaN values can have extra data associated
  with them. This is for example used in the R programming language to
  represent missing values. We won't care about this at all.

Note that the `Arf` floating point type does not support any of these
things.

## The "field" of floating point numbers and rounding

We now know what floating point numbers are, the next step is to be
able to do computations on floating point numbers. In this lecture we
will focus on basic arithmetic, i.e. addition, subtraction,
multiplication and division. In the next lecture we will look at
powers and elementary functions.

Except for the special values ``\pm \infty`` and NaN, floating point
numbers are a subset of the rational numbers. We therefore have a
natural definition for what it means to add, subtract, multiply and
divide floating point numbers with each other. There is however a
problem, the set of floating point numbers is not closed under these
operations.

!!! note "Example"
    Consider the floating point numbers ``a = 3 \cdot 2^0`` and ``b =
    5 \cdot 2^0`` in the set ``\mathbb{F}_3``. We have

    ``` math
    c = a \cdot b = 15 \cdot 2^0.
    ```

    But ``15 \cdot 2^0`` is not in the set ``\mathbb{F}_3`` since ``15 > 2^3``.

To fix this problem we have to introduce the concept of rounding.

### Rounding

A rounding function is a function

``` math
\bigcirc: \mathbb{R} \to \mathbb{F}_{p}
```

To be a proper rounding function it should satisfy

1. ``\bigcirc(x) = x`` for ``x \in \mathbb{F}_{p}``
2. ``\bigcirc(x) \leq \bigcirc(y)`` if ``x \leq y``

We will look at three different versions of rounding:

1. Round down: ``\nabla(x)``
2. Round up: ``\Delta(x)``
3. Round to nearest (even): ``\square(x)``

The round down and up are defined by

- ``\nabla(x) = \max \{y \in \mathbb{F}_{p}: y \leq x\}``
- ``\Delta(x) = \min \{y \in \mathbb{F}_{p}: y \geq x\}``

That is, they return the floating point number just below or just
above ``x``. Round to nearest on the other hand returns the floating
point number closest to ``x``, with ties being rounded to the one of
two which has a 0 in the last digit of the mantissa.

For general use round to nearest is the by far most common rounding
mode to use. For the specific purposes of interval arithmetic round up
and round down will however be very important.

!!! note
    The rounding function implicitly depends on the precision ``p`` of
    the set we are rounding into. In some cases one might want to use
    the notation ``\bigcirc_p`` to make this dependency explicit.

### Arithmetic with rounding

With our new rounding functions we can now define arithmetic on
floating points!

When adding two floating point numbers ``x, y \in \mathbb{F}_p`` under
the rounding mode ``\bigcirc`` the result is given by ``z =
\bigcirc(x + y)``. Here the operation ``x + y`` is the exact addition,
corresponding to addition of rational numbers. We similarly have that
``\bigcirc(x - y)``, ``\bigcirc(x \cdot y)`` and ``\bigcirc(x / y)``
are the floating point operations corresponding to subtraction,
multiplication and division under rounding mode ``\bigcirc``. In some
cases we will use the notation ``\bigcirc(+)`` to denote floating
point addition under the rounding mode ``\bigcirc`` (so ``\nabla(+)``
for round down and ``\Delta(+)`` for round up).

A natural question is, how does the computer compute ``\bigcirc(a +
b)``? The value ``a + b`` is not (necessarily) representable as a
floating point number, how can the computer then work with it? The key
is to remember that both ``a`` and ``b`` are of the form ``x \cdot
2^y``. If we write ``a = x_a \cdot 2^{y_a}`` and ``b = x_b \cdot
2^{y_b}`` then

``` math
a \cdot b = x_ax_b \cdot 2^{y_a + y_b}.
```

Computing this number requires multiplying the two integers ``x_a``
and ``x_b`` and adding the integers ``y_a`` and ``y_b``. The computer
can this; it is just integer arithmetic! Rounding the result then
requires some manipulation of these integers, but throughout the
computations we are only working with integers.

!!! note
    In practice most floating point implementations do not compute
    e.g. ``x_ax_b`` directly. They use more optimized routines that
    handle the multiplication and the rounding in one step. At the
    most fundamental level everything is however just integer
    arithmetic.

With this we finally have a mathematically well defined notion of
arithmetic for floating points! This definition does however come with
a number of awkward mathematical properties. These issues are a result
of the problem that rounding does not compose. For example,
``\bigcirc(\bigcirc(x + y) + z)`` is in general not the same as
``\bigcirc(x + \bigcirc(y + z))`` and neither of them are (in general)
the same as ``\bigcirc(x + y + z)``. This means that floating point
addition is non-associative (it is however commutative).

Working with non-associative operations is in general very tedious, it
means you have to be extremely careful when you specify your
expressions to make sure that the order of the operations is well
defined.

!!! note "Example"
    Consider the sum

    ``` math
    S = \sum_{n = 1}^{10^4} \frac{1}{n}.
    ```

    If we were to exactly compute this sum and then round it to a
    floating point then we would get the value ``\bigcirc(S)``. If we
    want to use floating points to compute the sum we round each
    individual operation. As a first step we can round the divisions, giving us

    ``` math
    S' = \sum_{n = 1}^{10^4} \bigcirc(1 / n).
    ```

    If we were to perform this sum exactly we would get the floating point
    number ``\bigcirc(S')``. Of course, we also have rounding when computing
    the sum. If we sum from the left we get

    ``` math
    S_l = \bigcirc(\cdots\bigcirc(\bigcirc(\bigcirc(1 / 1) + \bigcirc(1 / 2)) + \bigcirc(1 / 3))\cdots),
    ```

    if we sum from the right we get

    ``` math
    S_r = (\cdots \bigcirc(\bigcirc(1 / (10^4 - 2)) + \bigcirc(\bigcirc(1 / (10^4 - 1)) + \bigcirc(1 / 10^4)))\cdots).
    ```

    In Julia this would correspond to

    ``` @repl 1
    S_l = 0.0
    for n in 1:10^4
        S_l += 1.0 / n
    end
    S_l

    S_r = 0.0
    for n in reverse(1:10^4)
        S_r += 1.0 / n
    end
    S_r
    ```

    We can see that these mostly agree, but are not exactly the same.
    We can also compute the entire sum exactly using rational numbers
    and then round to a floating point. This gives us

    ``` @repl 1
    S = Float64(sum(n -> 1 // BigInt(n), 1:10^4))
    ```

    We can compare this to ``S_l`` and ``S_r``

    ``` @repl 1
    S_l - S
    S_r - S
    ```

    The `sum` function in Julia instead does a pairwise summation,
    this in general gives much smaller rounding errors.

    ``` @repl 1
    S - sum(n -> 1.0 / n, 1:10^4)
    ```
