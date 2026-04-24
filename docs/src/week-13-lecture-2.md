# Week 13 Lecture 2: Solving in sequence space - the radii polynomial approach

In the last lecture we looked at the radii polynomial approach for
solving differential equations in sequence space. In this lecture we
start where we left off last time, applying the approach to the
logistic equation.

## Where we left off

Our example in the last lecture was the logistic equation,

``` math
u'(t) = u(t)(1 - u(t)),
```

with initial data ``u(0) = 1 / 2``. Expanding ``u(t)`` as a Taylor
series we write it as

``` math
u(t) = \sum_{n = 0}^\infty c_n t^n.
```

This gives us an equation for the coefficients in sequence space. If
we let ``c = \{c\}_{n = 0}^\infty`` and let

``` math
(F(c))_n =
\begin{cases}
  c_0 - 1 / 2 & n = 0,\\
  nc_n - (c \ast (1 - c))_{n - 1} & n \geq 1,
\end{cases}
```

then we are searching for solutions to ``F(c) = 0``.

To prove the existence of a solution to ``F(c) = 0`` we will search
for fixed points of

``` math
T(c) = c - AF(c),
```

where ``A`` is an injective linear operator. In practice ``A`` is
taken to be an approximation of ``DF(\overline{c})`` for some
approximate fixed point ``\overline{c}``.

To prove the existence of a fixed point we will apply the Radii
polynomial theorem in the weighted sequence space

``` math
\ell_\nu^1 = \{c = \{c_n\}_{n = 0}^\infty : \|c\|_\nu < \infty\},
```

with norm

``` math
\|c\|_\nu = \sum_{n = 0}^\infty |c_n|\nu^n,
```

for some ``\nu > 0``. Given an approximate fixed point
``\overline{c}`` we need to find real numbers ``Y``, ``Z_1`` and
``Z_2`` satisfying

``` math
\begin{align}
  \|T(\overline{c}) - \overline{c}\| &\leq Y,\\
  \|DT(\overline{c})\|_{\ell_\nu^1 \to \ell_\nu^1} &\leq Z_{1},\\
  \sup_{c \in \text{cl}(B_R(\overline{c}))} \|D^2T(c)\|_{\ell_\nu^1 \times \ell_\nu^1 \to \ell_\nu^1} &\leq Z_{2}.
\end{align}
```

Define the radii polynomial ``p(r) = Y + (Z_1 - 1)r + \frac{Z_2}{2}
r^2``. If we can find ``r \in [0, R]`` such that ``p(r) \leq 0`` and
``Z_1 + Z_2 r < 1``, then ``T`` has a unique fixed point within a
distance ``r`` of the approximate fixed point ``\overline{c}``.

## Finite part + tail

For many of the bounds we will split the operator ``T`` into one
finite part, which is handled numerically, and one infinite tail which
is bounded by hand.

For this reason it is convenient to introduce the truncation operator
``\Pi_N : \ell_\nu^1 \to \ell_\nu^1`` that zeros out all coefficients
above ``N``. More precisely it is given by

``` math
(\Pi_N c)_n =
\begin{cases}
  c_n \text{ if } n \leq N,
  0 \text{ if } n > N.
\end{cases}
```

We will also make use of the complementary operator, ``\Pi_{>N} = I -
\Pi_N``, which zeros out the coefficients up to ``N``. These two
operators will often be used to split the problem into two parts.

Formally the operator ``\Pi_N`` goes from ``\ell_\nu^1`` to itself.
However, in many cases it is natural to instead consider it as an
operator to ``\mathbb{R}^{N + 1}``, since the output only has ``N +
1`` non-zero elements. In the presentation below we will in a slight
abuse of notation switch between these two points of view when it is
convenient.

When treating ``\Pi_N`` as an operator to ``\mathbb{R}^{N + 1}`` it is
also convenient to consider the inclusion operator ``i_N :
\mathbb{R}^{N + 1} \to \ell_\nu^1``, which takes a finite sequence and
embeds it in ``\ell_\nu^1`` (padding it with zeros).

## Finding an approximate solution

To find an approximate solution we completely throw away the infinite
tail and only work on the finite part. If we truncate to index ``N``
this gives us a mapping from ``\mathbb{R}^{N + 1}`` to
``\mathbb{R}^{N + 1}``, which we apply standard non-rigorous methods
to. The result is an approximate solution ``\overline{c} =
\{\overline{c}_n\}_{n = 0}^{N}``. Formally the approximation would be
infinite sequence coming from ``i_N`` applied to the finite numerical
approximation.

