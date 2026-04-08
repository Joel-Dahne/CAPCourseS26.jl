# Week 11 Lecture 2: Self-similar blowup - Enclosing ``Q_\infty``

We continue our study of the paper [Self-Similar Singular Solutions to
the Nonlinear Schrödinger and the Complex Ginzburg-Landau
Equations](https://arxiv.org/abs/2410.05480).

In last lecture we looked at enclosing ``Q_0``, the solution the ODE
satisfying the boundary conditions at zero. Today we will look at
enclosing ``Q_\infty``, the solution satisfying the boundary
conditions at infinity.

Recall that ``Q_\infty`` is a solution to the ODE

``` math
(1 - i\epsilon)\left(Q_{\infty}'' + \frac{d - 1}{\xi}Q_{\infty}'\right) + i\kappa\xi Q_{\infty}'
+ i \frac{\kappa}{\sigma}Q_{\infty} - \omega Q_{\infty} + (1 + i\delta)|Q_{\infty}|^{2\sigma}Q_{\infty}
= 0
```

satisfying appropriate boundary conditions at infinity (which we will
get to).

## Linear equation

We expect ``Q_\infty`` to go to zero at infinity. Hence the
non-linearity, ``(1 + i\delta)|Q_{\infty}|^{2\sigma}Q_{\infty}``,
becomes negligible in the limit and it suffices to study the linear
equation

``` math
(1 - i\epsilon)\left(Q_{\infty}'' + \frac{d - 1}{\xi}Q_{\infty}'\right) + i\kappa\xi Q_{\infty}'
+ i \frac{\kappa}{\sigma}Q_{\infty} - \omega Q_{\infty}
= 0.
```

This is a second order linear ODE with (after multiplication by
``\xi``) polynomial coefficients. This type of ODEs are well studied
in the literature. If one makes the change of coordinates

``` math
a = \frac{1}{2}\left(\frac{1}{\sigma} + i \frac{\omega}{\kappa}\right),\quad
b = \frac{d}{2},\quad
c = \frac{-i \kappa}{2(1 - i\epsilon)},\quad
z = c\xi^2,
```

then one can write the equation as

``` math
zw'' + (b - z)w' - aw = 0,
```

which is [Kummer's
equation](https://en.wikipedia.org/wiki/Confluent_hypergeometric_function#Kummer's_equation).
One of the solutions to Kummer's equation is the confluent
hypergeometric function, ``U(a, b, z)``, and the other solution is a
scaled version given by ``V(a, b, z) = e^z U(b - a, b, -z)``. Since we
are dealing with a linear second order ODE, all solutions are given by
linear combinations of these two.

To understand the asymptotic behavior of ``Q_\infty`` we will have to
understand the asymptotic behavior of ``U`` and ``V``. From the
asymptotic expansion of ``U`` one gets the asymptotic behavior

``` math
U(a, b, z) \approx z^{-a}.
```

For ``V`` this gives us

``` math
V(a, b, z) \approx e^{z}(-z)^{-(b - a)}.
```

In terms of solutions to our original linear ODE we let

``` math
P(\xi) = U(a, b, c\xi^2)
```

and

``` math
E(\xi) = e^{c\xi^2}U(b - a, b, -c\xi^2).
```

The solutions are then given by linear combinations of ``P`` and
``E``.

To get a better feeling for the asymptotic behavior. Let us look at
the case when ``d = 3``, ``\sigma = 1``, ``\epsilon = 0``, ``\omega =
1`` and ``\kappa`` is positive. We then have

``` math
a = \frac{1}{2}\left(1 + i \frac{1}{\kappa}\right),\quad
b = \frac{3}{2},\quad
c = -i\frac{\kappa}{2}.
```

This gives us

``` math
P(\xi) \approx z^{-a} = (c\xi^2)^{-a} \sim \xi^{-2a} = \xi^{-1 - i\frac{1}{\kappa}}
```

and

``` math
E(\xi) \approx e^{z}(-z)^{-(b - a)} = e^{c\xi^2}(-c\xi^2)^{-(b - a)} \sim e^{c\xi^2}\xi^{-2(b - a)}
= e^{-i\frac{\kappa}{2}\xi^2}\xi^{-2 + i\frac{1}{\kappa}}.
```

We can see that both ``P`` and ``E`` decay at infinity. However, ``E``
has exponentially increasing oscillations, which in this case stops it
from having finite energy. Since any solution to the linear ODE is
given by a linear combination of ``P`` and ``E``, the only way for
this solution to have finite energy is for the coefficient in front of
``E`` to be zero. This gives us our first approximation to
``Q_\infty``, namely

``` math
Q_\infty(\xi) \approx \gamma P(\xi)
```

for some ``\gamma \in \mathbb{C}``. This is, of course, not an exact
solution to the ODE, it neglects the non-linearity. The next step is
therefore to add a correction to this approximation to make it an
exact solution.

## Solution to full ODE

We can get an equation for the solution to the full ODE, including the
non-linear term, using the classical method of variation of
parameters. For this one treats the non-linearity as the right-hand
side in a non-homogeneous equation. Making the ansatz

``` math
Q_\infty(\xi) = c_1(\xi)P(\xi) + c_2(\xi)E(\xi)
```

one gets that ``c_1`` and ``c_2`` should satisfy

``` math
c_1' = -(1 + i\delta)|Q_\infty(\xi)|^{2\sigma}Q_\infty(\xi) \frac{E(\xi)}{(1 - i\epsilon)W(\xi)}
\text{ and }
c_2' = (1 + i\delta)|Q_\infty(\xi)|^{2\sigma}Q_\infty(\xi) \frac{P(\xi)}{(1 - i\epsilon)W(\xi)},
```

where ``W`` is the Wronskian associated with ``P`` and ``E``. To
simplify the notation we let

``` math
J_E(\xi) = -(1 + i\delta)\frac{E(\xi)}{(1 - i\epsilon)W(\xi)}
\text{ and }
J_P(\xi) = -(1 + i\delta)\frac{P(\xi)}{(1 - i\epsilon)W(\xi)}.
```

To satisfy the boundary conditions we want ``c_1`` to have a non-zero
limit at infinity and ``c_2`` to go to zero. It is therefore natural
to use the representations

``` math
\begin{align*}
  c_1(\xi) &= \gamma + \int_{\xi_1}^\xi J_E(\eta)|Q_\infty(\eta)|^{2\sigma}Q_\infty(\eta)\, d\eta,\\
  c_2(\xi) &= \int_{\xi}^\infty J_P(\eta)|Q_\infty(\eta)|^{2\sigma}Q_\infty(\eta)\, d\eta.
\end{align*}
```

We let ``I_E(\xi)`` and ``I_P(\xi)`` denote the integrals with ``J_E``
and ``J_P`` respectively. This gives us the following equation for
``Q_\infty``

``` math
Q_\infty(\xi) = \gamma P(\xi) + P(\xi)I_E(\xi) + E(\xi)I_P(\xi).
```

Note that both ``I_E`` and ``I_P`` themselves depend on the solution
``Q_\infty``, so this doesn't directly give us an expression for
``Q_\infty``. Instead, we introduce the operator

``` math
T(Q_\infty) = \gamma P(\xi) + P(\xi)I_E(\xi) + E(\xi)I_P(\xi).
```

We are then looking for fixed points of this operator. The first step
in computing enclosures of ``Q_\infty`` is therefore to prove the
existence of a fixed point for this operator, and give bounds for it.

## Existence of a fixed point

To prove the existence of a fixed point for ``T`` we need to be to
control the asymptotic behavior of ``P``, ``E``, ``J_P``, ``J_E``,
``I_P`` and ``I_E``. For ``P`` and ``E`` we have the following lemma

!!! note "Lemma (Bound for functions)"

    Let ``\xi_1 > 1``. Under certain assumptions on ``a``, ``b``, ``c``
    and ``\xi_1`` we have the bounds

    ``` math
    \begin{align*}
      |P(\xi)| &\leq C_{P}\xi^{-\frac{1}{\sigma}},\\
      |E(\xi)| &\leq C_{E}e^{\operatorname{Re}(c)\xi^{2}}\xi^{\frac{1}{\sigma} - d},\\
      |J_{P}(\xi)| &\leq C_{J_{P}}e^{-\operatorname{Re}(c)\xi^{2}}\xi^{-\frac{1}{\sigma} + d - 1},\\
      |J_{E}(\xi)| &\leq C_{J_{E}}\xi^{\frac{1}{\sigma} - 1}
    \end{align*}
    ```

    for all ``\xi \geq \xi_1``. The constants are explicitly computable,
    depending only on ``a``, ``b``, ``c`` and ``\xi_1``.

The proof of this is based on the asymptotic expansion of ``U``, with
explicit bounds for the remainder term, see
[Fungrim](https://fungrim.org/topic/Confluent_hypergeometric_functions/).
The same expansion is used in Flint for the evaluation of ``U``.

To get bounds for ``I_P`` and ``I_E`` we first need to decide on in
which space we are searching for a fixed point. Since we expect the
asymptotic behavior of ``Q_\infty`` to be determined by ``P``, which
decays as ``\xi^{-\frac{1}{\sigma}}``, and we are working on the
interval ``[\xi_1, \infty)`` it would be natural to use the norm

``` math
\|u\| = \sup_{\xi \geq \xi_1} \xi^{\frac{1}{\sigma}}|u(\xi)|.
```

However, when taking derivatives in ``\kappa`` we get extra
logarithmic factors and it is therefore better to use the norm

``` math
\|u\|_v = \sup_{\xi \geq \xi_1} \xi^{\frac{1}{\sigma} - v}|u(\xi)|.
```

for some small ``v > 0``.

We can then bound ``I_P`` and ``I_E`` in terms of this norm.

!!! note "Lemma (Bound for ``I_P`` and ``I_E``)"

    Assume that ``\xi_1 > 1``, ``v \geq 0`` and ``\operatorname{Re}(c)
    \geq 0`` and that the following inequalities are satisfied

    ``` math
    (2\sigma + 1)v - 2 < 0
    \text{ and }
    (2\sigma + 1)v - \frac{2}{\sigma} + d - 2 < 0.
    ```

    Then, for ``\xi \geq \xi_1`` we have the following bounds

    ``` math
    \begin{align*}
      |I_{P}(\xi)| &\leq C_{I_{P}}\|Q_{\infty}\|_{v}^{2\sigma + 1}e^{-\operatorname{Re}(c)\xi^{2}}\xi^{(2\sigma + 1)v - \frac{2}{\sigma} + d - 2},\\
      |I_{E}(\xi)| &\leq C_{I_{E}}\|Q_{\infty}\|_{v}^{2\sigma + 1}\xi_{1}^{(2\sigma + 1)v - 2},
    \end{align*}
    ```

    where

    ``` math
    C_{I_P} = \frac{C_{J_P}}{|(2\sigma + 1)v - \frac{2}{\sigma} + d - 2|}
    \text{ and }
    C_{I_E} = \frac{C_{J_E}}{|(2\sigma + 1)v - 2|}.
    ```

!!! note "Proof"
    We give the proof for ``I_{E}``, the proof for ``I_{P}`` is similar.
    To begin with we note that

    ``` math
    |I_{E}(\xi)| \leq \int_{\xi_1}^\infty |J_E(\eta)||Q_\infty(\eta)|^{2\sigma + 1}\, d\eta.
    ```

    From the above lemma we have

    ``` math
    |J_E(\eta)| \leq C_{J_{E}}\eta^{\frac{1}{\sigma} - 1}.
    ```

    Furthermore, we have

    ``` math
    |Q_\infty(\eta)| \leq \|Q_\infty\|_v \eta^{-\frac{1}{\sigma} + v},
    ```

    giving us

    ``` math
    |Q_\infty(\eta)|^{2\sigma + 1} \leq \|Q_\infty\|_v^{2\sigma + 1} \eta^{(2\sigma + 1)v - \frac{1}{\sigma} - 2}.
    ```

    Inserted into the integral we get

    ``` math
    |I_{E}(\xi)| \leq C_{J_E}\|Q_\infty\|_v^{2\sigma + 1}\int_{\xi_1}^\infty \eta^{(2\sigma + 1)v - 3}\, d\eta.
    ```

    The integral can be bounded by

    ``` math
    \int_{\xi_1}^\infty \eta^{(2\sigma + 1)v - 3}\, d\eta \leq \frac{1}{|(2\sigma + 1)v - 2|}\xi_1^{(2\sigma + 1)v - 2},
    ```

    giving us the result.

From this it is straightforward to prove the following bound for ``T``.

!!! note "Lemma (Bound for ``T``)"
    Under the assumptions of the previous lemma, we have

    ``` math
    \|T(Q_\infty)\|_v \leq C_P|\gamma|\xi_1^{-v} + C_T\xi_1^{-2 + 2\sigma v}\|Q_\infty\|_v^{2\sigma + 1}
    ```

    and

    ``` math
    \|T(u) - T(v)\|_v \leq M_\sigma C_T \|u - v\|_v (\|u\|_v^{2\sigma} + \|v\|_v^{2\sigma}),
    ```

    with ``C_T = C_PC_{I_E} + C_EC_{I_P}`` and a constant ``M_\sigma``
    depending only on ``\sigma``.

This gives us all the ingredients to set up a fixed point problem. The
above estimates shows that ``T`` is a contraction of the ball ``B_\rho
= \{u: \|u\|_v \leq \rho\}`` into itself if ``\rho`` satisfies

``` math
\begin{align}
  C_P|\gamma|\xi_1^{-v} + C_T\xi_1^{-2 + 2\sigma v}\|Q_\infty\|_v^{2\sigma + 1} &\leq \rho,\\
  2M_\sigma C_T\xi_1^{-2 + 2\sigma v}\rho^{2\sigma} &< 1.
\end{align}
```

It then follows from the Banach fixed point theorem that ``T`` has a
unique fixed point in the ball ``B_\rho``. This gives us both the
existence of a solution and also bounds on the ``\|\cdot\|_v`` norm of
the solution! However, to be able to compute good enclosures of
``Q_\infty``, just having bounds on its norm is not enough!

## Enclosures for fixed point

A bound for the norm of ``Q_\infty`` is only the first step. Next we
need to use this bound to get better enclosures.

From the fixed point equation we have

``` math
Q_\infty(\xi) = \gamma P(\xi) + P(\xi)I_E(\xi) + E(\xi)I_P(\xi).
```

In practice we are only interested in computing the value at ``\xi =
\xi_1``. We can note that ``I_E(\xi_1) = 0``, hence

``` math
Q_\infty(\xi_1) = \gamma P(\xi_1) + E(\xi_1)I_P(\xi_1).
```

We can compute enclosures of ``P`` and ``E`` using the implementation
of ``U`` in Flint. For ``I_P`` we can combine the above lemma with
the bound for ``\|Q_\infty\|_v`` to get a bound for ``|I_P(\xi_1)|``.

With the above approach we get a somewhat decent enclosure of
``Q_\infty(\xi_1)``. However, for the proof to go through we need
better enclosures than that. These improved bounds are based on
integration by parts in ``I_P``, which gives fairly lengthy
calculations.

In addition, we also need bounds for the derivatives, both with
respect to ``\xi`` and with respect to ``\gamma`` and ``\kappa``. In
the end we have to compute bounds for

``` math
\begin{align*}
  Q'(\xi)
  &= \gamma P'(\xi)
    + P'(\xi)I_{E}(\xi) + P(\xi)I_{E}'(\xi)
    + E'(\xi)I_{P}(\xi) + E(\xi)I_{P}'(\xi),\\
  Q_{\gamma}(\xi)
  &= P(\xi)
    + P(\xi)I_{E,\gamma}(\xi)
    + E(\xi)I_{P,\gamma}(\xi),\\
  Q_{\gamma}'(\xi)
  &= P'(\xi)
    + P'(\xi)I_{E,\gamma}(\xi)
    + P(\xi)I_{E,\gamma}'(\xi)
    + E'(\xi)I_{P,\gamma}(\xi)
    + E(\xi)I_{P,\gamma}'(\xi),\\
  Q_{\kappa}(\xi)
  &= \gamma P_{\kappa}(\xi)
    + P_{\kappa}(\xi)I_{E}(\xi)
    + P(\xi)I_{E,\kappa}(\xi)\\
  &\quad+ E_{\kappa}(\xi)I_{P}(\xi)
    + E(\xi)I_{P,\kappa}(\xi),\\
  Q_{\kappa}'(\xi)
  &= \gamma P_{\kappa}'(\xi)\\
  &\quad+ P_{\kappa}'(\xi)I_{E}(\xi)
    + P_{\kappa}(\xi)I_{E}'(\xi)
    + P'(\xi)I_{E,\kappa}(\xi)
    + P(\xi)I_{E,\kappa}'(\xi)\\
  &\quad+ E_{\kappa}'(\xi)I_{P}(\xi)
    + E'(\xi)I_{P,\kappa}(\xi)
    + E_{\kappa}(\xi)I_{P}'(\xi)
    + E(\xi)I_{P,\kappa}'(\xi).
\end{align*}
```

Some of these are relatively easy, others require more work. That is
however outside the scope of these notes.
