# Week 8 Lecture 1: Automatic differentiation and Taylor arithmetic

It is common in computer-assisted proofs that you need to compute
interval enclosures not only of a function, but also of its
derivatives. For example, the interval Newton method required us to
compute enclosures of the first derivative. One option is to implement
these derivatives by hand, that's what we did for the interval Newton
method. For more complicated functions, and in particular higher order
derivatives, this, however, quickly becomes unfeasible.

Instead of computing the derivatives by hand we want to have the
computer compute it for us. On a high level there are three different
approaches for this:

1. Symbolic differentiation
2. Finite differences
3. Automatic differentiation

They all have their pros and cons and the best alternative depends on
the context. For computer-assisted proofs the by far most useful one
is however automatic differentiation.

## Automatic differentiation

Automatic differentiation comes in two flavors:

1. Forward (automatic) differentiation
2. Backward (automatic) differentiation

Forward differentiation is then often further split into first order
forward differentiation (typically based on "Dual numbers") and higher
order forward differentiation (typically based on Taylor arithmetic).
Our focus will be on the higher order version, Taylor arithmetic. It
is to me the mathematically simplest version to understand.

!!! note "Remark"
    Automatic differentiation does by itself not have anything to do
    with computer-assisted proofs. The technique is used in all parts
    of scientific computing. It is however particularly important for
    computer-assisted proofs. For one because it composes well with
    interval arithmetic, but also because higher order derivatives are
    more commonly used in computer-assisted proofs than in many other
    parts of scientific computing because they are used to control
    remainder terms.

Let us start by briefly discussing the differences between forward and
backward differentiation, without worrying too much about the details
for how the computations are performed. Let us consider a function
``f: \mathbb{R}^n \to \mathbb{R}^m$`` with the goal of computing the
Jacobian ``Df``. The forward differentiation computes the Jacobian
column by column. At each step it computes the derivative with respect
to one variable at a time, i.e. it computes the derivatives

``` math
\left(\frac{\partial f_1}{\partial x_i},\ \frac{\partial f_2}{\partial x_i}, \dots \frac{\partial f_m}{\partial x_i}\right).
```

The backward differentiation computes the Jacobian row by row. At each
step it computes the derivative for one of the output variables with
respect to all of the inputs, i.e. it computes the gradient

``` math
\nabla f_j = \left(\frac{\partial f_j}{\partial x_1},\ \frac{\partial f_j}{\partial x_2}, \dots \frac{\partial f_j}{\partial x_n}\right).
```

This means that computing the Jacobian of ``f`` using forward
differentiation takes ``n`` steps, whereas computing it using
backwards differentiation takes ``m`` steps. This is enough to see one
of the main uses cases for backward differentiation, optimization. In
optimization, in particular machine learning, ``m`` is usually ``1``
and ``n`` is huge (in the order of billions of even trillions). In
that case backward differentiation is the only feasible option.

For computer-assisted proofs ``n`` and ``m`` are usually small, often
between ``1`` and ``3``. This would indicate that for these problems
the choice between forward and backward differentiation shouldn't be
to important. However, in practice the algorithms for backwards
differentiation are significantly more complicated to implement and
require orders of magnitude more work to get performant. Even highly
optimized backwards differentiation will usually come at a large
performance penalty. This means that for these low dimensional
problems forward differentiation is almost always the way to go.

## Taylor arithmetic

The goal of Taylor arithmetic is to allow for automatic computation of
truncated Taylor series. Given a function ``f: \mathbb{R} \to
\mathbb{R}``, a point ``x_0 \in \mathbb{R}`` and a degree ``n \in
\mathbb{Z}_{\geq 1}``, we want to compute the Taylor polynomial of
``f`` at ``x_0`` of degree ``n``.

``` math
f(x - x_0) = \sum_{k = 0}^n p_k (x - x_0)^k + \mathcal{O}((x - x_0)^{n + 1}).
```

To see how this works in action, let us take ``f(x) = e^x +
x^2``, ``x_0 = 1 / 3`` and ``n = 3``. Using Arblib.jl we can compute
the truncated Taylor series with

``` @repl 1
using Arblib
setprecision(Arb, 64) # We don't need too many digits
f(x) = exp(x) + x^2
x_0 = Arb(1 // 3)
n = 3
f(ArbSeries((x_0, 1), degree = n))
```

!!! note "Remark"
    Note that when the Taylor series will always be printed using the
    variable `x`. The series object only consists of the list of
    coefficients and the degree, it doesn't contain any information
    about the variable name nor the point ``x_0`` at which the
    expansion was computed.

How was the program able to compute this Taylor series? That's what we
will take a look at now! Let us start with the very basic case of just
addition and multiplication.

### Taylor arithmetic for addition and multiplication

To simplify the notation, let us take ``x_0 = 0``. Say we have two
functions ``f`` and ``g``, and the only thing we are given is their
Taylor series truncated to degree ``n``:

``` math
\begin{split}
  f(x) &= \sum_{k = 0}^n f_k x^k + \mathcal{O}(x^{n + 1}),\\
  g(x) &= \sum_{k = 0}^n g_k x^k + \mathcal{O}(x^{n + 1}).
\end{split}
```

On the computer, these truncated Taylor series are represented by a
list of coefficients and the degree of truncation. The Arblib type for
this type of truncated Taylor series is `ArbSeries`. Let us as an
example take ``f_k = k + 1``, ``g_k = k^2`` and ``n = 3``, we can then
compute the associated `ArbSeries` types as