## Studying ``DF`` and ``D^2F`` and choosing ``A``

Before we can choose the operator ``A`` to use in ``T`` we need to
understand the behavior of ``DF``. For the bound with ``Z_2`` we will
also need to understand ``D^2F``.

!!! note "Remark"
    Depending on your familiarity with infinite dimensional operators, the
    presentation below might be more or less easy to follow. For our
    purposes today it's convenient to think of ``DF`` as an infinite
    dimensional matrix. That makes the truncation to a finite part very
    simple and also helps with understanding how to handle the tail.

Let us write ``F`` as

``` math
(F(c))_n =
\begin{cases}
  c_0 - 1 / 2 & n = 0,\\
  nc_n - c_{n - 1}  + (c \ast c)_{n - 1} & n \geq 1.
\end{cases}
```

The Frechet derivative ``DF(c)`` is a linear operator on
``\ell_\nu^1`` and is the bounded linear operator satisfying

``` math
F(c + h) = F(c) + DF(c)h + o(\|c\|_\nu).
```

We need to understand how ``DF(c)`` acts on sequences ``h``. For ``n
\geq 1`` we have

``` math
(F(c + h))_n = n(c_n + h_n) - c_{n - 1} - h_{n - 1} + ((c + h) \ast (c + h))_{n - 1}
```

From

``` math
(c + h) \ast (c _ h) = c \ast c + 2(c \ast h) + h \ast h
```

we get

``` math
\begin{split}
  (F(c + h))_n
  &= n(c_n + h_n) - c_{n - 1} - h_{n - 1} + (c \ast c)_{n - 1} + 2(c \ast h)_{n - 1} + (h \ast h)_{n - 1}\\
  &= (F(c))_n + nh_n - h_{n - 1} + 2(c \ast h)_{n - 1} + o(\|h\|_\nu).
\end{split}
```

Combined with ``(F(c + h))_0 = F(c)_0 + h_0`` this gives us

``` math
(DF(c))_n =
\begin{cases}
  h_0 & n = 0,\\
  nh_n - h_{n - 1}  + 2(c \ast h)_{n - 1} & n \geq 1.
\end{cases}
```

If we represent ``DF(c)`` as an infinite dimensional matrix, then
``h_0`` and ``nh_n`` correspond to the diagonal part. We denote this
diagonal part by the operator ``\Lambda``, defined by

``` math
(\Lambda h)_n =
\begin{cases}
  h_0 & n = 0,\\
  nh_n & n \geq 1.
\end{cases}
```

The other part of ``DF(c)``, ``- h_{n - 1} + 2(c \ast h)_{n - 1}``, is
lower triangular. By noting that

``` math
- h_{n - 1} + 2(c \ast h)_{n - 1} = ((2c - 1) \ast h)_{n - 1}
```

we can see that it corresponds to multiplying ``h`` by ``2c - 1`` and
then shifting the sequence one step to the right. Let us denote this
part of the operator by ``L_c``. We then have

``` math
DF(c) = \Lambda + L_c.
```

For choosing the operator ``A`` we want it to be an approximation of
``DF(\overline{c})``. We split it into two parts, one finite part and
one infinite tail. For the finite part we consider the full operator
``DF(c) = \Lambda + L_c`` truncated to index ``N``. More precisely we
consider the finite dimensional linear operator

``` math
\Pi_N DF(c) i_N : \mathbb{R}^{N + 1} \to \mathbb{R}^{N + 1}.
```

Since this is a finite dimensional linear mapping it can be
represented by an ``(N + 1) \times (N + 1)`` matrix, which we can
explicitly compute given ``\overline{c}``. The finite part of ``A``
will be an approximate (numerical) inverse of this matrix, let us
denote this matrix by ``A_N``.

For the tail of ``A`` we only consider the dominant part of
``DF(\overline{c})``, namely the operator ``\Lambda``. Note that this
part doesn't depend on our approximation ``\overline{c}``. In this
case, we can explicitly compute the inverse ``\Lambda^{-1}``, it is
given by

``` math
(\Lambda^{-1} h)_n =
\begin{cases}
  h_0 & n = 0,\\
  \frac{1}{n}h_n & n \geq 1.
\end{cases}
```

We therefore take ``A`` to be given by

``` math
A = i_N A_N \Pi_N + \Lambda^{-1} \Pi_{> N}.
```

