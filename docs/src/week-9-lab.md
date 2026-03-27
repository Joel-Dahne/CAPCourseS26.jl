# Week 9 Lab: Performance comparisons between Arblib.jl and IntervalArithmetic.jl

In this lab we will see how Arblib.jl and IntervalArithmetic.jl
compare when it comes to performance. In the process we will also look
at how to perform different types of computations in the two packages.

We will compare the performance for:

1. Basic arithmetic
2. Elementary functions
3. Linear algebra

We will do the comparisons between `Interval{Float64}` and `Arb` with
53 bits of precision as well as between `Interval{BigFloat}` and
`Arb`, both with 256 bits of precision.

Since IntervalArithmetic.jl doesn't support any special functions nor
does it have any routines for polynomials, we can't make any
comparisons for that.

``` @example 1
using Arblib
using IntervalArithmetic
using ForwardDiff
using LinearAlgebra
using BenchmarkTools
```

## Basic arithmetic

Let us start by comparing performance for single arithmetic
computations. Doing so is not always so useful as some of the overhead
can dominate, but it is nevertheless a good starting point. Let us
take ``x = 1 / 3`` and ``y = \sqrt{2}`` as our input, we start by
computing them for the four cases we care about. We also include the
`Float64` case.

``` @example 1
x_f = 1 / 3
x_I = interval(Float64, 1 // 3)
x_B = Arb(1 // 3, prec = 53)
x_I_big = interval(BigFloat, 1 // 3)
x_B_big = Arb(1 // 3, prec = 256)

y_f = sqrt(2)
y_I = sqrt(interval(Float64, 2))
y_B = sqrt(Arb(2, prec = 53))
y_I_big = sqrt(interval(BigFloat, 2))
y_B_big = sqrt(Arb(2, prec = 256))
```

Comparing the performance for addition we have

``` @repl 1
@benchmark $x_f + $y_f
@benchmark $x_I + $y_I
@benchmark $x_B + $y_B
@benchmark $x_I_big + $y_I_big
@benchmark $x_B_big + $y_B_big
```

Note that for `Arb` and `Interval{BigFloat}` the minimum time and the
mean time are very different. The reason for this is garbage
collection (GC), the percent of time spent on garbage collection is
seen in the right column. You can also look at the number of
allocations.

For multiplication we get

``` @repl 1
@benchmark $x_f * $y_f
@benchmark $x_I * $y_I
@benchmark $x_B * $y_B
@benchmark $x_I_big * $y_I_big
@benchmark $x_B_big * $y_B_big
```

Finally, for division we have

``` @repl 1
@benchmark $x_f / $y_f
@benchmark $x_I / $y_I
@benchmark $x_B / $y_B
@benchmark $x_I_big / $y_I_big
@benchmark $x_B_big / $y_B_big
```

Let us next look at a function which consists of a combination of
arithmetic operations. Let us take an explicit degree 5 polynomial and
evaluate it using a Horner scheme.

``` math
p(x) = x - 2x^2 + 3x^3 - 4x^4 + 5x^5 = ((((5x - 4)x + 3)x - 2)x + 1)x
```

Implementing this in Julia is straightforward.

``` @example 1
p(x) = ((((5x - 4) * x + 3) * x - 2) * x + 1) * x
```

Evaluating this at ``x`` we get

``` @repl 1
@benchmark p($x_f)
@benchmark p($x_I)
@benchmark p($x_B)
@benchmark p($x_I_big)
@benchmark p($x_B_big)
```

We can also evaluate this on the complex value ``x + iy``.

``` @repl 1
@benchmark p($(complex(x_f, y_f)))
@benchmark p($(complex(x_I, y_I)))
@benchmark p($(Acb(x_B, y_B)))
@benchmark p($(complex(x_I_big, y_I_big)))
@benchmark p($(Acb(x_B_big, y_B_big)))
```

Finally, let us look at one of the tricks that the Arblib.jl library
has, mutable arithmetic. This allows us to reduce the number of
allocations, improving performance. Allowing these types of low-level
optimizations was one of the motivations for developing the Arblib.jl
library. In this case we implement ``p(x)`` as

``` @example 1
function p!(res, x)
    # res = 5x
    Arblib.mul!(res, x, 5)

    # res = 5x - 4
    Arblib.add!(res, res, -4)

    # res = (5x - 4) * x
    Arblib.mul!(res, res, x)

    # res = (5x - 4) * x + 3
    Arblib.add!(res, res, 3)

    # res = ((5x - 4) * x + 3) * x
    Arblib.mul!(res, res, x)

    # res = ((5x - 4) * x + 3) * x - 2
    Arblib.add!(res, res, -2)

    # res = (((5x - 4) * x + 3) * x - 2) * x
    Arblib.mul!(res, res, x)

    # res = (((5x - 4) * x + 3) * x - 2) * x + 1
    Arblib.add!(res, res, 1)

    # res = ((((5x - 4) * x + 3) * x - 2) * x + 1) * x
    Arblib.mul!(res, res, x)

    return res
end
```

With this we get

``` @repl 1
res_B = Arb(prec = 53)
res_B_big = Arb(prec = 256)
@benchmark p!($res_B, $x_B)
@benchmark p!($res_B_big, $x_B_big)
```

!!! note "Remark"
    The code could be sped up by making use of `muladd` for performing
    the fused addition and multiplication. In this precise case when
    the coefficients are integers this is however slightly more
    awkward to implement.

## Elementary functions

Let us next look at computing some elementary functions. To begin
with, let us use the same value ``x`` as in the previous section. For
``e^x`` and ``\sin`` we get

``` @repl 1
@benchmark exp($x_f)
@benchmark exp($x_I)
@benchmark exp($x_B)
@benchmark exp($x_I_big)
@benchmark exp($x_B_big)
```

