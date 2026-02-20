### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 75abe79d-42fe-4783-8824-b0d97e274528
begin
    using Pkg
    Pkg.activate(".", io = devnull)
    using CAPCourseS26
    using Arblib
    using PlutoUI
    using Plots

    using CAPCourseS26:
        from_a_b, to_a_b, to_a_fix_b, add_rnd, sub_rnd, mul_rnd, div_rnd, fma_rnd

    setprecision(Arb, 16)
end

# ╔═╡ 71a07cd4-0e73-11f1-b14a-9f334b1da489
md"""
# Lab 5: Playing with floating points
This notebook is part of Lab 5, see the package documentation for more details about the lab.
"""

# ╔═╡ 1122506b-a668-43ea-886b-1d40bb7eca21
md"""
This is the first time we will directly use the `CAPCourseS26.jl` Julia package. Since this is not a registered package we can't directly do `using CAPCOurseS26`. Instead we have to activate the right package environment before we load it.
"""

# ╔═╡ 2a914979-58a9-4738-a18f-353612062ddd
TableOfContents()

# ╔═╡ 3e0dadf4-3bd7-4d5f-911e-d676caf90d55
md"""
## Setup

When working with floating points we will use the `Arf` type from
`Arblib.jl`. With a little bit of extra work this type gives us full
control over precision and rounding. The precision used can be set
with `setprecision(Arb, p)` and is currently set to
"""

# ╔═╡ 20d42d03-bff3-4201-9d87-69967205aada
precision(Arb)

# ╔═╡ 15ffa201-fefb-4d80-b333-9f0723d86be2
md"""
### `from_a_b` and `to_a_b`

To make things simpler we have defined a number of helper functions in
`CAPCourseS26.jl`. The first two are `from_a_b` and `to_a_b`,
`from_a_b(a, b)` returns the Arf value corresponding to `a * 2^b` and
`to_a_b(x)` returns integers `a` and `b` so that `a * 2^b = x`.
"""

# ╔═╡ 042ce3d5-5c21-458a-9672-29b1e8c6fb38
from_a_b(5, 0)

# ╔═╡ b434e38a-c5e0-4b8a-abec-1577a65ffba4
to_a_b(from_a_b(5, 0))

# ╔═╡ 9e154c6e-a423-4195-9445-764dd16dfc96
md"""
The function `from_a_b(a, b)` will by default round the result to the
nearest floating point of the given precision. If you give the
`verbose = true` flag and the value cannot be exactly represented it
prints a log message saying that it was rounded
"""

# ╔═╡ 0d1a77e1-c7d6-48bf-98de-21b140ecebc4
from_a_b(2^16 + 1, 0, verbose = true)

# ╔═╡ 6b3e5c36-4ff0-4e86-ad7d-84808a43a663
to_a_b(from_a_b(2^16 + 1, 0))

# ╔═╡ 08452846-dd5b-4bcb-8e1b-75116aa1457f
md"""
The rounding can be specified by giving a third argument that
specified the rounding mode. 
"""

# ╔═╡ d2d9f1bb-4a0f-4e99-aff3-dd614f51c376
to_a_b(from_a_b(2^16 + 1, 0, RoundDown, verbose = true))

# ╔═╡ d3e0d711-9901-48a3-b09c-538582fc0df1
to_a_b(from_a_b(2^16 + 1, 0, RoundUp, verbose = true))

# ╔═╡ e2bb3fc2-97f0-4167-ba15-c1e166c901eb
to_a_b(from_a_b(2^16 + 1, 0, RoundNearest, verbose = true))

# ╔═╡ 8ece2c35-5b6c-4115-85bb-07c4c1622c8e
md"""
To make it easier to compare numbers it is often convenient to use a
representation that has the same exponent for the two numbers. The
`to_a_fix_b` function can be used for that. 
"""

# ╔═╡ 505a746f-9934-45b0-ab04-9d1fa7fced5f
to_a_fix_b(from_a_b(2^16 + 1, 0, RoundDown), 1)

# ╔═╡ d31ce547-225e-4330-b1e9-a9880a873e9e
to_a_fix_b(from_a_b(2^16 + 1, 0, RoundUp), 1)

