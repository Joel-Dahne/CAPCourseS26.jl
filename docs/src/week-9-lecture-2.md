# Week 9 Lecture 2: Overview of IntervalArithmetic.jl

In the previous lecture we took a closer look at the functionality in
FLINT and Arblib.jl. In this lecture we will take a look at
IntervalArithmetic.jl. Similar to FLINT it supports basic arithmetic,
elementary functions and basic linear algebra routines. It does not
implement any special functions or handling of polynomials. The focus
of the lecture will be on some of the functionality that either
differs or doesn't exist Arblib.jl package, namely:

1. Decorations
2. The "NG" label
3. Predicates
3. Automatric differentiation using
   [ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl)

## Decorations

Decorations are extra metadata associated with an interval. There are
five available decorations:

- `com` (common)
- `dac` (defined and continuous)
- `def` (defined)
- `trv` (trivial)
- `ill` (ill-formed)

In general the decoration is automatically computed. You can however
manually specify the decoration at construction as well.

``` @repl 1
using IntervalArithmetic
interval(1, com)
interval(1, dac)
interval(1, def)
interval(1, trv)
interval(1, ill)
```

Before we get into exactly what these decorations mean, let us
consider a motivating example for why these decorations can be useful.
Consider the problem of proving the existence a zero on the interval
``[4, 5]`` for the function

``` math
f(x) = 2\sin(x) + \sign(\cos(x / 3)) + 2.
```

In general, to prove the existence of a zero on an interval it
suffices to verify that the signs at the endpoints differ. In this
case we have

``` @repl 1
f(x) = 2sin(x) + sign(cos(x / 3)) + 2
f(interval(4))
f(interval(5))
sign(f(interval(4))) != sign(f(interval(5)))
```

So the signs at the endpoints do differ. However, plotting ``f`` we
see that there is no zero on the interval

``` @repl 1
using Plots
scatter(range(4, 5, 1000), f, ms = 1, legend = false)
savefig("week-9-lecture-2-f.svg"); nothing # hide
```

![](week-9-lecture-2-f.svg)

The problem is, of course, that ``f`` is not continuous. For this
specific function, one could figure out exactly where the
discontinuities are by hand and use this in the verification. For a
general function, finding all the discontinuities is however a
non-trivial problem. One of the main use-cases of decorations is to
automate this. If we evaluate ``f`` on the interval ``[4, 5]`` we get

``` @repl 1
f(interval(4, 5))
```

Note the decoration we get is `def`. This means that the function has
not been proved to be continuous on the interval. If we instead
evaluate the function on ``[3, 4]`` (where it is continuous), we get

``` @repl 1
f(interval(3, 4))
```

In this case the decoration is `com`, which guarantees the continuity
of the function

