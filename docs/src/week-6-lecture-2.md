# Week 6 Lecture 2: Interval Arithmetic

In this lecture we will begin our study of interval arithmetic, which
will be our primary tool for the rest of the course. We will look at
the basics of interval arithmetic, a couple of different flavors of
interval arithmetic and discuss how they are implemented on the
computer. For this lecture we will stick to basic arithmetic, in the
next lecture we will look at how to extend this to general functions.

## Real interval arithmetic

The basic idea of interval arithmetic is to do arithmetic directly on
intervals instead of on individual numbers. We extend the arithmetic
operations to intervals by treating them as sets of real numbers. If
``\bm{a} = [\underline{a}, \overline{a}]`` and ``\bm{b} =
[\underline{b}, \overline{b}]`` are two closed intervals then for any
operation ``\star`` of ``+, -, \cdot, /`` we let

``` math
\bm{a} \star \bm{b} = \{a \star b: a \in \bm{a}, b \in \bm{b}\}.
```

A crucial aspect of this definition is that the right hand side is an
interval (assuming ``0 \not\in \bm{b}`` for division). This is a
direct consequence of the operations being continuous. To compute the
resulting intervals we only need to make use of the endpoints, more
precisely we have the following formulas:

1. ``\bm{a} + \bm{b} = [\underline{a} + \underline{b}, \overline{a} + \overline{b}]``
2. ``\bm{a} - \bm{b} = [\underline{a} - \overline{b}, \overline{a} - \underline{b}]``
3. ``\bm{a} \cdot \bm{b} = [\min(\underline{a}\underline{b},
   \underline{a}\overline{b}, \overline{a}\underline{b},
   \overline{a}\overline{b}), \max(\underline{a}\underline{b},
   \underline{a}\overline{b}, \overline{a}\underline{b},
   \overline{a}\overline{b})]``
4. ``\bm{a} / \bm{b} = \bm{a} \cdot [1 / \overline{b}, 1 / \underline{b}]`` TODO: Is this correct?

!!! note "Example"
    We have

    ``` math
    \begin{align*}
      [1, 2] + [2, \pi] &= [3, 2 + \pi],\\
      [1, 2] - [1, 2] &= [-1, 1],\\
      [1, \sqrt{3}] \cdot [-1, 1] &= [-\sqrt{3}, \sqrt{3}],\\
      [1, 3] / [-2, -1] &= [-3, -1/3].
    \end{align*}
    ```

If ``r(x)`` is a rational function the we can extend ``r`` to work on
intervals by using our interval versions of interval arithmetic.

!!! note "Example"
    Consider the rational function

    ``` math
    r(x) = 2x - x^2 = 2x - x \cdot x.
    ```

    Applying this to the interval ``[0, 1]`` we get

    ``` math
    r([0, 1]) = 2[0, 1] - [0, 1] \cdot [0, 1]
    = [0, 2] - [0, 1]
    = [-1, 2].
    ```

    Alternatively we can write ``r`` as

     ``` math
    r(x) = x(2 - x).
    ```

    In this case we get

    ``` math
    r([0, 1]) = [0, 1] \cdot (2 - [0, 1])
    = [0, 1] \cdot [1, 2]
    = [0, 2].
    ```

    The range (or image) of the interval ``[0, 1]`` under ``r`` is

    ``` math
    \mathcal{R}(r; [0, 1]) := \{r(x): x \in [0, 1]\} = [0, 1]
    ```

As the above example shows, directly replacing the regular arithmetic
operations with their interval counterparts has problems. Different
formulations of the function ``r`` that are equivalent when computing
with real numbers are no longer equivalent when computing with
intervals. One of the most important properties of interval arithmetic
is however the following

!!! note "Proposition"
    Let ``r`` be a rational function and ``\bm{a}`` a closed interval.
    For any formulation (or representation) of ``r`` in terms of
    arithmetic operations we have

    ``` math
    \mathcal{R}(r; \bm{a}) \subseteq r(\bm{a}),
    ```

    as long as ``r(\bm{a})`` never involves a division by an interval
    containing zero.

!!! note "Remark"
    The reason to avoid division by zero is, of course, not because if
    we do divide by zero we might get an answer that doesn't satisfy
    the specified property. We simply haven't defined what division by
    zero should do. In the implementations we'll see, division by zero
    will return something similar to `NaN` for floating points.


!!! note "Remark"
    The specification "For any formulation of ``r``" is not something
    that is commonly encountered in mathematics. Usually we don't care
    how a function is specified, just how it maps inputs to outputs.
    The canonical way to specify an interval version of a function
    would be to let ``r(\bm{a})`` be the convex hull of
    ``\mathcal{R}(r, \bm{a})``. In this case the function is uniquely
    determined from how ``r`` maps inputs to outputs. However,
    actually implementing this function on a computer would in general
    not be possible. Since the main goal of interval arithmetic is
    precisely to implement the functions on a computer, we are stuck
    with having to take into account the formulation/representation of
    the function ``r``.

## Flavors of interval arithmetic

We will look at three different aspects of interval arithmetic that
play a role in how you work and think about it:

1. Real numbers or floating points
2. Intervals or balls
3. Wide intervals or thin intervals

### Real numbers or floating points

In the previous section we look at interval arithmetic over the real
numbers. For actual computations we will therefore have to work with
intervals where the endpoints are floating point numbers. When
performing arithmetic operations we will have to take into account
the rounding errors from floating points.