Note that ``i_N A_N \Pi_N`` only acts on the subspace of
``\ell_\nu^1`` given by indices up to ``N`` and that ``\Lambda^{-1}
\Pi_{> N}`` only acts on the subspace given by indices larger than
``N``. The linear operator ``A`` is hence block diagonal, and can be
represented as

``` math
A = \begin{pmatrix} A_N & 0 \\ 0 & \Lambda^{-1} \end{pmatrix}.
```

Note that for the finite part, ``i_N A_N \Pi_N``, we don't have any
direct control in terms of pen-and-paper estimates. The coefficients
are determined numerically and we need to use the computer to compute
bounds. For the tail, ``\Lambda^{-1} \Pi_{> N}``, we have a good
understanding of the behavior, which is important since we will have
to do these estimates by hand.

Let us finally take a look at ``D^2F``. Since ``F`` is a second order
operator, ``D^2F`` is independent of ``c``. It is given by the
bilinear map

``` math
(D^2F(c)(h, k))_n =
\begin{cases}
  0 & n = 0,\\
  2(k \ast h)_{n - 1} & n \geq 1.
\end{cases}
```

## Computing ``Y``

To bound ``Y`` we need to bound

``` math
\|T(\overline{c}) - \overline{c}\|_\nu = \|AF(\overline{c})\|_\nu.
```

From the definition of ``A`` we have

``` math
AF(\overline{c}) = i_N A_N \Pi_N F(\overline{c}) + \Lambda^{-1} \Pi_{> N} F(\overline{c}),
```

giving us

``` math
\|AF(\overline{c})\|_\nu \leq \|i_N A_N \Pi_N F(\overline{c})\|_\nu + \|\Lambda^{-1} \Pi_{> N} F(\overline{c})\|_\nu.
```

For the first term we note that

``` math
i_N A_N \Pi_N F(\overline{c})
```

is a finite sequence, which can be directly computed using interval
arithmetic. This allows us to compute a bound.

For the second term we note that this is, in fact, also a finite
sequence. This is a consequence of ``F(\overline{c})`` having non-zero
values up to at most index ``2N`` due to the quadratic non-linearity.
We can therefore again compute this sequence using interval arithmetic
and get a bound from there.

## Computing ``Z_1``

The next step is to bound ``Z_1``. We have

``` math
DT(\overline{c}) = I - ADF(\overline{c}).
```

From ``DF(\overline{c}) = \Lambda + L_{\overline{c}}`` and the
definition of ``A`` we get

``` math
ADF(\overline{c}) = A(\Lambda + L_{\overline{c}})
= i_N A_N \Pi_N (\Lambda + L_{\overline{c}}) + \Lambda^{-1} \Pi_{> N} (\Lambda + L_{\overline{c}}).
```

Note that similar to ``A``, this operator is block diagonal. The term
``i_N A_N \Pi_N (\Lambda + L_{\overline{c}})`` acts purely on the
subspace with indices up to ``N`` and ``\Lambda^{-1} \Pi_{> N}
(\Lambda + L_{\overline{c}})`` acts purely on the subspace with indices
larger than ``N``. It is then a general result that the norm is given
by the maximum of the two norms, namely

``` math
\|DT(\overline{c})\|_{\ell_\nu^1 \to \ell_\nu^1}
= \max\left(
\left\|\Pi_N - i_N A_N \Pi_N (\Lambda + L_{\overline{c}})\right\|_{\ell_\nu^1 \to \ell_\nu^1},
\left\|\Pi_{>N} - \Lambda^{-1} \Pi_{> N} (\Lambda + L_{\overline{c}})\right\|_{\ell_\nu^1 \to \ell_\nu^1}
\right).
```

To compute a bound for the first term we use that

``` math
\Pi_N - i_N A_N \Pi_N (\Lambda + L_{\overline{c}})
```

corresponds to a finite ``(N + 1) \times (N + 1)`` matrix. We can
compute this matrix and bound the norm from there.

For the second term we note that

``` math
\Lambda^{-1} \Pi_{> N} \Lambda = \Lambda^{-1} \Lambda \Pi_{> N} = \Pi_{> N}.
```

This gives us

``` math
\Pi_{>N} - \Lambda^{-1} \Pi_{> N} (\Lambda + L_{\overline{c}}) = -\Lambda^{-1} \Pi_{>N} L_{\overline{c}}.
```

We can bound this as

