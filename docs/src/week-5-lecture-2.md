# Week 5 Lecture 2: Floating point numbers

In this lecture, we will continue our study of floating point numbers.
In particular we will talk about the evaluation of elementary
functions and how this interacts with rounding.

## Issues with floating point arithmetic

Already in the last lecture we started talking about some of the
issues that arise from floating point arithmetic not satisfying the
usual properties we expect from arithmetic.

Most of these issues come from the operations not being associative.
For example `(x + y) + z` and `x + (y + z)` are in general different
floating point numbers. This non-associativity can make floating point
arithmetic behave in a non-deterministic way. Each individual
operation is of course deterministic; it computes the exact value of
``\bigcirc(x + y)``, but in many cases the order these operations are
performed is not always clear and in some cases not even
deterministic.

!!! note "Example: `@fastmath` and summation order"
    Let us consider the problem of computing a sum

    ``` math
    S = \sum_{n = 1}^{N} a_n.
    ```

    in floating point arithmetic. We could implement this in Julia as

    ``` @example 1
    function strict_sum(as)
        S = zero(eltype(as))
        for a in as
            S += a # Strictly sequential addition
        end
        return S
    end
    ```

    This will perform the sum from left to right. If we take ``a_n = 1 / 10``
    (or rather ``a_n = \square(1 / 10)``) and ``N = 10^6``, this gives us

    ``` @repl 1
    as = fill(1 / 10, 10^6);
    strict_sum(as)
    ```

    Let us next implement the same sum but put `@fastmath` before it, i.e.

    ``` @example 1
    function fast_sum(as)
        S = zero(eltype(as))
        @fastmath for a in as
            S += a # Compiler is allowed to reorder these additions
        end
        return S
    end
    ```

    In this case we get

    ``` @repl 1
    fast_sum(as)
    ```

    which is slightly different from before! What happens here is
    that `@fastmath` tells the compiler that it doesn't have to follow
    the usual associativity rules for floating point arithmetic. It is
    free to reorder the operations if this will make the code faster.
    The exact result you get here will depend on your processor, as different
    orderings are faster depending on the precise architecture of the CPU.
    We can see that the performance differs quite a lot here!

    ``` @repl 1
    using BenchmarkTools
    @benchmark strict_sum($as) samples = 1000 evals = 1
    @benchmark fast_sum($as) samples = 1000 evals = 1
    ```

As the above example shows we can get slightly different results by
changing the implementation, even if we mathematically are computing
the same thing. Some of the things that can affect the results are:

1. Your code
2. The code in the libraries that you are using
3. The compiler you are using
4. The processor you are using
5. The number of threads you are using

The most common reason for changes in the result is that operations
are reordered and the non-associativity hence means that we get a
different result.

## Correctly rounded functions

Consider a function ``f: \mathbb{R} \to \mathbb{R}``. Given a rounding
mode ``\bigcirc`` we define ``\bigcirc(f) : \mathbb{F}_p \to
\mathbb{F}_p`` as

``` math
\bigcirc(f)(x) = \bigcirc(f(x)).
```

We say that a floating point implementation of a function ``f`` is
**correctly rounded** (according to the specified rounding mode) if it
computes ``\bigcirc(f)``.

This definition naturally generalizes to multivariable functions ``f:
\mathbb{R}^n \to \mathbb{R}``. The standard floating point arithmetic
operations are examples of correctly rounded two variable functions.

The three variable function ``\operatorname{fma}``
(fused-multiply-add) is commonly used for floating points. It
implements a correctly rounded version of ``x \cdot y + z``.
Evaluating this using standard floating point arithmetic would give
you ``\bigcirc(\bigcirc(x \cdot y) + z)``. The ``\operatorname{fma}``
function instead gives you ``\operatorname{fma}(x, y, z) = \bigcirc(x
\cdot y + z)``, it avoids rounding the intermediate result ``x \cdot
y``. Due to hardware support this operation can be both faster than
performing the multiplication and addition separately and at the same
time give better accuracy.

## Elementary functions

The floating point functions we have looked at so far, ``+, -, \cdot,
/`` and ``\operatorname{fma}``, are primitive floating point functions
in the sense that they are either implemented directly in hardware or
computed directly through the ``x \cdot 2^y`` representation of
floating points. The square root function and the reciprocal square
root function (``1 / \sqrt{x}``) are two other examples of functions
which are usually implemented directly in hardware, or where the
implementation uses the ``x \cdot 2^y`` representation directly. Most
other floating point functions are themselves implemented using
floating point functions.

Ideally we want a floating point implementation to be correctly
rounded, i.e. for a function ``f`` and a floating point number ``x``
we want it to return ``\bigcirc(f(x))``. This, however, turns out to
be too much to ask in many cases. The vast majority of functions
implemented in floating points are not correctly rounded. We will look
at

1. How Julia computes ``\sin``
2. Libraries for correctly rounded elementary functions
3. Why correct rounding doesn't matter too much

### Evaluating ``\sin``