# ╔═╡ 39f8fcbc-852e-4b90-a956-9e1c85c98222
md"""
It throws an error if ``a`` would not be an integer with the specified ``b``
"""

# ╔═╡ 60ec4de3-6ace-486b-8af6-9cf599213a77
to_a_fix_b(Arf(1), 1)

# ╔═╡ 92fd8a0c-2f01-418d-92c3-2d33eb59e37e
md"""
### Rounded arithmetic

We have also implemented the functions `add_rnd, sub_rnd, mul_rnd,
div_rnd, fma_rnd`. They take as input `Arf` values and a rounding mode
and return the result rounding according to the rounding mode. They
also take the `verbose = true` flag for printing a log message if the
result was rounded.
"""

# ╔═╡ 4480b2f4-b20b-4c82-83db-a48e9ba74e16
add_rnd(from_a_b(1, 0), from_a_b(1, 0), RoundNearest, verbose = true)

# ╔═╡ 26ca6626-da4b-457c-886f-b0b076ea550d
mul_rnd(from_a_b(2, 0), from_a_b(3, 0), RoundNearest, verbose = true)

# ╔═╡ 3bb6b846-704b-4e24-aa9d-3cb3db48e576
div_rnd(from_a_b(2, 0), from_a_b(3, 0), RoundNearest, verbose = true)

# ╔═╡ c551c661-aedf-40d2-a0c0-5fb372371bc1
to_a_b(div_rnd(from_a_b(2, 0), from_a_b(3, 0), RoundNearest, verbose = true))

# ╔═╡ 7cab8606-b52e-4e91-9f8e-b266165f6094
md"""
## Working with rounded arithmetic
"""

# ╔═╡ 343c8dfd-4cff-44e6-8492-ebea01fd1317
md"""
### Machine epsilon

One definition of machine epsilon is that it is the smallest number
you can add to 1 and still get a value larger than one (assuming round
to nearest). 
"""

# ╔═╡ 699f8161-b682-4cc3-9f4e-f175279ddfe4
epsilon = from_a_b(1, -10)

# ╔═╡ af0cfd3b-f45c-40cd-8295-32d6107a3c82
one_plus_epsilon = add_rnd(Arf(1), epsilon, RoundNearest)

# ╔═╡ 07c94456-f071-4c8e-9701-c4ee70704165
one_plus_epsilon > 1

# ╔═╡ a59dacab-0aa9-4723-ac4c-1d19ffb7fd0d
to_a_b(one_plus_epsilon)

# ╔═╡ e9d8c5fc-36b5-4308-8072-5aa2b303ee19
string(one_plus_epsilon, digits = 100)

# ╔═╡ 8e37f70a-380d-4652-966c-17b01729e281
md"""
What happens if you change the `RoundNearest` to `RoundUp`?
`RoundDown`?
"""

# ╔═╡ d62d6795-5038-40dc-a560-8b40cf09a737
md"""
### Rounding for compositions

We don't have a function for directly computing ``x^3`` that gives us
a correctly rounded result. We can compute `x * x * x`, but that
rounds twice. Getting a correctly rounded result can be difficult. We
cat however easily get an upper or lower bound if we are fine with it
not being the tightest one. The following function computes an upper
bound of ``x^3``
"""

# ╔═╡ 417bdaa2-aa3a-43dd-9c81-05693af3d560
function cube_upper(x::Arf)
    return mul_rnd(mul_rnd(x, x, RoundUp), x, RoundUp)
end

# ╔═╡ b169b4a8-f4e7-4723-8aa5-c84ac298a845
md"""
TASK: Implement the same version that rounds down
"""

# ╔═╡ 8502cbd0-9773-4bd6-905d-3f1cde084f97
function cube_lower(x::Arf)
    return mul_rnd(mul_rnd(x, x, RoundDown), x, RoundDown)
end

# ╔═╡ b7c7e917-7986-4a4f-9861-e704f9e0a206
to_a_fix_b(cube_upper(from_a_b(12313, 0)), 25)

# ╔═╡ bc699ac2-0a04-43c2-8b5d-0220c178ce71
to_a_fix_b(cube_lower(from_a_b(12313, 0)), 25)

