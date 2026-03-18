# Week 8 Lecture 2: Applications of Taylor arithmetic

Last lecture we looked at how to automatically compute truncated
Taylor series of functions. In Arblib this is done using the
`ArbSeries` type. For example, to compute the Taylor expansion of
degree 3 of the function ``e^{\sin(2x)} - \frac{\tan(x)}{x}`` at ``x =
\pi`` we can do

``` @repl 1
using Arblib
setprecision(Arb, 53) # We don't need too many digits
x = ArbSeries((π, 1), degree = 3) # x as a Taylor series of degree 3
exp(sin(2x)) - tan(x) / x
```

In this lecture we will look at two applications of Taylor arithmetic,
how to compute enclosures of functions and how to handle removable
singularities.

## Enclosing functions with Taylor arithmetic

We can make use of Taylor's theorem to enclose functions through their
Taylor expansion. Recall Taylor's theorem:

!!! note "Theorem"
    Let ``f`` be ``n + 1`` times differentiable on the interval ``[a,
    b]`` and let ``x_0 \in [a, b]``. Then, for any ``x \in [a, b]`` we
    have

    ``` math
    f(x) = \sum_{k = 0}^n f_k (x - x_0)^k + R_n(x)
    ```

    where

    ``` math
    R_n(x) = \frac{f^{(n + 1)}(\xi)}{(n + 1)!}(x - x_0)^{n + 1},
    ```

    for some ``\xi`` between ``x_0`` and ``x``. In particular

    ``` math
    R_n(x) \in \frac{f^{(n + 1)}([a, b])}{(n + 1)!}(x - x_0)^{n + 1}.
    ```

Let us apply this to the function ``f(x) = \sin(2x) - 2x - \cos(x)``,
taking ``x_0 = \pi`` and ``[a, b] = [2.5, 3.5]``. The first step is to
compute the Taylor expansion at ``x_0``.

``` @repl 1
f(x) = sin(2x) - 2x - cos(x)
x_0 = Arb(π)
a = Arf(2.5)
b = Arf(3.5)
n = 3
f_x0_series = f(ArbSeries((x_0, 1), degree = n))
```

We can plot this Taylor expansion on the interval ``[2.5, 3.5]`` and
compare it to ``f``.

``` @example 1
using Plots
plot(range(Arb(a), b, 1000), f, label = "f(x)")
plot!(range(Arb(a), b, 1000), x -> f_x0_series(x - x_0), label = "Taylor expansion")
savefig("week-8-lecture-2-f-taylor.svg"); nothing # hide
```

![](week-8-lecture-2-f-taylor.svg)

We see that the Taylor expansion gives a good approximation close to
``\pi`` but that the errors grow at the endpoints, just as we would
expect. The next step is to bound the remainder term. For this we need
to compute an enclosure of ``f^{(3)}([2.5, 3.5])``, which we can also
do using Taylor arithmetic! The only difference from before is that
instead of taking the constant term to be ``x_0`` we take it to be an
enclosure of the entire interval ``[a, b]``. Note that the coefficient
in the Taylor expansion already includes the factor ``\frac{1}{(n +
1)!}``.

``` @repl 1
ab = Arb((a, b))
f_ab_series = f(ArbSeries((ab, 1), degree = n + 1))
R = f_ab_series[n + 1]
```

We can then use this to compute an enclosure of ``f`` through its
Taylor series. Let us do this at ``x = 3`` as an example.

``` @repl 1
x = Arb(3)
f_x = f_x0_series(x - x_0) + R * (x - x_0)^(n + 1)
f(x) # Value to compare to
```

``` @example 1
xs = range(Arb(a), b, 1000)
f_xs = f_x0_series.(xs .- x_0) + R * (xs .- x_0).^(n + 1)
plot(xs, f, label = "f(x)")
plot!(xs, x -> f_x0_series(x - x_0), label = "Taylor expansion without remainder")
plot!(xs, f_xs, ribbon = Arblib.radius.(Arf, f_xs), label = "Taylor expansion with remainder")
savefig("week-8-lecture-2-f-taylor-remainder.svg"); nothing # hide
```