``` @repl 1
n = 3
f_ks = [Arb(k + 1) for k in 0:n]
g_ks = [Arb(k^2) for k in 0:n]
f_series = ArbSeries(f_ks)
g_series = ArbSeries(g_ks)
```

From these Taylor series it is, of course, straightforward to compute
the Taylor series for the function ``f(x) + g(x)``, by simply adding
the coefficients. That is, we have

``` math
f(x) + g(x) &= \sum_{k = 0}^n (f_k + g_k) x^k + \mathcal{O}(x^{n + 1}).
```

In Arblib we could either compute this Taylor series manually, by
adding the coefficients and then constructing the associated
`ArbSeries`, or we could directly add the two `ArbSeries` values.

``` @repl 1
f_plus_g_ks = f_ks + g_ks # Compute manually
f_plus_g_series_1 = ArbSeries(f_plus_g_ks)
f_plus_g_series_2 = f_series + g_series # Compute automatically
```

Under the hood, `f_series + g_series` simply adds the coefficients
together as one would expect.

How about multiplication then? In this case we have the formula

``` math
(fg)_k = \sum_{i = 0}^k f_ig_{k - i}
```

for the coefficients. We can compute these coefficients manually

``` @repl 1
f_mul_g_ks = map(0:n) do k
    # The + 1 in the indices are needed since Julia starts indexing at 1 and not 0
    sum(i -> f_ks[i + 1] * g_ks[k - i + 1], 0:k)
end
f_mul_g_series_1 = ArbSeries(f_mul_g_ks)
```

We can also directly multiply the two `ArbSeries` values

``` @repl 1
f_mul_g_series_2 = f_series * g_series
```

!!! note "Remark"
    Note that the formula for the product is equivalent to taking
    multiplying the two polynomials ``\sum_{k = 0}^n f_k x^k`` and
    ``\sum_{k = 0}^n g_k x^k`` and truncating the degree to ``n``.
    This is in fact how Arblib computes the result, more precisely it
    uses the function
    [`arb_poly_mullow`](https://flintlib.org/doc/arb_poly.html#c.arb_poly_mullow).
    Reducing it to polynomial multiplication allows for use of fast
    algorithms for multiplying polynomials.

### Taylor arithmetic for standard functions

Let us now get to the more complex problem of computing Taylor series
of standard functions. We will take ``e^x`` as the example, similar
ideas then apply to other standard functions. As before we are given a
truncated Taylor series for a function ``f``,

``` math
f(x) = \sum_{k = 0}^n f_k x^k + \mathcal{O}(x^{n + 1}),
```

and in this case the goal is to compute a truncated Taylor series of
``e^{f(x)}``. That is, we are interested in computing coefficients
``(e^{f})_k`` such that

``` math
e^{f(x)} = \sum_{k = 0}^n (e^{f})_k x^k + \mathcal{O}(x^{n + 1}).
```

Using the fact that

``` math
\frac{d}{dx} e^{f(x)} = f'(x)e^{f(x)}
```

yields

``` math
\sum_{k = 1}^n k(e^{f})_k x^{k - 1}
= \left(\sum_{k = 1}^n kf_k x^{k - 1}\right)\left(\sum_{k = 0}^n (e^{f})_k x^k\right).
```

Multiplying both sides by ``x``, we get

``` math
\sum_{k = 1}^n k(e^{f})_k x^k
= \left(\sum_{k = 1}^n kf_k x^k\right)\left(\sum_{k = 0}^n (e^{f})_k x^k\right).
```

Using the product rule and matching coefficients gives us

``` math
k(e^{f})_k = \sum{i = 1}^k if_i(e^{f})_{k - i}.
```

We also know that the constant term is given by ``(e^{f})_0 =
e^{f_0}``, giving us

``` math
(e^{f})_k =
\begin{cases}
  e^{f_0} \text{ if } k = 0,\\
  \frac{1}{k}\sum{i = 1}^k if_i(e^{f})_{k - i} \text{ if } k > 0.
\end{cases}
```

Implementing this in code we get

``` @repl 1
exp_f_ks = zeros(Arb, n + 1) # Initialize vector for coefficients
exp_f_ks[1] = exp(f_ks[1]) # Constant coefficient
for k in 1:n
    exp_f_ks[k + 1] = sum(i -> i * f_ks[i + 1] * exp_f_ks[k - i + 1], 1:k) / k
end
exp_f_series_1 = ArbSeries(exp_f_ks)
```

As before we can also simply apply `exp` to our `ArbSeries` value.

``` @repl 1
exp_f_series_2 = exp(f_series)
```

Similar ideas can be applied to functions such as ``\log``, ``\sin``,
``\cos`` and ``1 / x``. For example we can compute

``` @repl 1
log(f_series)
sin(f_series)
cos(f_series)
1 / f_series
```

!!! note "Remark"
    In practice many of the implementations in Flint uses more
    sophisticated methods than the one we have discussed here. For
    example, ``e^x`` uses the algorithm above for small lengths but
    switches to a Newton iteration approach for higher degrees, see
    [arb_poly_exp_series](https://flintlib.org/doc/arb_poly.html#c.arb_poly_exp_series).

The final piece of the puzzle to understand we computed the Taylor
expansion of ``e^x + x^2`` at ``x_0`` is to write ``x`` as ``x = x_0 +
1 \cdot (x - x_0)``. In code this would be

``` @repl 1
x_series = ArbSeries((x_0, 1), degree = n)
```

We can then give this to our function `f`.

``` @repl 1
f(x_series)
exp(x_series) + x_series^2
```