# ╔═╡ cf6d6008-0d53-433a-b6ad-1391f2b0cb7b
to_a_fix_b(from_a_b(12313^3, 0, RoundUp), 25) # Correctly rounded

# ╔═╡ 385d8fe8-fc19-4db8-98fb-24c1f7c18449
to_a_fix_b(from_a_b(12313^3, 0, RoundDown), 25) # Correctly rounded

# ╔═╡ 88dcfb77-f947-4903-81da-53d8ac1f5b4d
md"""
## Poor mans interval arithmetic

Let us consider the problem of computing ``\sin`` in floating point
arithmetic. We will not implement a **correctly rounded** version,
this is too hard. Instead we will implement a version that is
guaranteed to give a lower bound and another version which is
guaranteed to give an upper bound, but with not guarantees of these
being the tightest possible lower and upper bounds.
"""

# ╔═╡ fc40012d-9d75-4f61-a44e-6bf0feeac544
md"""
Let us consider the problem of computing ``\sin`` in floating point
arithmetic. We will not implement a **correctly rounded** version,
this is too hard. Instead we will implement a version that is
guaranteed to give a lower bound and another version which is
guaranteed to give an upper bound, but with not guarantees of these
being the tightest possible lower and upper bounds.

We will consider the case when ``x \in [0, \pi/4)`` and we will use
the following Taylor expansion for ``\sin``

``` math
\sin(x) = x - \frac{x^3}{3!} + \frac{x^5}{5!} + R_7(x)
```

Where

``` math
R_7(x) = \frac{-\cos(\xi)}{7!}x^7
```

for some ``\xi \in (0, x)``.
"""

# ╔═╡ 6c67677a-e594-47e5-839e-5fe9235564a4
md"""
Let us start with a simple bound for ``R_7``. Since ``x < 1/2``
and ``\cos(\xi) \in [0, 1]`` we get

``` math
-\frac{1}{7!} \cdot 2^{-7} \leq R_7(x) \leq 0
```
"""

# ╔═╡ 76f167ea-099a-4cb3-9752-6fb2da2366dc
md"""
Since ``R_7(x) \leq 0`` we get that just evaluating the polynomial
directly gives us an upper bound for ``\sin(x)``. A naive
implementation would be
"""

# ╔═╡ 0e531182-0ba4-4b25-a316-ae7335c40ced
function sin_upper_wrong(x::Arf)
    return x - x^3 / factorial(3) + x^5 / factorial(5)
end

# ╔═╡ 0066b806-3631-4460-95d9-aa4d3e409e2d
md"""
And for the lower bound a naive version would be
"""

# ╔═╡ 64ca13d7-c011-49f2-bc34-8fe6d88228e8
function sin_lower_wrong(x::Arf)
    return x - x^3 / factorial(3) + x^5 / factorial(5) - Arf(1) / factorial(7)
end

# ╔═╡ 9ac0749e-77e9-4be5-b379-9fe3b86fc7fc
to_a_b(sin_upper_wrong(Arf(0.1)))

# ╔═╡ 8045a682-7693-49cc-969c-fe0fd9f9ae6f
to_a_b(sin_lower_wrong(Arf(0.1)))

# ╔═╡ 7ce6f30d-48d3-40d1-b9f0-de3382e78065
md"""
The issue with these implementations is that they don't take into
account rounding errors from the evaluation of the polynomial. Our
goal will be to fix this!

To make the notation a bit simpler we will use ``\Delta`` and
``\nabla`` to denote rounding up and down respectively, but not
necessarily to the nearest floating point. So ``\Delta(x + y)`` can
represent any floating point that is larger than or equal to ``x +
y``. To compute an upper bound of ``\sin(x)`` we then need to compute

``` math
\Delta\left(x - \frac{x^3}{3!} + \frac{x^5}{5!}\right).
```

We don't know how to directly compute this using floating points. As a
first step we can however see that it suffices to compute

``` math
\Delta\left(x + \Delta\left(-\frac{x^3}{3!}\right) + \Delta\left(\frac{x^5}{5!}\right)\right).
```

The two outer additions we do know how to do! The following code uses
this idea, but doesn't yet handle the last two terms correctly.
"""