![](week-8-lecture-2-f-taylor-remainder.svg)

!!! note "Remark"
    In the above plot the `ribbon` argument is used to visualize the
    size of the error term. This visualization is however not
    completely rigorous. It only computes the error on a discrete set
    of points along the function. For a rigorous plot of the error one
    needs an interval box plot along the lines of those from Week 7
    Lecture 1.

As we can see in the plot we get good enclosures near ``x_0 = \pi``
but further away the error bounds grow. We can mitigate this using a
higher order Taylor expansion. Computing the series and the remainder
term we get

``` @repl 1
n_2 = 10
f_x0_series_2 = f(ArbSeries((x_0, 1), degree = n_2))
f_ab_series_2 = f(ArbSeries((ab, 1), degree = n_2 + 1))
R_2 = f_ab_series_2[n_2 + 1]
```

Plotting this we get

``` @example 1
f_xs_2 = f_x0_series_2.(xs .- x_0) + R_2 * (xs .- x_0).^(n_2 + 1)
plot(xs, f, label = "f(x)")
plot!(xs, x -> f_x0_series_2(x - x_0), label = "Taylor expansion without remainder")
plot!(xs, f_xs_2, ribbon = Arblib.radius.(Arf, f_xs_2), label = "Taylor expansion with remainder")
savefig("week-8-lecture-2-f-taylor-remainder-2.svg"); nothing # hide
```

![](week-8-lecture-2-f-taylor-remainder-2.svg)

Since we already have a way of evaluating ``f``, One might wonder what
the benefit of evaluating it through its Taylor series is. There are
a couple of benefits with the Taylor series evaluation:

1. It can be faster when evaluating ``f`` on many points. Computing
   the Taylor expansion and the remainder term is relatively costly,
   but once they are computed you can evaluate them very fast. So if
   you want to evaluate ``f`` on a large number of points in the
   interval ``[a, b]`` it might be faster to compute the Taylor series
   and use that.
2. It often gives better enclosures when evaluated on wide intervals.
   For example, evaluating ``f`` directly on the interval ``[2.5,
   3.5]`` gives us

   ``` @repl 1
   f(ab)
   getinterval(f(ab))
   ```

   Whereas evaluating the Taylor series gives us

   ``` @repl 1
   f_x0_series(ab - x_0) + R * (ab - x_0)^(n + 1)
   getinterval(f_x0_series(ab - x_0) + R * (ab - x_0)^(n + 1))
   ```
3. Depending on the context you can do fast, exact evaluations on the
   polynomial, and then add the remainder term at the end. For
   example, for enclosing the maximum of ``f`` we can use that

   ``` math
   \max_{x \in [a, b]} f(x) = \max_{x \in [a, b]} \sum_{k = 0}^n f_k (x - x_0)^k + R_n(x).
   ```

   If we let ``P_f`` denote the polynomial in the right hand side,
   then we can use the enclosure of ``R_n`` to enclose this as

   ``` math
   \max_{x \in [a, b]} f(x) \in \max_{t \in [a - x_0, b - x_0]} P_f(t)
   + \frac{f^{(n + 1)}([a, b])}{(n + 1)!}([a, b] - x_0)^{n + 1}.
   ```

   The problem, therefore, reduces to computing the maximum of a
   polynomial. The ArbExtras package implements the
   `ArbExtras.maximum_polynomial` for exactly this purpose. We can
   thus compute the above as

   ``` @repl 1
   using ArbExtras
   P_f = f_x0_series.poly # Set P_f to the polynomial associated with our expansion
   max_P_f = ArbExtras.maximum_polynomial(P_f, lbound(a - x_0), ubound(b - x_0))
   max_f = max_P_f + R * (ab - x_0)^(n + 1)
   getinterval(max_f)
   ```

   The function `ArbExtras.maximum_series` implements this approach.

   ``` @repl 1
   ArbExtras.maximum_series(f, a, b, degree = 3)
   ```

   !!! note "Remark"
       This code calling `ArbExtras.maximum_polynomial` is not quite
       rigorous. The issue is with `lbound(a - x_0)` and `ubound(b -
       x_0)`. They mean that we are not actually computing the maximum
       of ``P_f`` on the interval ``[a - x_0, b - x_0]``, but on a
       potentially slightly larger interval. This will still give us
       an upper bound for the maximum (which is often what you need),
       since enlarging the interval can only increase the maximum. To
       get a proper enclosure of the maximum you, however, have to do
       a bit of extra work.

