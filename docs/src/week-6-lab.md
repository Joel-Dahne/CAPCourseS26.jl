# Week 6 Lab: IntervalArithmetic.jl and Arblib.jl

In this lab we will look at the two Julia packages
[IntervalArithmetic.jl](https://github.com/JuliaIntervals/IntervalArithmetic.jl)
and [Arblib.jl](https://github.com/kalmarek/Arblib.jl).
IntervalArithmetic.jl implements "regular" interval arithmetic, where
the intervals are represented by their lower and upper bounds.
Arblib.jl implements ball arithmetic, where the intervals are
represented by a midpoint and a radius. We will make use of both of
these packages throughout the course, though likely Arblib.jl to a
larger extent (mostly because I'm more used to that package).

For the first part of the lab (intro to IntervalArithmetic.jl and
Arblib.jl) we will use the Julia REPL and the instructions below. For
the second part (computing ``\sin``) we will use the `lab-6.jl` Pluto
notebook that you can find in the `notebooks` directory. The
instructions for the second part are also included below, but we will
use the ones in the notebook.

## Intro to IntervalArithmetic.jl

Let us start by taking a closer look at IntervalArithmetic.jl.

### Construction

Intervals are constructed using the `interval` function. With
`interval(a, b)` we can construct the interval ``[a, b]`` and with
`interval(a)` we get the thin interval ``[a, a]``.

``` @repl 1
using IntervalArithmetic

interval(1, 2) # We will get back to what _com means

interval(0.1, 0.2)

interval(2)
```

By default it will create intervals where the endpoints are of type
`Float64`.

``` @repl 1
typeof(interval(1))
```

We can create intervals with endpoints of different types by giving
the type as first argument.

``` @repl 1
interval(BigFloat, 1, 2) # Note the ₂₅₆ in the output, this is the BigFloat precision

typeof(interval(BigFloat, 1, 2))

interval(Rational{Int}, 1, 2)

typeof(interval(Rational{Int}, 1, 2))
```

In practice we will mostly use `Float64` and sometimes `BigFloat`.
Having endpoints which are rational numbers can sometimes be useful,
but we won't see it too much.

Finally, you can create an interval from a string with its decimal
representation using `parse`. This avoid issues with rounding of
floating points and guarantees that the given number is contained in
the interval.

``` @repl 1
parse(Interval{Float64}, "0.1") # The printing of this is weird, see next section

parse(Interval{Float64}, "[0.1, 0.2]")
```

### Printing

There are a couple of different options for how intervals are printed.
The default can be set with `setdisplay`, see its documentation for
more details. The default is `setdisplay(:infsup)`.

By default it only rounds to 6 significant digits, with no special
handling of the different endpoints. This means that if the endpoints
share the first 6 significant digits then they print the same.

``` @repl
using IntervalArithmetic # hide
setdisplay(:infsup)
interval(π)
interval(1, 1 + 1e-10)
interval(Float64, 1 // 3) # Just interval(1 // 3) gives us a Rational one
```

As you can see in the above examples it also prints `_com` after the
interval. This is a
[decoration](https://juliaintervals.github.io/IntervalArithmetic.jl/stable/manual/construction/#Decorations).
They keep track of extra information regarding the functions used to
compute the interval. We won't care about these for now, but might
come back to them later in the course.

To print everything you can use `setdisplay(:full)`.

``` @repl
using IntervalArithmetic # hide
setdisplay(:full)
interval(1, 2)
interval(π)
interval(1, 1 + 1e-10)
interval(Float64, 1 // 3)
```

In this case the full endpoints are printed. It should however be
noted that the printing doesn't take into account rounding. For
example the printing of the following interval makes it look like it
would contain ``0.1 = 1 / 10``.

``` @repl
using IntervalArithmetic # hide
setdisplay(:full)
interval(0.1, 0.2)
```

But this is an artefact of ``0.1`` not being exactly representable in
`Float64`. We can print more digits by creating an interval of type
`BigFloat`, and then we can see that the interval does in fact not
contain ``0.1`` (it does contain ``0.2`` though).

``` @repl
using IntervalArithmetic # hide
setdisplay(:full)
interval(BigFloat, 0.1, 0.2)
```

You should be careful with reading information of intervals from their
printed representation. It is usually better to use a predicate to
check something directly

``` @repl
using IntervalArithmetic # hide
in_interval(1 // 10, interval(0.1, 0.2)) # 1 // 10 is exactly 0.1
```

### Useful tools

You can get the lower and upper bounds of the interval using `inf` and
`sup`.

``` @repl
using IntervalArithmetic # hide
x = interval(1, 2)
inf(x)
sup(x)
```

You can get the midpoint and radius using `mid` and `radius`, or both
using `midradius`. You can also get the diameter with `diam`.

``` @repl
using IntervalArithmetic # hide
x = interval(1, 2)
mid(x)
radius(x)
midradius(x)
diam(x)
```

Note that these functions return floating points and that they
therefore round. For `radius` and `diam` the rounding is outwards, so
they should always be at least as large as the true value. For the
midpoint the rounding is to nearest. Since they round you should
however be a bit careful with using these.

``` @repl
using IntervalArithmetic # hide
x = interval(1e-100, 1)
mid(x)
radius(x)
midradius(x)
diam(x)
```

## Intro to Arblib.jl

### Construction

For Arblib.jl balls are constructed using the `Arb` constructor. With
`Arb(x)` we get a ball enclosing the value of ``x``, with `Arb((a,
b))` we get a ball enclosing the interval ``[a, b]``.

``` @repl
using Arblib
Arb(1)
Arb(1 // 3)
Arb(π)
Arb("0.1")
Arb("[0.1 +/- 1e-10]")

Arb((1, 2)) # Note that this prints like [+/- 2.01], we'll get back to this
Arb((-1, 1))
Arb((1 // 3, π))
```

An alternative, slightly lower level, constructor is `setball`. We
have that `setball(Arb, m, r)` creates a ball with midpoint `m` and
radius `r`.

``` @repl
using Arblib # hide
setball(Arb, 0, 1)
setball(Arb, 1, 1e-10)
```

With `setball` the midpoint `m` is first rounded to a floating point.
This for example means that `setball(Arb, 1 // 3, 0)` will not
actually contain the number `1 / 3`.

``` @repl
using Arblib # hide
x = setball(Arb, 1 // 3, 0)
radius(x)
```

If rounding for the midpoint needs to be taken into account
`add_error` is more useful, `add_error(x::Arb, err)` will return the
ball `x` with `err` added to its radius.

``` @repl
using Arblib # hide
x = Arb(1 // 3)
y = add_error(x, Arb("1e-50"))
```

### Printing

Similar to for IntervalArithmetic.jl there are a couple of options
when printing Arb values. For Arblib.jl there is however no global
setting, instead the `string` function is used with different
arguments. See the documentation of `string` for all the options.

Arb values are printed on the form `[m +/- r]` and by default the
printed value is guaranteed to enclose the true interval. The output
for the midpoint is rounded so that the value is correct up to 1 ulp
(unit in the last decimal place). The following example from the
documentation of `string` shows that this behavior in some cases can
be slightly confusing

``` @repl
using Arblib # hide
x = Arb((1, 2))
string(x)
string(x, more = true)
string(x, digits = 5, more = true)
```

Compared to IntervalArithmetic.jl you can hence trust that the true
value is contained in the printed output. As the above example shows
there are however often large overestimations in the printed value, in
particular when no or very few significant digits of the output can be
determined.

### Useful tools

You can get the midpoint and radius of a ball using `midpoint` and
`radius` or `getball`.

``` @repl
using Arblib # hide
x = Arb(1 // 3)
midpoint(x)
radius(x)
getball(x)
```

By default the midpoint and radius are returned as floating points
(`Arf` for the midpoint, `Mag` for the radius). You can get them as
`Arb` values (with radius zero)

``` @repl
using Arblib # hide
x = Arb(1 // 3)
midpoint(Arb, x)
radius(Arb, x)
getball(Arb, x)
```

This is often more useful if you want to later do calculations with
them.

You can get lower and upper bounds with `lbound`, `ubound` and
`getinterval`.

``` @repl
using Arblib # hide
x = Arb(1 // 3)
lbound(x)
ubound(x)
getinterval(x)
```

By default these are returned as floating points, you can get them as
`Arb` values (with radius zero)

``` @repl
using Arblib # hide
x = Arb(1 // 3)
lbound(Arb, x)
ubound(Arb, x)
getinterval(Arb, x)
```

Note that these values are not the exact lower and upper bounds of the
interval, they are floating point values given by rounding the true
values outwards.

The `Arblib.rel_accuracy_bits` function can be used to get the
relative accuracy of a ball.

``` @repl
using Arblib # hide
x = Arb(1 // 3)
Arblib.rel_accuracy_bits(x)
y = add_error(x, Arb(1e-16))
Arblib.rel_accuracy_bits(y)
```

## Computing ``\sin``

We are now ready to compute ``\sin`` using both IntervalArithmetic.jl
and Arblib.jl!

As before we will use a Taylor expansion around zero. Compared to
before we will however not use a fixed degree for the expansion, but
allow it to be easily changed. Recall that

``` math
\sin(x) = \sum_{n = 0}^\infty (-1)^n\frac{x^{2n + 1}}{(2n + 1)!}.
```

Since the series is alternating the error we get if we only sum up to
term ``N`` is bounded by term ``N + 1``, i.e.

``` math
\left|\sin(x) - \sum_{n = 0}^N (-1)^n\frac{x^{2n + 1}}{(2n + 1)!}\right| \leq \frac{|x|^{2N + 3}}{(2N + 3)!}.
```

This bound can be improved, but it is good enough for our purposes.
Note that we don't put any restrictions on the value of ``x`` here.
For large values of ``x`` the error bound will of course be very
large, but it is still valid.

Here is an implementation of this approach for `Float64`. Note that it
doesn't actually do anything with the computed error bound.

``` @example 2
function my_sin(x::Float64; N::Integer = 6)
    y = 0.0
    for n in 0:N
        y += (-1)^n * x^(2n + 1) / factorial(2n + 1)
    end
    # For Float64 we can't actually do anything with this value...
    err = abs(x)^(2N + 3) / factorial(2N + 3)
    return y
end
```

Let us check that it seems to work

``` @repl 2
my_sin(1.0)
sin(1.0)
my_sin(1.0) ≈ sin(1.0)

my_sin(10.0) # For large values of x we would need more terms
sin(10.0)
```

Let us now implement `Interval{Float64}` and `Arb` versions of this
function! Here we do want to correctly handle the error bounds as
well.

``` julia
function my_sin(x::Interval{Float64}; N::Integer = 6)
    # TASK: Implement this
end

function my_sin(x::Arb; N::Integer = 6)
    # TASK: Implement this
end
```

!!! details "Solution"
    ``` @example 2
    using Arblib, IntervalArithmetic # hide

    function my_sin(x::Interval{Float64}; N::Integer = 6)
        y = zero(x)
        for n in 0:N
            y += (-1)^n * x^(2n + 1) / factorial(2n + 1)
        end
        err = abs(x)^(2N + 3) / factorial(2N + 3)
        return y + interval(-sup(err), sup(err))
    end

    function my_sin(x::Arb; N::Integer = 6)
        y = zero(x)
        for n in 0:N
            y += (-1)^n * x^(2n + 1) / factorial(2n + 1)
        end
        err = abs(x)^(2N + 3) / factorial(2N + 3)
        return add_error(y, err)
    end
    ```

``` @repl 2
setdisplay(:full) # To see the full output
my_sin(interval(1))
sin(interval(1))
issubset_interval(sin(interval(1)), my_sin(interval(1)))

my_sin(Arb(1))
sin(Arb(1))
Arblib.contains(my_sin(Arb(1)), sin(Arb(1)))

my_sin(interval(10)) # For large values of x we get enormous error bounds
my_sin(Arb(10))
```

With these two implementations, some of the things we can look at are:

- How does the radius of the `Interval` and `Arb` versions compare?
  For example for ``x = 1``.
- What happens if you increase ``N``? Hint: At some point you will get
  an error and need to adjust the code.
- What happens for wide input? ``x = [0.999, 1.001],\ [0.9, 1.1],\ [0,
  1],\ [0, 2]``? Or even larger!
- Can we do better for wide input? There are two reasonable
  approaches, one better for `Interval` and one for `Arb`.
- For large values of ``x`` you first want to reduce the argument to a
  smaller value using the periodicity. How could this be done?
