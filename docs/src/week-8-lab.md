# Week 8 Lab: Taylor arithmetic

## Exercise 1: Removable singularities

The goal of this exercise is to compute enclosures of

``` math
f(t) = \frac{\cos\left(\frac{\pi}{2}(t + 1)\right)}{t},
```

for ``t`` in the interval ``[-1/4, 1/4]``. Note that ``f`` has a
removable singularity at ``t = 0``.

We start by loading the packages we will need, and also define the
function ``f``.

``` @example 1
using Arblib
using IntervalArithmetic
using Plots
setprecision(Arb, 53) # We don't need too much precision

f(t) = cos(Arb(π) / 2 * (t + 1)) / t
```

To simplify plotting of `Arb` enclosures we define the following two
functions.

``` @example 1
# Return a rectangular shape with sides given by x and y. This shape
# can be plotted directly.
function to_shape(x::Arb, y::Arb)
    x_min, x_max = getinterval(x)
    y_min, y_max = getinterval(y)
    xs = [x_min, x_max, x_max, x_min]
    ys = [y_min, y_min, y_max, y_max]
    return Shape(xs, ys)
end

function plot_balls(xs::Vector{Arb}, ys::Vector{Arb})
    plot(to_shape.(xs, ys), color = 1, legend = false)
end
```

### Task 1: Direct evaluation

Plot ``f`` on ``[-1/4, 1/4]`` using direct evaluation. Do this by
splitting the interval into 100 subintervals and evaluating it on each
subinterval. **Hint:** To split the interval into subintervals the
`IntervalArithmetic.mince` function is handy, you can then convert the
`Interval`s into `Arb` values.

What happens with the enclosures near zero? Can you explain why?

### Task 2: Taylor expanding numerator

Compute a Taylor expansion (with remainder term) of the numerator at
``t = 0`` and use this to plot ``f`` on the interval. You are free to
choose the degree, but for example the degree of ``n = 2`` works well.
**Note:** The enclosures you get in this case will not be much better
than in the previous case. This part is mainly a setup for the next
step.

### Task 3: Explicitly cancel division by ``t``

The next step is to explicitly cancel the division by ``t`` in the
evaluation of ``f``. The key here is to notice that the constant term
in the Taylor expansion of the numerator of ``f`` is exactly zero at
``t = 0``. Hence, all terms have a factor ``t`` in them which can be
explicitly cancelled. **Hint:** If the constant term in the Taylor
expansion of ``g(t)`` is zero, then the Taylor expansion for
``\frac{g(t)}{t}`` is given by shifting the coefficients in the Taylor
expansion of ``g(t)`` by one step. In Arblib this can be achieved by
`ArbSeries(g_series[1:end])`, if `g_series` is the `ArbSeries` for
``g``.

## Exercise 2: `fx_div_x`

The goal of this exercise is to implement a function, `fx_div_x`,
which automatically handles evaluation for functions of the form

``` math
\frac{f(x)}{x}
```

when ``f`` has a zero at the origin. We want to implement the
following function.

``` julia
"""
    fx_div_x(f, x::Arb; degree::Int = 1)

Compute an enclosure of `f(x) / x` for a function `f` with a zero
at the origin.

The argument `degree` determines the degree of the Taylor expansion used
for the computations.
"""
function fx_div_x(f, x::Arb; degree::Int = 1)
    # TODO: Implement this!
end
```