For the remainder term in the Taylor series to be small, you need
either ``\frac{f^{(n + 1)}([a, b])}{(n + 1)!}`` or ``(x - x_0)^{n +
1}`` to be small. In particular the latter condition means that Taylor
expansions work best on relatively thin intervals. It is therefore
often favorable to combine Taylor series with bisection. For example,
the function `ArbExtras.maximum_enclosure` computes the maximum of a
function by combining `ArbExtras.maximum_series` with adaptive
bisection.

``` @repl 1
ArbExtras.maximum_enclosure(f, a, b, degree = 3, verbose = true)
```

## Removable singularities

Traditional interval arithmetic (and to a large extent also classical
numerics) has trouble evaluating functions with removable
singularities. For example, the function ``g(x) = \frac{\sin(x)}{x}``
is perfectly smooth near zero but cannot be directly evaluated
numerically due to the division by zero.

``` @repl 1
g(x) = sin(x) / x
g(0.0) # Float64
g(Arb(0))
```

Using Taylor series we can however easily compute an enclosure. For
this we have the following lemma, which is an immediate consequence of
Taylor's theorem.

!!! note "Lemma"
    Let ``f`` be ``n + 1`` times differentiable on the interval ``[a,
    b]`` and let ``x_0 \in [a, b]``. If ``f`` has a zero of order
    ``m < n`` at ``x_0``, then for ``x \in [a, b]`` we have

    ``` math
    \frac{f(x)}{x^{m}} = \sum_{k = m}^{n}f_{k}(x_0)(x - x_0)^{k - m}
    + \frac{f^{(n + 1)}(\xi)}{(n + 1)!}(x - x_0)^{n - m + 1},
    ```

    for some ``\xi`` between ``x_0`` and ``x``. If ``P_f`` denotes the
    polynomial for the Taylor expansion of ``f`` then the above sum is
    exactly ``\frac{P_f}{x^m}``.

Let us apply this to the function ``\frac{\sin(x)}{x}`` on the
interval ``[-0.5, 0.5]``. First we compute the Taylor series and the
remainder term for ``\sin``.

``` @repl 1
n = 5
sin_series = sin(ArbSeries((0, 1), degree = n))
@assert iszero(sin_series[0]) # Constant term is zero
R_sin = sin(ArbSeries((Arb((-0.5, 0.5)), 1), degree = n + 1))[n + 1]
```

Dividing the series by ``x`` corresponds to shifting the coefficients
by one step. Note that the resulting expansion has degree one less.

``` @repl 1
sin_series_div_x = ArbSeries(sin_series[1:end])
```

We can then enclose ``\frac{\sin(x)}{x}`` at say ``x = 0.125``.

``` @repl 1
x = Arb(0.125)
sin_series_div_x(x) + R_sin * x^n
sin(x) / x # Compare with this
```

We can now also evaluate it at ``x = 0``

``` @repl 1
x = Arb(0)
sin_series_div_x(x) + R_sin * x^n
```

Of course, this gives exactly the constant term in `sin_series_div_x`.
More importantly we can evaluate it in an interval enclosing zero, say
``[-0.125, 0.125]``.

``` @repl 1
x = Arb((-0.125, 0.125))
sin_series_div_x(x) + R_sin * x^n
```