# ╔═╡ b3d5d29b-ae96-4829-83bb-eea29f5c4f9a
function sin_upper(x::Arf)
    term1 = x
    # TODO: These are not yet rounded correctly!
    term2_upper = -x^3 / factorial(3)
    term3_upper = x^5 / factorial(5)

    return add_rnd(add_rnd(term1, term2_upper, RoundUp), term3_upper, RoundUp)
end

# ╔═╡ 3857726a-44b1-41a6-97ef-eb7729c14d9c
md"""
For the lower bound we want to compute

``` math
\nabla\left(x - \frac{x^3}{3!} + \frac{x^5}{5!} - \frac{1}{7!} \cdot 2^{-7}\right),
```

which we can do as

``` math
\nabla\left(x + \nabla\left(-\frac{x^3}{3!}\right) + \nabla\left(\frac{x^5}{5!}\right) + \nabla\left(-\frac{1}{7!} \cdot 2^{-7}\right)\right),
```

an implementation of this is give by
"""

# ╔═╡ 3aebbcf4-6355-4371-bb82-515cb24aebed
function sin_lower(x::Arf)
    term1 = x
    # TODO: These are not yet rounded correctly!
    term2_lower = -x^3 / factorial(3)
    term3_lower = x^5 / factorial(5)
    R_lower = -1 / from_a_b(factorial(7), 7)

    return add_rnd(
        add_rnd(add_rnd(term1, term2_lower, RoundDown), term3_lower, RoundDown),
        R_lower,
        RoundDown,
    )
end

# ╔═╡ a652cc32-77a6-46df-a098-6c5ce1421a7b
md"""
Our goal will be to fix the two TODOs! You can approach this problem
in any order your want, but here is one order that could work well.

1. Figure out how to compute lower and upper bounds of ``x^3``. Hint:
   Use `mul_rnd` multiple times.
2. Figure out how to compute lower and upper bounds when dividing
   ``x^3`` by ``3!``. Hint: ``3!`` is exactly representable in our
   precision.
3. Use this to compute upper and lower bounds of ``-\frac{x^3}{3!}``.
   Hint: How does the minus sign affect the order we have to round?
4. Do the same for ``\frac{x^5}{5!}``.
5. Handle ``-\frac{1}{7!} \cdot 2^{-7}`` as well. Hint:
   `from_a_b(factorial(7), 7)` is exact!
"""

# ╔═╡ 728548c1-8b96-427d-9c97-c47695045c85
md"""
To help with testing we have
the following two functions that compute correctly rounded lower and
upper bounds of ``\sin`` (in practice at least, they haven't been
proved to do so).
"""

# ╔═╡ 56da7a87-c6d8-4e45-b299-3f20d2ef2a3a
function sin_upper_correct(x::Arf)
    y = midpoint(sin(Arb(x, prec = 8precision(x))))
    res = Arf()
    Arblib.set_round!(res, y, rnd = RoundUp)
    return res
end

# ╔═╡ bacffa4d-a61e-4e32-9044-85e12abc4d45
function sin_lower_correct(x::Arf)
    y = midpoint(sin(Arb(x, prec = 8precision(x))))
    res = Arf()
    Arblib.set_round!(res, y, rnd = RoundDown)
    return res
end

# ╔═╡ f991d3d5-26e4-49ca-b06c-46ebb49a547b
md"""
The following is a list of evenly spaced floating point numbers
between 0 and 0.5, we can test our input on these numbers.
"""

# ╔═╡ baf46c35-8bbd-4f86-8ef5-19436d19bbe4
xs = from_a_b.(1:(2^16), -17)

# ╔═╡ fdabbb7b-ffb6-4a12-abba-c12a26327844
md"""
Here are some plots that might interesting to look at!
"""

# ╔═╡ e66558c6-090b-4149-a3db-42398cccadc1
md"""
Direct plot of values (can't see too much)
"""

# ╔═╡ 9aa5c8f6-335a-4f1b-86d2-8e6374156f57
let
    plot(Float64.(xs), Float64.(sin_lower.(xs)))
    plot!(Float64.(xs), Float64.(sin_upper.(xs)))
    plot!(Float64.(xs), sin.(Float64.(xs)))