More precisely, the decorations have the following meanings (see the
associated
[documentation](https://juliaintervals.github.io/IntervalArithmetic.jl/stable/manual/construction/#Decorations)):

- `com` (common): ``x`` is a closed, bounded, non-empty subset of the
  domain of ``f``, ``f`` is continuous on the interval ``x``, and
  ``f(x)`` is bounded.
- `dac` (defined and continuous): ``x`` is a non-empty subset of the
  domain of ``f``, and ``f`` is continuous on ``x``.
- `def` (defined): ``x`` is a non-empty subset of the domain of ``f``;
  in other words, ``f`` is defined at each point of ``x``.
- `trv` (trivial): ``f(x)`` carries no meaningful information.
- `ill` (ill-formed): ``f(x)`` is Not an Interval (NaI).

In the above example we got the decoration `def`, which does not imply
that the function is continuous. As usual with interval arithmetic,
overestimations in the enclosures can lead to more pessimistic
decorations then necessary. For example, the function

``` math
\sign(1 + x^2 - x^2)
```

is clearly continuous everywhere (it is equal to 1). Computing an
interval enclosure for the interval ``[-1, 1]`` we, however, get

``` @repl 1
x = interval(-1, 1)
sign(1 + x^2 - x^2)
```

The issue in this case being that we get an overestimation of ``1 +
x^2 - x^2`` when computed in interval arithmetic.

The `trv` decoration occurs for functions that are not defined
everywhere on the input interval. In this case the computed enclosure
is for the intersection between the interval and the domain of the
function. For example

``` @repl 1
sqrt(interval(-1, 1))
sqrt(interval(-1))
```

!!! note "Remark"
    In my own research, it is rare that functions have unknown
    discontinuities.

## The "NG" label

In the examples above you might have seen that the intervals sometimes
have a trailing `_NG`, and sometimes don't. This is short for "Not
Guaranteed" and is part of the libraries tools for reducing the risk
of accidentally mixing rigorous and non-rigorous computations. They
signal that the computations could have been "poisoned" by
non-rigorous computations.

Newly constructed intervals will by default have the guaranteed flag
set to true. We can have the value explicitly printed by modifying the
display settings.

``` @repl 1
interval(1, 2)
setdisplay(:full)
interval(1, 2) # The true at the end indicates that the interval is guaranteed
isguaranteed(interval(1, 2)) # The value can be checked explicitly as well
setdisplay(:infsup) # Restore display settings
```

Operations only involving intervals will preserve the guaranteed flag.
Note the absence of a `_NG` flag.

``` @repl 1
x = interval(-1, 1)
y = interval(3)
x + y
sin(x)^y
sqrt(x)
```

The guaranteed flag is set to false whenever intervals are mixed with
non-intervals. In this case it prints the `_NG` flag.

``` @repl 1
x + 2π
2y
```

In the first case the result truly is non-rigorous, since the
multiplication of ``\pi`` by two is performed using `Float64`. In the
second case the result is in fact rigorous, since the `2` is
represented exactly.

You can signal that a non-interval value is exact by using the `exact`
function. You are then promising that you have verified that the value
has been rigorously computed.

``` @repl 1
exact(2) * y
```

If you do this for data that is not rigorous you can get wrong results.

``` @repl 1
x = interval(2)
sin(x * (2π)) # This shoud contain zero, but does not!
sin(x * exact(2π)) # This shoud contain zero, but does not!
sin(x * 2interval(π)) # This does contain zero!
sin(x * exact(2) * interval(π)) # So does this!
```

The guaranteed flag can be very helpful for reducing the risk of
accidentally introducing non-rigorous computations in your
computer-assisted proofs. This is in particular helpful to find places
where computations where done with `Float64` values. For example

``` @repl 1
x - interval(1, 2)
1 / 3 * x # 1 / 3 in Float64
2π * x # 2π in Float64
sqrt(3) * x # sqrt(3) in Float64
```

However, it also catches operations involving integers, where it is
much more common that the operation actually is rigorous

``` @repl 1
2x # OK!
1 // 3 * x # OK!
```

The motivation for also catching integers is that they are not always
guaranteed to be correctly computed, for example due to overflow.

``` @repl 1
2^64 * x # 2^64 overflows
interval(2)^64 * x
```

## Predicates

Arblib.jl and IntervalArithmetic.jl differ in how they handle
predicates.

- Arblib.jl returns `true` if the predicate is guaranteed to be
  satisfied and `false` otherwise.
- IntervalArithmetic.jl returns `true` if the predicate is guaranteed
  to be satisfied, `false` if it is guaranteed to be false and throws
  an error otherwise.

This difference can be seen when checking if an interval is zero

``` @repl 1
using Arblib
# Both return true for exactly zero input
iszero(Arb(0))
iszero(interval(0))
# Both return false for non-zero input
iszero(Arb(1))
iszero(interval(1))
# Arblib returns false and IntervalArithmetic throws for input overlapping zero
iszero(Arb((-1, 1)))
iszero(interval(-1, 1))
```

The same philosophy is used for other predicates as well. For
Arblib.jl this means that many predicates have a function checking the
negation. For example, `Arblib.isnonzero` checks if input is non-zero

``` @repl 1
Arblib.isnonzero(Arb(0))
Arblib.isnonzero(Arb(1))
Arblib.isnonzero(Arb((-1, 1)))
```

For IntervalArithmetic.jl this is not needed.

## Automatic differentiation

The IntervalArithmetic.jl package does not support computation of
truncated Taylor series. Instead, computations of derivatives is done
using more traditional automatic differentiation through the
[ForwardDiff.jl](https://github.com/JuliaDiff/ForwardDiff.jl) package.

``` @repl 1
using ForwardDiff

ForwardDiff.derivative(sin, interval(1))
```

This is rigorous and in general highly efficient. Unfortunately, for
higher order derivatives the situation is more complicated. In
general, higher order derivatives are computed by nesting
`ForwardDiff.derivative` calls. This gives both slightly awkward code
and is also less performant than the Taylor arithmetic approach.

``` @repl 1
sin(interval(1))
ForwardDiff.derivative(sin, interval(1))
ForwardDiff.derivative(x -> ForwardDiff.derivative(sin, x), interval(1))
ForwardDiff.derivative(x -> ForwardDiff.derivative(x -> ForwardDiff.derivative(sin, x), x), interval(1))
# Alternatively, using do-notation
ForwardDiff.derivative(interval(1)) do x
    ForwardDiff.derivative(x) do x
        ForwardDiff.derivative(sin, x)
    end
end
```

!!! note "Remark"
    There is a
    [TaylorSeries.jl](https://github.com/JuliaDiff/TaylorSeries.jl)
    package for Julia as well. It does seem to work for interval
    arithmetic and I would believe it gives rigorous results in this
    case. However, I'm not entirely sure about the status.