How does Julia compute ``\sin(x)``? Finding out is surprisingly simple
and the code is relatively easy to understand. You can find the code
implementing `sin` by running `@less sin(0.0)`. This shows us the
following function.

``` julia
function sin(x::T) where T<:Union{Float32, Float64}
    absx = abs(x)
    if absx < T(pi)/4 #|x| ~<= pi/4, no need for reduction
        if absx < sqrt(eps(T))
            return x
        end
        return sin_kernel(x)
    elseif isnan(x)
        return x
    elseif isinf(x)
        sin_domain_error(x)
    end
    n, y = rem_pio2_kernel(x)
    n = n&3
    if n == 0
        return sin_kernel(y)
    elseif n == 1
        return cos_kernel(y)
    elseif n == 2
        return -sin_kernel(y)
    else
        return -cos_kernel(y)
    end
end
```

It checks some special cases, very small `x` (less than
`sqrt(eps())`), `NaN` values and infinity values. Otherwise it does an
argument reduction, reducing it to a value `y` in the range ``[-\pi/4,
\pi/4]`` and information about which quadrant we are in. Depending on
the quadrant it computes either `sin_kernel(y)` or `cos_kernel(y)`.
Let us look closer at `sin_kernel` (`cos_kernel` is similar). The
relevant code here is

``` julia
# Coefficients in 13th order polynomial approximation on [0; π/4]
#     sin(x) ≈ x + S1*x³ + S2*x⁵ + S3*x⁷ + S4*x⁹ + S5*x¹¹ + S6*x¹³
# D for double, S for sin, number is the order of x-1
const DS1 = -1.66666666666666324348e-01
const DS2 = 8.33333333332248946124e-03
const DS3 = -1.98412698298579493134e-04
const DS4 = 2.75573137070700676789e-06
const DS5 = -2.50507602534068634195e-08
const DS6 = 1.58969099521155010221e-10

@inline function sin_kernel(y::Float64)
    y² =  y*y
    y⁴ =  y²*y²
    r  =  @horner(y², DS2, DS3, DS4) + y²*y⁴*@horner(y², DS5, DS6)
    y³ =  y²*y
    y+y³*(DS1+y²*r)
end
```

To approximate ``\sin`` on ``[-\pi/4, \pi/4]`` it uses a degree 13
polynomial which is almost, but not quite, the Taylor expansion at
zero. The slight adjustments to the coefficients are to minimize the
maximum error on the interval, rather than the error close to zero.
For evaluating the polynomial it doesn't directly use the form `y +
S1*y³ + S2*y⁵ + S3*y⁷ + S4*y⁹ + S5*y¹¹ + S6*y¹³`, instead it uses a
Horner like scheme. The `@horner` calls here correspond to

``` julia
@horner(y², DS2, DS3, DS4) = DS2 + y² * (DS3 + y² * DS4)
@horner(y², DS5, DS6) = DS5 + y² * DS6
```

Additionally, it uses `fma` for the computations. One can check that
this corresponds to the polynomial we want to evaluate, but this
choice of order reduces the rounding errors.

This implementation is not correctly rounded, though in the majority
of cases it does return the correctly rounded result in practice. One
example where it doesn't is

``` @repl
x = 0.17931446656123207
y1 = sin(x)
y2 = Float64(sin(BigFloat(x))) # Compute in higher precision and then round
y1 - y2
```

## Libraries for correctly rounded functions

Implementing correctly rounded functions is hard, even harder is
implementing correctly rounded functions that are fast. One has to
both control truncation errors coming from the finite expansions, as
well as rounding errors when evaluating these expansions. In practice
most libraries that implement correctly rounded functions internally
make use of higher precision to be able to handle the rounding errors
from evaluating the expansions. This then has to be combined with
proofs for the truncation errors being sufficiently small. Two
libraries that do this are

1. [The GNU MPFR Library](https://www.mpfr.org/): This implements
   arbitrary precision floating point arithmetic with full control
   over rounding. The `BigFloat` type in Julia uses this library under
   the hood.
2. [CR-LIBM](https://ens-lyon.hal.science/ensl-01529804v1): This
   implements correctly rounded functions for `Float64`.

## Why this doesn't matter too much

From a mathematical point of view, asking for correctly rounded
elementary functions is natural. In practice, it is however not that
important. Even if all the functions you are using are correctly
rounded, you will still be combining the results from these functions
and introduce rounding errors along the way.

At a fundamental level, the issue is that functions being correctly
rounded "doesn't compose". If we have two functions ``f`` and ``g``
and manage to implement correctly rounded versions of these,
i.e.``\bigcirc(f)`` and ``\bigcirc(g)``, then computing
``\bigcirc(f)(\bigcirc(g)(x))`` corresponds to
``\bigcirc(f(\bigcirc(g(x))))`` which in general is not the same as
``\bigcirc(f(g(x)))``.

Solving this composition problem is one of the things that interval
arithmetic will allow us to do. It will not allow us to get correctly
rounded results, but it will allow us to get results where we have
control over the error.