end

# ╔═╡ 7ff202f0-a8ef-4b6d-923b-96fdd54cc6a3
md"""
Difference between lower and upper bounds
"""

# ╔═╡ 585a0a0b-497a-4c89-beff-2a83ddfc4f53
scatter(Float64.(xs), Float64.(sin_upper.(xs)) - Float64.(sin_lower.(xs)))

# ╔═╡ 84f8b0aa-bd3b-48d8-936b-0620dd2e2125
md"""
Difference between correct lower bound and wrong lower bound
"""

# ╔═╡ 11014351-a6da-44eb-b2c2-26e9da8122b4
scatter(Float64.(xs), Float64.(sin_lower_wrong.(xs)) - Float64.(sin_lower.(xs)))

# ╔═╡ 358a6c16-dabe-47b6-9d90-89c88695da40
md"""
Difference between lower bound and correct lower bound
"""

# ╔═╡ 86d59c91-7094-4595-b2f0-e536f853e845
scatter(Float64.(xs), Float64.(sin_lower_correct.(xs)) - Float64.(sin_lower.(xs)))

# ╔═╡ 68dfd4f5-09ad-481e-9974-534e5d9bfbe8
md"""
Difference between upper bound and wrong upper bound
"""

# ╔═╡ 6a0302f6-4cd4-43a3-ab5b-4ed3eb463787
scatter(Float64.(xs), Float64.(sin_upper.(xs)) - Float64.(sin_upper_wrong.(xs)))

# ╔═╡ a8d8cc2a-e449-4043-bca5-948c13972d1d
md"""
Difference between upper bound and correct upper bound
"""

# ╔═╡ b70232f2-6fb3-4d5d-88b9-e81766134e7a
scatter(Float64.(xs), Float64.(sin_upper.(xs)) - Float64.(sin_upper_correct.(xs)))

# ╔═╡ 18efc5f8-99ec-41a4-9f64-3ddc0dfd7458
md"""
### Bonus: Improve bounds

There are a couple of ways to improve the bounds we have computed so
far

1. Use a higher degree expansion.
2. Compute tighter bounds for the remainder term ``R_7(x)``.
3. Reduce rounding errors by for example using `fma`.
"""

