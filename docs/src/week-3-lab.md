# Week 3 Lab: A simple computer-assisted proof (and VS Code)

The goal of this lab is to reproduce a simple [computer-assisted proof
by Alex and Mitch](https://doi.org/10.1063/5.0054122). In doing so we
will use VS Code in order to get used to working with Julia from that
interface.

## VS Code setup

1. Start VS Code
2. Open the course folder. You can find **Open Folder** under
   **File** (shortcut Ctrl-K Ctrl-O).
3. Create a new file `lab-3.jl` in the directory `scratch/labs` (which
   you will have to create). You can find **New File** under **File**
   (shortcut Ctrl-Alt-Super-N).
4. Copy the following code into the file

   ``` julia
   using Arblib

   x = Arb(π)
   y = Arb(3)

   println(x)
   ```

There are multiple different ways to run the code in the file.

1. Execute entire file in a separate process. Use the shortcut
   Ctrl-F5.
2. Execute entire file in REPL. Press the arrow in the top right
   corner.
3. Execute the current line in the REPL. Use the shortcut Ctrl-Enter.
   You can also select multiple lines and it will execute all of them.
4. Execute the current line in the REPL and move to the next line. Use
   the shortcut Shift-Enter.

Try all of them and see how they work! Which of these alternatives is
best depends on your workflow. In my case I almost exclusively make
use of alternatives 3 and 4.

For this lab we will write all of our code inside this one file and
use the above commands for running it. For larger projects it is
usually a good idea to split the work into multiple files and in many
cases it is beneficial to structure the project like a Julia package.
We will get back to this later in the course.

## A simple computer-assisted proof

Our goal will be to prove Proposition II.2 in paper mentioned above.
For this we need the following polynomial

``` math
P = 1 - 3\alpha^2 + \alpha^4 - \frac{111}{49}\alpha^6 + \frac{143}{294}\alpha^8 - \frac{7536933}{11957764}\alpha^{10} \allowbreak + \frac{4598172331}{47460365316}\alpha^{12} - \frac{30028809212865451}{520327364608478700}\alpha^{14} \allowbreak + \frac{49750141858992227}{12487856750603488800}\alpha^{16}
```

and the function

``` math
E(\alpha) = \frac{6\alpha^9}{15 - 20\alpha} \left( 1 + \sqrt{3}\alpha + \sqrt{2}\alpha^2 + \frac{\sqrt{14}}{7}\alpha^3 + \frac{\sqrt{258}}{42}\alpha^4 + \frac{\sqrt{1968837}}{3458}\alpha^5 + \frac{\sqrt{106525799}}{31122}\alpha^6 + \frac{2\sqrt{2129312323981473}}{624696345}\alpha^7 + \frac{\sqrt{183643119755214454}}{4997570760}\alpha^8 \right) + \frac{9\alpha^{18}}{(15 - 20\alpha)^2}
```

We want to prove the following proposition

!!! note "Proposition"
    The function ``P(\alpha) + E(\alpha)`` is negative at ``\alpha =
    0.61`` and the function ``P(\alpha) + E(\alpha)`` is positive at
    ``\alpha = 0.57``.

What they are actually trying to prove in the paper is that a function
``v(\alpha)`` has a zero on the interval ``[0.57, 0.61]``. The
polynomial ``P`` is an approximation of ``v`` and ``E(\alpha)`` gives
an upper bound of the error for the approximation.

!!! note
    The proof in the paper is not quite rigorous. It uses regular
    floating points together with results that gives you bound on the
    rounding errors for evaluating polynomials with floating points.
    It does however not quite account for all the places where
    rounding errors are introduced.

    Moreover, the expression for ``E(\alpha)`` seems to not quite be
    correct. This is being looked into.

### A not quite correct implementation

Our first task will be to implement ``P`` and ``E`` in Julia. A direct
(but as we will see slightly problematic) conversion of the above
expressions for ``P`` and ``E`` to Julia is given below. You can copy
the code into your `lab-3.jl` file (you can also remove what is
already there if you want).

``` @example 1
P(α) =
    1 - 3α^2 + α^4 - 111 / 49 * α^6 + 143 / 294 * α^8 - 7536933 / 11957764 * α^10 +
    4598172331 / 47460365316 * α^12 - 30028809212865451 / 520327364608478700 * α^14 +
    49750141858992227 / 12487856750603488800 * α^16

E(α) =
    6α^9 / (15 - 20α) * (
        1 +
        sqrt(3) * α +
        sqrt(2) * α^2 +
        sqrt(14) / 7 * α^3 +
        sqrt(258) / 42 * α^4 +
        sqrt(1_968_837) / 3458 * α^5 +
        sqrt(106_525_799) / 31_122 * α^6 +
        2sqrt(2_129_312_323_981_473) / 624_696_345 * α^7 +
        sqrt(183_643_119_755_214_454) / 4_997_570_760 * α^8
    ) + 9α^18 / (15 - 20α)^2
```

We can now implement functions computing lower and upper bounds of
``v`` as

``` @example 1
v_lower(α) = P(α) - E(α)
v_upper(α) = P(α) + E(α)
```

Try evaluating `v_lower` at ``\alpha = 0.57`` and `v_upper` at
``\alpha = 0.61``. You should get

``` @repl 1
v_lower(0.57)
v_upper(0.61)
```

One can show (which we will soon do) that

``` math
P(0.57) - E(0.57) = 0.02857494349754851842380087961496259058289166470274019410736704418784480353\dots
```

and

``` math
P(0.61) + E(0.61) = -0.018830737780969134528206854817563710242534970158515810047488029826855742148\dots.
```

To what extent do your computed values above agree with these values?
If they disagree, what could be the reason? We can also evaluate the
functions to higher precision in Julia using `BigFloat`, Julia's
standard type for arbitrary precision floating points.

``` @repl
v_lower(BigFloat(0.57))
v_upper(BigFloat(0.61))
```

To what extent do these values agree with the above given ones? What
could be the reason for them not agreeing?

### An improved implementation

The issue with the above implementation of ``P(\alpha)`` and
``E(\alpha)`` is that Julia by default uses `Float64` for numerical
computations unless told otherwise. This happens for example when
dividing integers with each other and when computing square roots of
integers.

``` @repl
1 / 3
sqrt(2)
```

To make our implementation of ``P`` and ``E`` work for rigorous
numerics we need to make sure that all intermediate computations are
also done in a rigorous way. For integer division one way of achieving
this is to represent the coefficient as a rational number, which is an
exact representation.

``` @repl
1 / 3 # Performs floating point arithmetic
1 // 3 # Represents it as a rational number
```

This plays well with for example `BigFloat` (and rigorous numerics as
well)

``` @repl
(1 / 3) * BigFloat(3) # Not close to 1
(1 // 3) * BigFloat(3) # Very close to 1
```

Let us define a new function `P_correct` which represents the
coefficients as rational numbers.

``` @example 1
P_correct(α) =
    1 - 3α^2 + α^4 - 111 // 49 * α^6 + 143 // 294 * α^8 - 7536933 // 11957764 * α^10 +
    4598172331 // 47460365316 * α^12 - 30028809212865451 // 520327364608478700 * α^14 +
    49750141858992227 // 12487856750603488800 * α^16
```

For the square roots we don't have a way of exactly representing the
values (at least not without using any external package). Instead we
take the approach of converting the integer to the right type before
computing the square root.

``` @repl
BigFloat(sqrt(2))^2 # This gives large errors
sqrt(BigFloat(2))^2 # This is very precise
```

For the function `E` the type we want to convert the integers is given
by the type of the argument `α`. For this you can use the function
`oftype`.

``` @repl
a = BigFloat(2)
oftype(a, 1 // 3) # Convert 1 // 3 to the type of a
```

Using this for `E` we get

``` @example 1
E_correct(α) =
    6α^9 / (15 - 20α) * (
        1 +
        sqrt(oftype(α, 3)) * α +
        sqrt(oftype(α, 2)) * α^2  +
        sqrt(oftype(α, 14)) / 7 * α^3  +
        sqrt(oftype(α, 258)) / 42 * α^4  +
        sqrt(oftype(α, 1_968_837)) / 3458 * α^5  +
        sqrt(oftype(α, 106_525_799)) / 31_122 * α^6  +
        2sqrt(oftype(α, 2_129_312_323_981_473)) / 624_696_345 * α^7  +
        sqrt(oftype(α, 183_643_119_755_214_454)) / 4_997_570_760 * α^8
    ) + 9α^18 / (15 - 20α)^2
```

Note that we are not converting the integers we are dividing by. Why
do we not need to do that?

Let us finally define

``` @example 1
v_lower_correct(α) = P_correct(α) - E_correct(α)
v_upper_correct(α) = P_correct(α) + E_correct(α)
```

After this we can now compute

``` @repl 1
v_lower_correct(BigFloat(0.57))
v_upper_correct(BigFloat(0.61))
```

How does this compare to the values given above? What is the issue
now?

The last issue comes from using the constants `0.57` and `0.61`. We have

``` @repl
BigFloat(0.57)
BigFloat(0.61)
BigFloat("0.57")
BigFloat("0.61")
```

Finally we thus compute

``` @repl 1
v_lower_correct(BigFloat("0.57"))
v_upper_correct(BigFloat("0.61"))
```

Now it should agree with the values given above!

!!! note
    This last fix, using `BigFloat("0.57")` instead of
    `BigFloat(0.57)`, is not strictly necessary for a
    computer-assisted proof. There is nothing special about the value
    ``0.57 = 57 / 100``, we could just as well use the value
    ``0.56999999999999995115018691649311222136020660400390625`` which
    is the exact value for the `Float64` number that is closest to
    ``0.57 = 57 / 100``. Of course, the statement in the paper would
    look slightly awkward: "it is positive at ``\alpha =
    0.56999999999999995115018691649311222136020660400390625``" doesn't
    look quite as nice as "it is positive at ``\alpha = 0.57``"

### A computer-assisted proof

So far we have of course not proved anything, we have still only
evaluated the functions using floating point arithmetic which will
give us rounding errors. With the `P_correct` and `E_correct`
implementations it is however very straightforward to fully prove the
result. For this we will use the Arblib.jl package which implements
one type of interval arithmetic. To load the package you can add this
to the top of your file (it doesn't **have** to be at the top, but you
usually put packages there)

``` @example 1
using Arblib
```

We can now evaluate our functions using interval arithmetic

``` @repl 1
v_lower_correct(Arb("0.57"))
v_upper_correct(Arb("0.61"))
```

This gives us fully rigorous enclosures for the values. From these
enclosures we immediately see that ``P(0.57) - E(0.57)`` is positive
and ``P(0.61) + E(0.61)`` is negative. We have thus finished the
proof!

### Bonus: Tighten enclosure of root

So far we have proved that there is a root in the interval ``[0.57,
0.61]``. Can you compute a tighter enclosure of the root?