``` math
\left\|-\Lambda^{-1} \Pi_{>N} L_{\overline{c}}\right\|_{\ell_\nu^1 \to \ell_\nu^1}
\leq \left\|\Lambda^{-1} \Pi_{>N}\right\|_{\ell_\nu^1 \to \ell_\nu^1}
\left\|L_{\overline{c}}\right\|_{\ell_\nu^1 \to \ell_\nu^1}.
```

The first factor is bounded by ``\frac{1}{N + 1}``. To bound the
second factor, recall that ``L_c`` corresponds to multiplication by
``2\overline{c} - 1``, followed by a shift of the sequence one step to the right.
The norm for the operator corresponding to multiplication by ``2\overline{c} -
1`` is given by the norm of ``2\overline{c} - 1``. The norm for shifting is
``\nu``, which follows from

``` math
\|\{c_{n - 1}\}_{n = 1}^N\| =
= \sum_{n = 1}^\infty |c_{n - 1}|\nu^n
= \nu \sum_{n = 0}^\infty |c_{n}|\nu^n
\leq \nu\|\{c_{n}\}_{n = 0}^N\|.
```

Hence

``` math
\left\|L_{\overline{c}}\right\|_{\ell_\nu^1 \to \ell_\nu^1} \leq \nu\|2\overline{c} - 1\|_{\nu}.
```

We conclude that

``` math
\left\|\Pi_{>N} - \Lambda^{-1} \Pi_{> N} (\Lambda + L_{\overline{c}})\right\|_{\ell_\nu^1 \to \ell_\nu^1}
\leq \frac{\nu}{N + 1}\|2\overline{c} - 1\|_{\nu}.
```

Note that since ``\overline{c}`` is a finite sequence we can compute
its norm directly.

## Computing ``Z_2``

Finally we get to ``Z_2``. In this case, we have

``` math
D^2T(\overline{c}) = AD^2F(\overline{c})
```

and hence

``` math
\|D^2T(\overline{c})\|_{\ell_\nu^1 \times \ell_\nu^1 \to \ell_\nu^1}
\leq \|A\|_{\ell_\nu^1 \to \ell_\nu^1} \|D^2F(\overline{c})\|_{\ell_\nu^1 \times \ell_\nu^1 \to \ell_\nu^1}.
```

Note that since ``D^2F(\overline{c})`` is independent of
``\overline{c}`` the supremum in the bound doesn't actually matter, we
get a global bound for the operator.

For ``A`` we have

``` math
\|A\|_{\ell_\nu^1 \to \ell_\nu^1} \leq
\max\left(
\|i_N A_N \Pi_N\|_{\ell_\nu^1 \to \ell_\nu^1},
\|\Lambda^{-1} \Pi_{>N}\|_{\ell_\nu^1 \to \ell_\nu^1}
\right).
```

The first term is a finite matrix, whose norm we can compute. The
second term is bounded by ``\frac{1}{N + 1}`` since this is the
largest scaling applied to indices larger than ``N``.

For ``D^2T(\overline{c})`` we recall that it was given by

``` math
(D^2F(c)(h, k))_n =
\begin{cases}
  0 & n = 0,\\
  2(k \ast h)_{n - 1} & n \geq 1.
\end{cases}
```

It hence corresponds to a shift and multiplication by 2, giving us a
norm of ``2\nu``. We conclude that

``` math
\|D^2T(\overline{c})\|_{\ell_\nu^1 \times \ell_\nu^1 \to \ell_\nu^1}
\leq 2\nu\max\left(\|i_N A_N \Pi_N\|_{\ell_\nu^1 \to \ell_\nu^1}, \frac{1}{N + 1}\right).
```

## Other equations

The computations above were specific for the equation we considered.
The idea of splitting into a finite part and a tail does, however,
hold in general. There are, however, a number of things that can make
computing the bounds more complicated:

1. If the non-linearity is not polynomial we don't get a finite tail
   when bounding ``\|T(\overline{c}) - \overline{c}\|_\nu``. One then
   has to do more estimates to get bounds for the decay rate.
2. In general the operator ``D^2T(c)`` will not be independent of
   ``c``. In this case one has to get bounds for how this behaves in a
   neighbourhood of ``\overline{c}``.
3. In this case the dominant part of ``DF(c)`` was diagonal and we
   could hence take the tail of ``A`` to be diagonal as well. In
   general this might not be the case and one would have to rely on
   more sophisticated methods for bounding it.