# ╔═╡ Cell order:
# ╟─71a07cd4-0e73-11f1-b14a-9f334b1da489
# ╟─1122506b-a668-43ea-886b-1d40bb7eca21
# ╠═75abe79d-42fe-4783-8824-b0d97e274528
# ╠═2a914979-58a9-4738-a18f-353612062ddd
# ╟─3e0dadf4-3bd7-4d5f-911e-d676caf90d55
# ╠═20d42d03-bff3-4201-9d87-69967205aada
# ╟─15ffa201-fefb-4d80-b333-9f0723d86be2
# ╠═042ce3d5-5c21-458a-9672-29b1e8c6fb38
# ╠═b434e38a-c5e0-4b8a-abec-1577a65ffba4
# ╟─9e154c6e-a423-4195-9445-764dd16dfc96
# ╠═0d1a77e1-c7d6-48bf-98de-21b140ecebc4
# ╠═6b3e5c36-4ff0-4e86-ad7d-84808a43a663
# ╟─08452846-dd5b-4bcb-8e1b-75116aa1457f
# ╠═d2d9f1bb-4a0f-4e99-aff3-dd614f51c376
# ╠═d3e0d711-9901-48a3-b09c-538582fc0df1
# ╠═e2bb3fc2-97f0-4167-ba15-c1e166c901eb
# ╟─8ece2c35-5b6c-4115-85bb-07c4c1622c8e
# ╠═505a746f-9934-45b0-ab04-9d1fa7fced5f
# ╠═d31ce547-225e-4330-b1e9-a9880a873e9e
# ╟─39f8fcbc-852e-4b90-a956-9e1c85c98222
# ╠═60ec4de3-6ace-486b-8af6-9cf599213a77
# ╟─92fd8a0c-2f01-418d-92c3-2d33eb59e37e
# ╠═4480b2f4-b20b-4c82-83db-a48e9ba74e16
# ╠═26ca6626-da4b-457c-886f-b0b076ea550d
# ╠═3bb6b846-704b-4e24-aa9d-3cb3db48e576
# ╠═c551c661-aedf-40d2-a0c0-5fb372371bc1
# ╟─7cab8606-b52e-4e91-9f8e-b266165f6094
# ╟─343c8dfd-4cff-44e6-8492-ebea01fd1317
# ╠═699f8161-b682-4cc3-9f4e-f175279ddfe4
# ╠═af0cfd3b-f45c-40cd-8295-32d6107a3c82
# ╠═07c94456-f071-4c8e-9701-c4ee70704165
# ╠═a59dacab-0aa9-4723-ac4c-1d19ffb7fd0d
# ╠═e9d8c5fc-36b5-4308-8072-5aa2b303ee19
# ╟─8e37f70a-380d-4652-966c-17b01729e281
# ╟─d62d6795-5038-40dc-a560-8b40cf09a737
# ╠═417bdaa2-aa3a-43dd-9c81-05693af3d560
# ╟─b169b4a8-f4e7-4723-8aa5-c84ac298a845
# ╠═8502cbd0-9773-4bd6-905d-3f1cde084f97
# ╠═b7c7e917-7986-4a4f-9861-e704f9e0a206
# ╠═bc699ac2-0a04-43c2-8b5d-0220c178ce71
# ╠═cf6d6008-0d53-433a-b6ad-1391f2b0cb7b
# ╠═385d8fe8-fc19-4db8-98fb-24c1f7c18449
# ╟─88dcfb77-f947-4903-81da-53d8ac1f5b4d
# ╟─fc40012d-9d75-4f61-a44e-6bf0feeac544
# ╟─6c67677a-e594-47e5-839e-5fe9235564a4
# ╟─76f167ea-099a-4cb3-9752-6fb2da2366dc
# ╠═0e531182-0ba4-4b25-a316-ae7335c40ced
# ╟─0066b806-3631-4460-95d9-aa4d3e409e2d
# ╠═64ca13d7-c011-49f2-bc34-8fe6d88228e8
# ╠═9ac0749e-77e9-4be5-b379-9fe3b86fc7fc
# ╠═8045a682-7693-49cc-969c-fe0fd9f9ae6f
# ╟─7ce6f30d-48d3-40d1-b9f0-de3382e78065
# ╠═b3d5d29b-ae96-4829-83bb-eea29f5c4f9a
# ╟─3857726a-44b1-41a6-97ef-eb7729c14d9c
# ╠═3aebbcf4-6355-4371-bb82-515cb24aebed
# ╟─a652cc32-77a6-46df-a098-6c5ce1421a7b
# ╟─728548c1-8b96-427d-9c97-c47695045c85
# ╠═56da7a87-c6d8-4e45-b299-3f20d2ef2a3a
# ╠═bacffa4d-a61e-4e32-9044-85e12abc4d45
# ╟─f991d3d5-26e4-49ca-b06c-46ebb49a547b
# ╠═baf46c35-8bbd-4f86-8ef5-19436d19bbe4
# ╟─fdabbb7b-ffb6-4a12-abba-c12a26327844
# ╟─e66558c6-090b-4149-a3db-42398cccadc1
# ╟─9aa5c8f6-335a-4f1b-86d2-8e6374156f57
# ╟─7ff202f0-a8ef-4b6d-923b-96fdd54cc6a3
# ╠═585a0a0b-497a-4c89-beff-2a83ddfc4f53
# ╟─84f8b0aa-bd3b-48d8-936b-0620dd2e2125
# ╠═11014351-a6da-44eb-b2c2-26e9da8122b4
# ╟─358a6c16-dabe-47b6-9d90-89c88695da40
# ╠═86d59c91-7094-4595-b2f0-e536f853e845
# ╟─68dfd4f5-09ad-481e-9974-534e5d9bfbe8
# ╠═6a0302f6-4cd4-43a3-ab5b-4ed3eb463787
# ╟─a8d8cc2a-e449-4043-bca5-948c13972d1d
# ╠═b70232f2-6fb3-4d5d-88b9-e81766134e7a
# ╟─18efc5f8-99ec-41a4-9f64-3ddc0dfd7458