``` @repl 1
@benchmark sin($x_f)
@benchmark sin($x_I)
@benchmark sin($x_B)
@benchmark sin($x_I_big)
@benchmark sin($x_B_big)
```

For many elementary functions the performance depends on the value of
the input, this is for example true for ``\sin`` where an argument
reduction needs to be done for values outside of ``[-\pi/4, \pi/4]``.
Let us take ``z = 10^6 / 3``. We get

``` @example 1
z_f = 10^6 / 3
z_I = interval(Float64, 10^6 // 3)
z_I_big = interval(BigFloat, 10^6 // 3)
z_B = Arb(10^6 // 3, prec = 53)
z_B_big = Arb(10^6 // 3, prec = 256)
```

``` @repl 1
@benchmark sin($z_f)
@benchmark sin($z_I)
@benchmark sin($z_B)
@benchmark sin($z_I_big)
@benchmark sin($z_B_big)
```

Let us next look at a function consisting of many elementary
functions. For this we take

``` math
f(x) = \sqrt{\arctan(\sin(x) + e^x)} - \cosh(\log(x))
```

``` @example 1
f(x) = sqrt(atan(sin(x) + exp(x))) - cosh(log(x))
```

``` @repl 1
@benchmark f($x_f)
@benchmark f($x_I)
@benchmark f($x_B)
@benchmark f($x_I_big)
@benchmark f($x_B_big)
```

Let us also try it for the complex value ``x + iy``.

``` @repl 1
@benchmark f($(complex(x_f, y_f)))
@benchmark f($(complex(x_I, y_I)))
@benchmark f($(Acb(x_B, y_B)))
@benchmark f($(complex(x_I_big, y_I_big)))
@benchmark f($(Acb(x_B_big, y_B_big)))
```

Finally, let us compare the computation of derivatives. For `Arb` we
use an `ArbSeries` of degree 1 and for `Interval` we use
ForwardDiff.jl.

``` @repl 1
@benchmark ForwardDiff.derivative($f, $x_f)
@benchmark ForwardDiff.derivative($f, $x_I)
@benchmark f($(ArbSeries((x_B, 1))))
@benchmark ForwardDiff.derivative($f, $x_I_big)
@benchmark f($(ArbSeries((x_B_big, 1))))
```

## Linear algebra

For this we will look at matrix multiplication, inverses and the
computation of eigenvalues.

!!! note "Remark"
    Last lecture I said that IntervalArithmetic.jl supports solving
    linear systems; this seems to not actually be the case. It does
    support computing matrix inverses though, so we benchmark that
    instead.

For matrix multiplication let us take two ``100 \times 100`` matrices
``X`` and ``Y`` with ``(X)_{ij} = \rho^{|i - j|}`` with ``\rho = 1 /
3`` and ``Y_{ij} = 1 / (i - j + 0.5)``. For `Arb` we make two versions
of the matrix, one standard `Matrix{Arb}` and one `ArbMatrix`.

``` @example 1
N = 100

ρ = 1 // 3
X_f = [(1 / 3)^abs(i - j) for i in 1:N, j in 1:N]
X_I = [interval(Float64, 1 // 3)^abs(i - j) for i in 1:N, j in 1:N]
X_B = [Arb(1 // 3, prec = 53)^abs(i - j) for i in 1:N, j in 1:N]
X_B_AM = ArbMatrix(X_B, prec = 53)
X_I_big = [interval(BigFloat, 1 // 3)^abs(i - j) for i in 1:N, j in 1:N]
X_B_big = [Arb(1 // 3, prec = 256)^abs(i - j) for i in 1:N, j in 1:N]
X_B_big_AM = ArbMatrix(X_B_big)

Y_f = [inv(i - j + 0.5) for i in 1:N, j in 1:N]
Y_I = [inv(interval(i - j + 0.5)) for i in 1:N, j in 1:N]
Y_B = [inv(Arb(i - j + 0.5, prec = 53)) for i in 1:N, j in 1:N]
Y_B_AM = ArbMatrix(Y_B, prec = 53)
Y_I_big = [inv(interval(BigFloat, i - j + 0.5)) for i in 1:N, j in 1:N]
Y_B_big = [inv(Arb(i - j + 0.5, prec = 256)) for i in 1:N, j in 1:N]
Y_B_big_AM = ArbMatrix(Y_B_big)
```

``` @repl 1
@benchmark $X_f * $Y_f
@benchmark $X_I * $Y_I
@benchmark $X_B * $Y_B
@benchmark $X_B_AM * $Y_B_AM
@benchmark $X_I_big * $Y_I_big
@benchmark $X_B_big * $Y_B_big
@benchmark $X_B_big_AM * $Y_B_big_AM
```

Next we benchmark computing the inverse of ``X``.

``` @repl 1
@benchmark inv($X_f)
@benchmark inv($X_I)
@benchmark inv($X_B)
@benchmark inv($X_B_AM)
@benchmark inv($X_I_big)
@benchmark inv($X_B_big)
@benchmark inv($X_B_big_AM)
```

Finally, let us look at computation of eigenvalues, in this case of
``Y``. Arblib only supports computation of eigenvalues for complex
matrices, so we convert them to `AcbMatrix` for the computation. There
is also no implementation of `eigvals` for `Matrix{Arb}` nor for
`Matrix{Interval{BigFloat}}`, so we exclude those.

``` @repl 1
@benchmark eigvals($Y_f)
@benchmark eigvals($Y_I)
@benchmark eigvals($(AcbMatrix(Y_B_AM)))
@benchmark eigvals($(AcbMatrix(Y_B_big_AM)))
```