If ``\bm{a} = [\underline{a}, \overline{a}]`` and ``\bm{b} =
[\underline{b}, \overline{b}]`` are intervals with endpoints given by
floating points then

1. ``\bm{a} + \bm{b} = [\nabla(\underline{a} + \underline{b}), \Delta(\overline{a} + \overline{b})]``
2. ``\bm{a} - \bm{b} = [\nabla(\underline{a} - \overline{b}), \Delta(\overline{a} - \underline{b})]``
3. ``\bm{a} \cdot \bm{b} = [\min(\nabla(\underline{a}\underline{b}),
   \nabla(\underline{a}\overline{b}), \nabla(\overline{a}\underline{b}),
   \nabla(\overline{a}\overline{b})), \max(\Delta(\underline{a}\underline{b}),
   \Delta(\underline{a}\overline{b}), \Delta(\overline{a}\underline{b}),
   \Delta(\overline{a}\overline{b}))]``
4. ``\bm{a} / \bm{b} = \bm{a} \cdot [\nabla(1 / \overline{b}), \Delta(1 / \underline{b})]`` TODO: Is this correct?

In many contexts the distinction between the endpoints being real
numbers of floating points is however not that important. Even when
working with real numbers the computed intervals will contain
overestimations, see the example in the previous section. The extra
overestimations coming from the floating point rounding do therefore
not qualitatively change the behavior. For many purposes it is
therefore useful to think about interval arithmetic over real numbers,
even if in the end you have to implement it in floating points.

### Intervals or balls

So far we have represented our intervals by a using a lower and upper
bound, ``\bm{a} = [\underline{a}, \overline{a}]``. It is of course
mathematically equivalent to represent them with a midpoint and a
radius, ``\bm{a} = [m \pm r]``. How to perform arithmetic operations
does however change slightly. If ``\bm{a} = [m_1 \pm r_1]`` and
``\bm{b} = [m_2 \pm r_2]`` then


1. ``\bm{a} + \bm{b} = [(m_1 + m_2) \pm (r_1 + r_2)]``
2. ``\bm{a} - \bm{b} = [(m_1 - m_2) \pm (r_1 + r_2)]``

For multiplication and division it gets slightly more complicated. In
general we do not have that the midpoint of ``\bm{a} \cdot \bm{b}`` is
given by ``m_1m_2``. If we still take ``m = m_1m_2`` as the midpoint
for the product then we need to find ``r`` such that ``\bm{a} \cdot
\bm{b} \subseteq [m \pm r]``. If ``t_1, t_2 \in [-1, 1]`` then

``` math
|m_1m_2 - (m_1 + t_1r_1)(m_2 + t_2r_2)|
= |m_1t_2r_2 + m_2t_1r_1 + t_1t_2r_1r_2|
\leq |m_1|r_2 + |m_2|r_1 + r_1r_2.
```

This means that

``` math
\bm{a} \cdot \bm{b} \subseteq [m_1m_2 \pm (|m_1|r_2 + |m_2|r_1 + r_1r_2)].
```

For division one similarly have (assuming ``r_2 < |m_2|`` to avoid
division by zero)

``` math
\left|\frac{m_1}{m_2} - \frac{m_1 + t_1r_1}{m_2 + t_2r_2}\right|
\leq \left|\frac{m_1t_2r_2 - m_2t_1r_1}{m_2(m_2 + t_2r_2)}\right|
\leq \frac{|m_1|r_2 + |m_2|r_1}{|m_2|(|m_2| - r_2)},
```

hence

``` math
\bm{a} / \bm{b} \subseteq \left[\frac{m_1}{m_2} \pm \frac{|m_1|r_2 + |m_2|r_1}{|m_2|(|m_2| - r_2)}\right].
```

For floating point numbers you have to make sure that the radius is
rounded upwards and you also need to add the rounding error made in
the computation of the midpoint.

It might seem like the ball representation is just more complicated
than the version with lower and upper bounds. It does however have an
important technical benefit, when working in high precision you can
still use a low precision representation for the radius. For high
precision it is therefore up to a factor 2 faster than working with
the lower and upper bounds separately.

The ball version naturally lends itself to treating the midpoint as
your approximation and the radius as a small error that can be treated
perturbatively. This naturally leads us to the next aspect to
consider.

### Wide intervals or thin intervals

One of the things that I believe make the biggest difference to how
you should conceptually approach interval arithmetic is whether you
are working with wide intervals or thin intervals. The methods and
algorithms you want to use often heavily depend on this.

In general, if an interval is to be considered wide or not depends on
the ratio between the midpoint and the radius. If the radius is factor
``10^{-10}`` smaller one could consider it a thin interval, if the
radius is not more than a factor ``10^{-2}`` smaller then it could be
considered wide. In between these two factors you get a hybrid region
were both view points are useful. These numbers of course depend on
the context.

For thin intervals it is usually useful to take the ball arithmetic
approach. Where you think of the midpoint as your approximation and
the radius as a small error. Since the radius is small you can use
perturbative methods for bounds, which is usually simpler.

For wide intervals the lower and upper bound version is often more
useful. Perturbative error bounds usually give very bad results in
this case. Often times you want to rely on monotonicity to be able to
compute accurate enclosures.
