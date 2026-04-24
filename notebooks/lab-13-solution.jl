### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 7319104e-3fe7-11f1-a20d-19c8679cd7e3
begin
    using Arblib
    using ArbExtras
    using Plots
    setprecision(Arb, 64)
end

# ╔═╡ 3bf4c2f3-ed30-4209-aef4-bd5336f39368
md"""
# Lab 13 - Solving in sequence space - the radii polynomial approach

The goal of this lab is to finish the example we have discussed in this week's lectures.
"""

# ╔═╡ e431fd7b-132e-4e38-97ba-7766dffcfedd
N = 9 # Number of terms to keep when truncating

# ╔═╡ 53575658-6bae-4ac2-b03c-e2729d460815
ν = Arb(2) # Weight for the norm

# ╔═╡ dc8e3c66-f20d-44e5-afd3-c75523de2614
md"""
Recall that we are working with sequences in

``` math
\ell_\nu^1 = \{c = \{c_n\}_{n = 0}^\infty : \|c\|_\nu < \infty\},
```

with norm

``` math
\|c\|_\nu = \sum_{n = 0}^\infty |c_n|\nu^n.
```

These sequences are associated with the Taylor expansion of an
analytic function with radius of convergence at least ``\nu``.

In the code we will be working with truncated sequences of this type,
i.e. sequences for which only a finite number of terms are non-zero.
Since the sequences are associated with Taylor expansions it is
natural to use the type `ArbPoly` for representing such sequences.

!!! note "Remark"
    For some situations, using `ArbSeries` might be more appropriate.
    However, in this case we want to be able to compute full products of
    such sequences, in which case `ArbPoly` is a better choice.

For example, the sequence given by ``c_0 = 1``, ``c_1 = 3``, and ``c_2 = 5`` would be represented as
"""

# ╔═╡ 9a62d3d3-5507-4e28-bb39-fe077b8151af
c_example = ArbPoly([1, 3, 5])

# ╔═╡ 11db2b51-50f9-47c6-abfa-029db1bd1ac9
md"""
Let us start by implementing the function ``F(c)`` given by

``` math
(F(c))_n =
\begin{cases}
  c_0 - 1 / 2 & n = 0,\\
  nc_n - (c \ast (1 - c))_{n - 1} & n \geq 1.
\end{cases}
```

Note that this takes finite sequences to finite sequences, so we can
compute the result exactly.
"""

# ╔═╡ 1f756b43-224e-466c-a60b-9554508849c2
function F(c::ArbPoly)
    # Non-linearity 
    res = -c * (1 - c)
    Arblib.shift_left!(res, res, 1)

    # Linear part
    res[0] = c[0] - 1 // 2
    for n = 1:Arblib.degree(c)
        res[n] += n * c[n]
    end

    return res
end

# ╔═╡ 400f4528-eb39-4dbb-93fc-e3ba73dd6bde
F(c_example)

# ╔═╡ a9f11e9e-0d84-475a-81ac-edfc861c228d
md"""
We also want to implement the Fréchet derivative, ``DF(c)``. In this
case there is no finite representation, even if ``c`` is finite. We
therefore only implement a version truncated to index ``N``.

Recall that

``` math
(DF(c))_n =
\begin{cases}
  h_0 & n = 0,\\
  nh_n - h_{n - 1}  + 2(c \ast h)_{n - 1} & n \geq 1.
\end{cases}
```

The term ``nh_n`` corresponds to elements on the diagonal, whereas
``h_{n - 1} + 2(c \ast h)_{n - 1}`` gives us lower-diagonal elements. 

Note that matrices in Julia are indexed from ``1``, we therefore have
to adjust the indices by ``1`` accordingly.
"""

# ╔═╡ 6fbb5d8f-76d0-408b-b4cc-f2f77c38bf02
function DF_N(c)
    res = ArbMatrix(N + 1, N + 1)
    for n = 0:N
        if n == 0
            res[n+1, 1] = 1
        else
            # Diagonal part
            res[n+1, n+1] = n
            # Lower triangular part
            res[n+1, n] = -1
            for j = 0:(n-1)
                res[n+1, n-j] += 2c[j]
            end
        end
    end
    res
end

# ╔═╡ fdaffa1b-6d5d-4a08-8026-9d146ec5862a
DF_N(c_example)

# ╔═╡ e041a355-5f97-4733-b54e-47c891c07619
md"""
Last time we defined the projection operator

``` math
(\Pi_N c)_n =
\begin{cases}
  c_n \text{ if } n \leq N,
  0 \text{ if } n > N.
\end{cases}
```

as well as its complement ``\Pi_{>N} = I - \Pi_N``. Let us implement
these as well.
"""

# ╔═╡ 54f4f7ed-6a0b-4279-95a3-36dbfed8c866
function Π_N(c::ArbPoly)
    res = copy(c)
    for n = (N+1):Arblib.degree(c)
        res[n] = 0
    end
    return res
end

# ╔═╡ 357d54cf-306d-4cf4-b10d-ddeff384a485
Π_N(ArbPoly(1:20))

# ╔═╡ 5f7c448e-5a6d-4e30-a511-c019ca64c849
function Π_gt_N(c::ArbPoly)
    res = copy(c)
    for n = 0:N
        res[n] = 0
    end
    return res
end

# ╔═╡ 2351dd03-0786-49b5-ad80-b41027899f52
Π_gt_N(ArbPoly(1:20))

# ╔═╡ 46718c25-652f-4152-8060-db70dda60ee9
md"""
Finally, let us implement functions to compute the
``\|\cdot\|_\nu`` norm of a finite sequence as well as the associated
operator norm of a finite linear operator.
"""

# ╔═╡ 2bd9a7f7-f857-4a3b-a28d-6f43fb43614f
norm_ν(c::ArbPoly) =
    sum(0:Arblib.degree(c)) do n
        abs(c[n]) * ν^n
    end

# ╔═╡ c67c43ea-b94e-4cda-85e2-625f589f58ed
norm_ν(c_example)

# ╔═╡ 42f3c8ae-5d90-44e7-8879-3147f103bb77
function opnorm_ν(L::ArbMatrix)
    maximum(1:size(L, 2)) do j
        sum(1:size(L, 1)) do i
            # TODO: Do we need to adjust the exponent?
            abs(L[i, j]) * ν^(i - j)
        end
    end
end

# ╔═╡ 2c965a95-8a6f-4274-9651-6a478ab62ecb
opnorm_ν(DF_N(c_example))

# ╔═╡ 15d346e4-1e3d-4ae7-bd08-7c259e7267c6
md"""
## Compute approximation

With the above setup, we are ready to start with the computations. The
first step is to compute an approximate solution ``\overline{c}``.
Here we will cheat and use that a closed form for the solution is
``(1 + e^{-t})^-1``. We Taylor expand this using `ArbSeries` and take
the coefficients up to ``N`` as our approximation.
"""

# ╔═╡ cad8bd5c-3f93-4ced-8a51-6e4f724d2f26
c_bar = let c_bar = inv(1 + exp(-ArbSeries((0, 1), degree = N)))
    for n = 2:2:N
        c_bar[n] = 0
    end
    c_bar.poly
end

# ╔═╡ 311213a4-6c79-444c-8ffa-d426dfc8e7ad
md"""
We can check that this gives us a (very) good approximation for the first ``N`` terms of ``F(\overline{c})``. The tail is however not as small.
"""

# ╔═╡ 4cb2a65c-0e30-4a70-9d58-120d6229ab40
F(c_bar)

# ╔═╡ 7cef0994-4fe6-43d9-84ea-8ba07311e7c5
norm_ν(F(c_bar))

# ╔═╡ 9dadaf86-4bc1-4f66-a99c-31cb7f97a7ae
norm_ν(Π_N(F(c_bar)))

# ╔═╡ 58c053dd-c7bf-4c85-8571-b02be39e5abf
md"""
## Compute ``A``

Next we compute ``A``. Recall that we take

``` math
A = i_N A_N \Pi_N + \Lambda^{-1} \Pi_{> N},
```

where ``A_N`` is an approximation of the inverse of
``DF(\overline{c})`` truncated to index ``N`` and

``` math
(\Lambda^{-1} h)_n =
\begin{cases}
  h_0 & n = 0,\\
  \frac{1}{n}h_n & n \geq 1.
\end{cases}
```

We have already implemented a function that computes the truncated
matrix for ``DF(\overline{c})``. This makes it easy to compute
``A_N``.
"""

# ╔═╡ bdfc1901-d9f1-4b4a-802c-6a36851654f6
A_N = inv(DF_N(c_bar))

# ╔═╡ 681e0edf-e0f7-410b-88a1-da52eaef40ff
md"""
The operator ``\Lambda^{-1}`` is not finite, so we can't directly
construct a matrix for it. We can however implement a function that
applies it to any finite sequence:
"""

# ╔═╡ 52758d44-89d5-4a1c-b49b-38ba0879767f
function Λ_inv(c::ArbPoly)
    res = copy(c)
    for n = 1:Arblib.degree(c)
        res[n] = c[n] / n
    end
    return res
end

# ╔═╡ 9c878c88-03ed-4c40-8405-12b400ccfd82
md"""
## Bound ``Y``

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

We start by computing ``F(\overline{c})``:
"""

# ╔═╡ dfa0cf55-d70d-4cc0-87a8-f8613bb2d446
F_c_bar = F(c_bar)

# ╔═╡ 05e97420-5854-48dc-a334-20dcd3696c2b
md"""
For the first term we want to project and then multiply by ``A_N``.
Note that to perform the matrix multiplication we need to explicitly
collect the coefficients of the `ArbPoly`.
"""

# ╔═╡ 1c2206e9-f0d6-495c-bfea-c6c6bcf909f0
A_N_Π_N_F = ArbPoly(A_N * Arblib.coeffs(Π_N(F_c_bar)))

# ╔═╡ a926e571-5e47-4794-be9e-735f29c3cd84
md"""
We can then compute its norm.
"""

# ╔═╡ 08fccdfb-4ad7-4135-86db-0273a8a19845
norm_ν(A_N_Π_N_F)

# ╔═╡ 93f2446b-e6f0-4f93-8130-280db05de80d
md"""
For the tail we use our implementation of ``\Lambda^{-1}``. Note that
we are relying on the fact that the tail is finite!
"""

# ╔═╡ ec7a541b-cd89-4d6d-a6a3-047a3f00bff1
Λ_inf_Π_gt_N_F = Λ_inv(Π_gt_N(F_c_bar))

# ╔═╡ 1b8cb447-cc24-40b7-b9c6-d5ad31994c57
norm_ν(Λ_inf_Π_gt_N_F)

# ╔═╡ 191b71be-095e-408c-b931-d9073df815a9
Y = norm_ν(A_N_Π_N_F) + norm_ν(Λ_inf_Π_gt_N_F)

# ╔═╡ 4fe1cf2d-eed3-4ebc-8aa2-e57b577f2205
md"""
## Bound ``Z_1``

The next step is to bound ``Z_1``. We have

``` math
DT(\overline{c}) = I - ADF(\overline{c}).
```

From the definition of ``A`` we get

``` math
ADF(\overline{c}) = A(\Lambda + L_{\overline{c}})
= i_N A_N \Pi_N DF(\overline{c}) + \Lambda^{-1} \Pi_{> N} DF(\overline{c}).
```

Note that similar to ``A``, this operator is block diagonal. The term
``i_N A_N \Pi_N DF(\overline{c})`` acts purely on the subspace with
indices up to ``N`` and ``\Lambda^{-1} \Pi_{> N} DF(\overline{c})``
acts purely on the subspace with indices larger than ``N``. It is then
a general result that the norm is given by the maximum of the two
norms, namely

``` math
\|DT(\overline{c})\|_{\ell_\nu^1 \to \ell_\nu^1}
= \max\left(
\left\|\Pi_N - i_N A_N \Pi_N DF(\overline{c})\right\|_{\ell_\nu^1 \to \ell_\nu^1},
\left\|\Pi_{>N} - \Lambda^{-1} \Pi_{> N} DF(\overline{c})\right\|_{\ell_\nu^1 \to \ell_\nu^1}
\right).
```

The first part is a finite matrix, which we can compute explicitly.
"""

# ╔═╡ 879ba393-c321-4500-a395-e23b02bb9e51
DT_N = one(ArbMatrix(N + 1, N + 1)) - A_N * DF_N(c_bar)

# ╔═╡ 79d0affe-24ca-4413-af04-dabded294ca7
Z_1_part_1 = opnorm_ν(DT_N)

# ╔═╡ a07004f9-4987-43eb-8bb9-17c9eb5eff29
md"""
For the second term we use that ``DF(\overline{c}) = \Lambda +
L_{\overline{c}}``, giving us

``` math
\Pi_{>N} - \Lambda^{-1} \Pi_{> N} DF(\overline{c})
= \Pi_{>N} - \Lambda^{-1} \Pi_{> N} (\Lambda + L_{\overline{c}}).
```

Noticing that

``` math
\Lambda^{-1} \Pi_{> N} \Lambda = \Lambda^{-1} \Lambda \Pi_{> N} = \Pi_{> N},
```

this gives us

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
\left\|\Pi_{>N} - \Lambda^{-1} \Pi_{> N} DF(\overline{c})\right\|_{\ell_\nu^1 \to \ell_\nu^1}
\leq \frac{\nu}{N + 1}\|2\overline{c} - 1\|_{\nu}.
```
"""

# ╔═╡ 12af4c5e-8fe1-4aa9-a5c0-93d84da7fb23
Z_1_part_2 = ν / (N + 1) * norm_ν(2c_bar - 1)

# ╔═╡ 350ac322-b5b1-4d7f-bb84-d4672727571b
Z_1 = max(Z_1_part_1, Z_1_part_2)

# ╔═╡ d3a8269f-396d-4c18-a6d5-38bc512174b7
md"""
## Bound ``Z_2``

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

The first part is just the norm of ``A_N``. 
"""

# ╔═╡ 2614d280-3b66-442a-be2f-80972d6c53c6
Z_2_part_1 = opnorm_ν(A_N)

# ╔═╡ 76111c96-ff4d-4485-aa20-f4cb9bf5e256
md"""
The second term is bounded by ``\frac{1}{N + 1}`` since this is the
largest scaling applied to indices larger than ``N``.
"""

# ╔═╡ a7b1d5fa-c362-48d6-84a3-67bd3891ce5d
Z_2_part_2 = Arb(1 // (N + 1))

# ╔═╡ d424d26b-0edc-4327-beea-492bedfdc7e0
md"""
For ``D^2T(\overline{c})`` we recall that it was given by

``` math
(D^2F(c)(h, k))_n =
\begin{cases}
  0 & n = 0,\\
  2(k \ast h)_{n - 1} & n \geq 1.
\end{cases}
```

It therefore corresponds to a shift and multiplication by 2, giving us a
norm of ``2\nu``. We conclude that

``` math
\|D^2T(\overline{c})\|_{\ell_\nu^1 \times \ell_\nu^1 \to \ell_\nu^1}
\leq 2\nu\max\left(\|i_N A_N \Pi_N\|_{\ell_\nu^1 \to \ell_\nu^1}, \frac{1}{N + 1}\right).
```
"""

# ╔═╡ 74173885-ddad-4f95-9702-aecaf6a20e34
Z_2 = 2ν * max(Z_2_part_1, Z_2_part_2)

# ╔═╡ 45907280-0dfa-4db9-b2c4-2ed7be048d61
md"""
## Radii polynomial

With ``Y``, ``Z_1``, and ``Z_2`` computed, we define the radii polynomial

``` math
p(r) = Y + (Z_1 - 1)r + \frac{Z_2}{2} r^2
```
"""

# ╔═╡ cf152914-4d8a-40b2-8ef8-0e0412d6e7de
p = ArbPoly([Y, Z_1 - 1, Z_2 / 2])

# ╔═╡ 398c10b8-1be5-4881-a23c-8feac4789086
md"""
If we can find ``r \in [0, R]`` such that ``p(r) \leq 0`` and ``Z_1 +
Z_2 r < 1``, then ``T`` has a unique fixed point within a distance
``r`` of the approximate fixed point ``\overline{c}``. Note that in
this case, ``R = +\infty``. Plotting ``p(r)`` on ``[0, 0.15]`` we see
that there are two roots on the interval.
"""

# ╔═╡ 8476b871-c587-4ee6-96d5-7e953f2a84d1
let
    plot(range(0, 0.15, 1000), r -> p(r))
    hline!([0])
end

# ╔═╡ 218d8c4d-7e19-4f08-94b4-d6537e7bc9b2
md"""
With the help of ArbExtras.jl we can isolate and refine these two roots.
"""

# ╔═╡ d4323102-7e78-48f2-8d14-681cad8d6d86
roots, flags = ArbExtras.isolate_roots(p, Arf(0), Arf(1))

# ╔═╡ 0ed5ff87-e51f-4c95-8f3e-9a645dda6f90
@assert all(flags)

# ╔═╡ b0f05dc9-bb30-4c64-af3d-c5d8a91c3879
r_existence = ArbExtras.refine_root(p, Arb(roots[1]))

# ╔═╡ e38e1625-69d6-41f2-b474-d9e68d380f52
r_uniqueness = ArbExtras.refine_root(p, Arb(roots[2]))

# ╔═╡ dc5cf826-231c-4f9d-b755-c83a14f2ade1
md"""
We have thus proved that there is an exact solution to our problem in
the ball centered at ``\overline{c}`` with radius `r_existence`.
Moreover, this solution is unique in the ball of radius `r_uniqueness`.

Note that if we want to obtain ``L^\infty`` error bounds for the Taylor
expansion associated with the approximation, we need to do slightly
more work.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
ArbExtras = "c87f5d39-a852-4149-8a88-e3a13a25afc6"
Arblib = "fb37089c-8514-4489-9461-98f9c8763369"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"

[compat]
ArbExtras = "~1.1.0"
Arblib = "~1.7.0"
Plots = "~1.41.6"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.6"
manifest_format = "2.0"
project_hash = "21809724aa1bc81d59c9713dfdf6e8954f57270f"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArbExtras]]
deps = ["Arblib", "SpecialFunctions"]
git-tree-sha1 = "1acfd478eaa1d555247a8b8511337ca08d7182ca"
uuid = "c87f5d39-a852-4149-8a88-e3a13a25afc6"
version = "1.1.0"

[[deps.Arblib]]
deps = ["FLINT_jll", "LinearAlgebra", "Random", "ScopedValues", "Serialization", "SpecialFunctions"]
git-tree-sha1 = "23ad5b959003ceb775e13b6863240910eb356e73"
uuid = "fb37089c-8514-4489-9461-98f9c8763369"
version = "1.7.0"

    [deps.Arblib.extensions]
    ArblibForwardDiffExt = "ForwardDiff"

    [deps.Arblib.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BitFlags]]
git-tree-sha1 = "0691e34b3bb8be9307330f88d1a3c3f25466c24d"
uuid = "d1d4a3ce-64b1-5f1a-9ba4-7e7e69966f35"
version = "0.1.9"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "d0efe2c6fdcdaa1c161d206aa8b933788397ec71"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.6+0"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "b0fd3f56fa442f81e0a47815c92245acfaaa4e34"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.31.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "67e11ee83a43eb71ddc950302c53bf33f0690dfe"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.12.1"
weakdeps = ["StyledStrings"]

    [deps.ColorTypes.extensions]
    StyledStringsExt = "StyledStrings"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "8b3b6f87ce8f65a2b4f857528fd8d70086cd72b1"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.11.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "37ea44092930b1811e666c3bc38065d7d87fcc74"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.13.1"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.ConcurrentUtilities]]
deps = ["Serialization", "Sockets"]
git-tree-sha1 = "21d088c496ea22914fe80906eb5bce65755e5ec8"
uuid = "f0e56b4a-5159-44fe-b623-3e5288b988bb"
version = "2.5.1"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataStructures]]
deps = ["OrderedCollections"]
git-tree-sha1 = "e86f4a2805f7f19bec5129bc9150c38208e5dc23"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.19.4"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Dbus_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "473e9afc9cf30814eb67ffa5f2db7df82c3ad9fd"
uuid = "ee1fde0b-3d02-5ea6-8484-8dfef6360eab"
version = "1.16.2+0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.EpollShim_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a4be429317c42cfae6a7fc03c31bad1970c310d"
uuid = "2702e6a9-849d-5ed8-8c21-79e8b8f9ee43"
version = "0.0.20230411+1"

[[deps.ExceptionUnwrapping]]
deps = ["Test"]
git-tree-sha1 = "d36f682e590a83d63d1c7dbd287573764682d12a"
uuid = "460bff9d-24e4-43bc-9d9f-a8973cb893f4"
version = "0.1.11"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "27af30de8b5445644e8ffe3bcb0d72049c089cf1"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.7.3+0"

[[deps.FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "95ecf07c2eea562b5adbd0696af6db62c0f52560"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.5"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libva_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "66381d7059b5f3f6162f28831854008040a4e905"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "8.0.1+1"

[[deps.FLINT_jll]]
deps = ["Artifacts", "GMP_jll", "JLLWrappers", "Libdl", "MPFR_jll", "OpenBLAS32_jll"]
git-tree-sha1 = "b730e276143ad63360611f64243117d00276b632"
uuid = "e134572f-a0d5-539d-bddf-3cad8db41a82"
version = "301.400.1+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "f85dac9a96a01087df6e3a749840015a0ca3817d"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.17.1+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "70329abc09b886fd2c5d94ad2d9527639c421e3e"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.14.3+1"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll", "libdecor_jll", "xkbcommon_jll"]
git-tree-sha1 = "b7bfd56fa66616138dfe5237da4dc13bbd83c67f"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.4.1+0"

[[deps.GMP_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "781609d7-10c4-51f6-84f2-b8444358ff6d"
version = "6.3.0+2"

[[deps.GR]]
deps = ["Artifacts", "Base64", "DelimitedFiles", "Downloads", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Preferences", "Printf", "Qt6Wayland_jll", "Random", "Serialization", "Sockets", "TOML", "Tar", "Test", "p7zip_jll"]
git-tree-sha1 = "44716a1a667cb867ee0e9ec8edc31c3e4aa5afdc"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.73.24"

    [deps.GR.extensions]
    IJuliaExt = "IJulia"

    [deps.GR.weakdeps]
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"

[[deps.GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "FreeType2_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Qt6Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "be8a1b8065959e24fdc1b51402f39f3b6f0f6653"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.73.24+0"

[[deps.GettextRuntime_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll"]
git-tree-sha1 = "45288942190db7c5f760f59c04495064eedf9340"
uuid = "b0724c58-0f36-5564-988d-3bb0596ebc4a"
version = "0.22.4+0"

[[deps.Ghostscript_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Zlib_jll"]
git-tree-sha1 = "38044a04637976140074d0b0621c1edf0eb531fd"
uuid = "61579ee1-b43e-5ca0-a5da-69d92c66a64b"
version = "9.55.1+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "GettextRuntime_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "24f6def62397474a297bfcec22384101609142ed"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.86.3+0"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HTTP]]
deps = ["Base64", "CodecZlib", "ConcurrentUtilities", "Dates", "ExceptionUnwrapping", "Logging", "LoggingExtras", "MbedTLS", "NetworkOptions", "OpenSSL", "PrecompileTools", "Random", "SimpleBufferStream", "Sockets", "URIs", "UUIDs"]
git-tree-sha1 = "51059d23c8bb67911a2e6fd5130229113735fc7e"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "1.11.0"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "f923f9a774fcf3f5cb761bfa43aeadd689714813"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.1+0"

[[deps.HashArrayMappedTries]]
git-tree-sha1 = "2eaa69a7cab70a52b9687c8bf950a5a93ec895ae"
uuid = "076d061b-32b6-4027-95e0-9a2c6f6d7e74"
version = "0.2.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.JLFzf]]
deps = ["REPL", "Random", "fzf_jll"]
git-tree-sha1 = "82f7acdc599b65e0f8ccd270ffa1467c21cb647b"
uuid = "1019f520-868f-41f5-a6de-eb00f4b6a39c"
version = "0.1.11"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "0533e564aae234aff59ab625543145446d8b6ec2"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.1"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "67c6f1f085cb2671c93fe34244c9cccde30f7a26"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.5.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c0c9b76f3520863909825cbecdef58cd63de705a"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.5+0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "059aabebaa7c82ccb853dd4a0ee9d17796f7e1bc"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.3+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "17b94ecafcfa45e8360a4fc9ca6b583b049e4e37"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.1.0+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eb62a3deb62fc6d8822c0c4bef73e4412419c5d8"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.8+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "Ghostscript_jll", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "44f93c47f9cd6c7e431f2f2091fcba8f01cd7e8f"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.10"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"
    TectonicExt = "tectonic_jll"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"
    tectonic_jll = "d7dd28d6-a5e6-559c-9131-7eb760cdacc5"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibGit2]]
deps = ["LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.9.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "cc3ad4faf30015a3e8094c9b5b7f19e85bdf2386"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.42.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "f04133fe05eff1667d2054c53d59f9122383fe05"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.2+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d620582b1f0cbe2c72dd1d5bd195a9ce73370ab1"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.42.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoggingExtras]]
deps = ["Dates", "Logging"]
git-tree-sha1 = "f00544d95982ea270145636c181ceda21c4e2575"
uuid = "e6f89c97-d47a-5376-807f-9c37f3926c36"
version = "1.2.0"

[[deps.MPFR_jll]]
deps = ["Artifacts", "GMP_jll", "Libdl"]
uuid = "3a97d323-0669-5f0c-9066-3539efd106a3"
version = "4.2.2+0"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "MozillaCACerts_jll", "NetworkOptions", "Random", "Sockets"]
git-tree-sha1 = "8785729fa736197687541f7053f6d8ab7fc44f92"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.1.10"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "ff69a2b1330bcb730b9ac1ab7dd680176f5896b8"
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.1010+0"

[[deps.Measures]]
git-tree-sha1 = "b513cedd20d9c914783d8ad83d08120702bf2c77"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.3"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6aa4566bb7ae78498a5e68943863fa8b5231b59"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.6+0"

[[deps.OpenBLAS32_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "46cce8b42186882811da4ce1f4c7208b02deb716"
uuid = "656ef2d0-ae68-5445-9ca0-591084a874a2"
version = "0.3.30+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL]]
deps = ["BitFlags", "Dates", "MozillaCACerts_jll", "NetworkOptions", "OpenSSL_jll", "Sockets"]
git-tree-sha1 = "1d1aaa7d449b58415f97d2839c318b70ffb525a0"
uuid = "4d8831e6-92b7-49fb-bdf8-b643e874388c"
version = "1.6.1"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e2bb57a313a74b8104064b7efd01406c0a50d2ff"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.6.1+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.44.0+1"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0662b083e11420952f2e62e17eddae7fc07d5997"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.57.0+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotThemes]]
deps = ["PlotUtils", "Statistics"]
git-tree-sha1 = "41031ef3a1be6f5bbbf3e8073f210556daeae5ca"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "3.3.0"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "26ca162858917496748aad52bb5d3be4d26a228a"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.4"

[[deps.Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "JLFzf", "JSON", "LaTeXStrings", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "Pkg", "PlotThemes", "PlotUtils", "PrecompileTools", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "RelocatableFolders", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "TOML", "UUIDs", "UnicodeFun", "Unzip"]
git-tree-sha1 = "cb20a4eacda080e517e4deb9cfb6c7c518131265"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.41.6"

    [deps.Plots.extensions]
    FileIOExt = "FileIO"
    GeometryBasicsExt = "GeometryBasics"
    IJuliaExt = "IJulia"
    ImageInTerminalExt = "ImageInTerminal"
    UnitfulExt = "Unitful"

    [deps.Plots.weakdeps]
    FileIO = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
    GeometryBasics = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    ImageInTerminal = "d8c32880-2388-543b-8c61-d9f865259254"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "07a921781cab75691315adc645096ed5e370cb77"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.3.3"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "8b770b60760d4451834fe79dd483e318eee709c4"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.5.2"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "4fbbafbc6251b883f4d2705356f3641f3652a7fe"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.4.0"

[[deps.Qt6Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Vulkan_Loader_jll", "Xorg_libSM_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_cursor_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "libinput_jll", "xkbcommon_jll"]
git-tree-sha1 = "d7a4bff94f42208ce3cf6bc8e4e7d1d663e7ee8b"
uuid = "c0090381-4147-56d7-9ebc-da0b1113ec56"
version = "6.10.2+1"

[[deps.Qt6Declarative_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6ShaderTools_jll", "Qt6Svg_jll"]
git-tree-sha1 = "d5b7dd0e226774cbd87e2790e34def09245c7eab"
uuid = "629bc702-f1f5-5709-abd5-49b8460ea067"
version = "6.10.2+1"

[[deps.Qt6ShaderTools_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "4d85eedf69d875982c46643f6b4f66919d7e157b"
uuid = "ce943373-25bb-56aa-8eca-768745ed7b5a"
version = "6.10.2+1"

[[deps.Qt6Svg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll"]
git-tree-sha1 = "81587ff5ff25a4e1115ce191e36285ede0334c9d"
uuid = "6de9746b-f93d-5813-b365-ba18ad4a9cf3"
version = "6.10.2+0"

[[deps.Qt6Wayland_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Qt6Base_jll", "Qt6Declarative_jll"]
git-tree-sha1 = "672c938b4b4e3e0169a07a5f227029d4905456f2"
uuid = "e99dba38-086e-5de3-a5b1-6e4c66e897c3"
version = "6.10.2+1"

[[deps.REPL]]
deps = ["InteractiveUtils", "JuliaSyntaxHighlighting", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "PrecompileTools", "RecipesBase"]
git-tree-sha1 = "45cf9fd0ca5839d06ef333c8201714e888486342"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.6.12"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.ScopedValues]]
deps = ["HashArrayMappedTries", "Logging"]
git-tree-sha1 = "ac4b837d89a58c848e85e698e2a2514e9d59d8f6"
uuid = "7e506255-f358-4e82-b7e4-beb19740aa63"
version = "1.6.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "9b81b8393e50b7d4e6d0a9f14e192294d3b7c109"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.3.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SimpleBufferStream]]
git-tree-sha1 = "f305871d2f381d21527c770d4788c06c097c9bc1"
uuid = "777ac1f9-54b0-4bf8-805c-2214025038e7"
version = "1.2.0"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "64d974c2e6fdf07f8155b5b2ca2ffa9069b608d9"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.2"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.12.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "2700b235561b0335d5bef7097a111dc513b8655e"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.7.2"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "4f96c596b8c8258cc7d3b19797854d368f243ddc"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "178ed29fd5b2a2cfc3bd31c13375ae925623ff36"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.8.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "IrrationalConstants", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "aceda6f4e598d331548e04cc6b2124a6148138e3"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.10"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "aab80fbf866600f3299dd7f6656d80e7be177cfe"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.7.2"

    [deps.StructUtils.extensions]
    StructUtilsMeasurementsExt = ["Measurements"]
    StructUtilsStaticArraysCoreExt = ["StaticArraysCore"]
    StructUtilsTablesExt = ["Tables"]

    [deps.StructUtils.weakdeps]
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tables = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.8.3+2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.URIs]]
git-tree-sha1 = "bef26fb046d031353ef97a82e3fdb6afe7f21b1a"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.Unzip]]
git-tree-sha1 = "ca0969166a028236229f63514992fc073799bb78"
uuid = "41fe7b60-77ed-43a1-b4f0-825fd5a5650d"
version = "0.2.0"

[[deps.Vulkan_Loader_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Wayland_jll", "Xorg_libX11_jll", "Xorg_libXrandr_jll", "xkbcommon_jll"]
git-tree-sha1 = "2f0486047a07670caad3a81a075d2e518acc5c59"
uuid = "a44049a8-05dd-5a78-86c9-5fde0876e88c"
version = "1.3.243+0"

[[deps.Wayland_jll]]
deps = ["Artifacts", "EpollShim_jll", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "96478df35bbc2f3e1e791bc7a3d0eeee559e60e9"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.24.0+0"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b29c22e245d092b8b4e8d3c09ad7baa586d9f573"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.3+0"

[[deps.Xorg_libICE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a3ea76ee3f4facd7a64684f9af25310825ee3668"
uuid = "f67eecfb-183a-506d-b269-f58e52b52d7c"
version = "1.1.2+0"

[[deps.Xorg_libSM_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libICE_jll"]
git-tree-sha1 = "9c7ad99c629a44f81e7799eb05ec2746abb5d588"
uuid = "c834827a-8449-5923-a945-d239c165b7dd"
version = "1.2.6+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "808090ede1d41644447dd5cbafced4731c56bd2f"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.13+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c74ca84bbabc18c4547014765d194ff0b4dc9da"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.4+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "1a4a26870bf1e5d26cd585e38038d399d7e65706"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.8+0"

[[deps.Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "75e00946e43621e09d431d9b95818ee751e6b2ef"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "6.0.2+0"

[[deps.Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "a376af5c7ae60d29825164db40787f15c80c7c54"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.8.3+0"

[[deps.Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll"]
git-tree-sha1 = "0ba01bc7396896a4ace8aab67db31403c71628f4"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.7+0"

[[deps.Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "6c174ef70c96c76f4c3f4d3cfbe09d018bcd1b53"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.6+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libpciaccess_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "4909eb8f1cbf6bd4b1c30dd18b2ead9019ef2fad"
uuid = "a65dc6b1-eb27-53a1-bb3e-dea574b5389e"
version = "0.18.1+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "ed756a03e95fff88d8f738ebc2849431bdd4fd1a"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.2.0+0"

[[deps.Xorg_xcb_util_cursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_jll", "Xorg_xcb_util_renderutil_jll"]
git-tree-sha1 = "9750dc53819eba4e9a20be42349a6d3b86c7cdf8"
uuid = "e920d4aa-a673-5f3a-b3d7-f755a4d47c43"
version = "0.1.6+0"

[[deps.Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f4fc02e384b74418679983a97385644b67e1263b"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll"]
git-tree-sha1 = "68da27247e7d8d8dafd1fcf0c3654ad6506f5f97"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "44ec54b0e2acd408b0fb361e1e9244c60c9c3dd4"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.1+0"

[[deps.Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "5b0263b6d080716a02544c55fdff2c8d7f9a16a0"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.10+0"

[[deps.Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xcb_util_jll"]
git-tree-sha1 = "f233c83cad1fa0e70b7771e0e21b061a116f2763"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.2+0"

[[deps.Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "801a858fc9fb90c11ffddee1801bb06a738bda9b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.7+0"

[[deps.Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "00af7ebdc563c9217ecc67776d1bbf037dbcebf4"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.44.0+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.eudev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c3b0e6196d50eab0c5ed34021aaa0bb463489510"
uuid = "35ca27e7-8b34-5b7f-bca9-bdc33f59eb06"
version = "3.2.14+0"

[[deps.fzf_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b6a34e0e0960190ac2a4363a1bd003504772d631"
uuid = "214eeab7-80f7-51ab-84ad-2988db7cef09"
version = "0.61.1+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "371cc681c00a3ccc3fbc5c0fb91f58ba9bec1ecf"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.13.1+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "125eedcb0a4a0bba65b657251ce1d27c8714e9d6"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.17.4+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.libdecor_jll]]
deps = ["Artifacts", "Dbus_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pango_jll", "Wayland_jll", "xkbcommon_jll"]
git-tree-sha1 = "9bf7903af251d2050b467f76bdbe57ce541f7f4f"
uuid = "1183f4f0-6f2a-5f1a-908b-139f9cdfea6f"
version = "0.2.2+0"

[[deps.libdrm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libpciaccess_jll"]
git-tree-sha1 = "63aac0bcb0b582e11bad965cef4a689905456c03"
uuid = "8e53e030-5e6c-5a89-a30b-be5b7263a166"
version = "2.4.125+1"

[[deps.libevdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "56d643b57b188d30cccc25e331d416d3d358e557"
uuid = "2db6ffa8-e38f-5e21-84af-90c45d0032cc"
version = "1.13.4+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "646634dd19587a56ee2f1199563ec056c5f228df"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.4+0"

[[deps.libinput_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "eudev_jll", "libevdev_jll", "mtdev_jll"]
git-tree-sha1 = "91d05d7f4a9f67205bd6cf395e488009fe85b499"
uuid = "36db933b-70db-51c0-b978-0f229ee0e533"
version = "1.28.1+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "45a20bd63e4fafc84ed9e4ac4ba15c8a7deff803"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.57+0"

[[deps.libva_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll", "Xorg_libXfixes_jll", "libdrm_jll"]
git-tree-sha1 = "7dbf96baae3310fe2fa0df0ccbb3c6288d5816c9"
uuid = "9a156e7d-b971-5f62-b2c9-67348b8fb97c"
version = "2.23.0+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll"]
git-tree-sha1 = "11e1772e7f3cc987e9d3de991dd4f6b2602663a5"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.8+0"

[[deps.mtdev_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "b4d631fd51f2e9cdd93724ae25b2efc198b059b1"
uuid = "009596ad-96f7-51b1-9f1b-5ce2d5e8a71e"
version = "1.1.7+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "e7b67590c14d487e734dcb925924c5dc43ec85f3"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "4.1.0+0"

[[deps.xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "a1fc6507a40bf504527d0d4067d718f8e179b2b8"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "1.13.0+0"
"""

# ╔═╡ Cell order:
# ╟─3bf4c2f3-ed30-4209-aef4-bd5336f39368
# ╠═7319104e-3fe7-11f1-a20d-19c8679cd7e3
# ╠═e431fd7b-132e-4e38-97ba-7766dffcfedd
# ╠═53575658-6bae-4ac2-b03c-e2729d460815
# ╟─dc8e3c66-f20d-44e5-afd3-c75523de2614
# ╠═9a62d3d3-5507-4e28-bb39-fe077b8151af
# ╟─11db2b51-50f9-47c6-abfa-029db1bd1ac9
# ╠═1f756b43-224e-466c-a60b-9554508849c2
# ╠═400f4528-eb39-4dbb-93fc-e3ba73dd6bde
# ╟─a9f11e9e-0d84-475a-81ac-edfc861c228d
# ╠═6fbb5d8f-76d0-408b-b4cc-f2f77c38bf02
# ╠═fdaffa1b-6d5d-4a08-8026-9d146ec5862a
# ╟─e041a355-5f97-4733-b54e-47c891c07619
# ╠═54f4f7ed-6a0b-4279-95a3-36dbfed8c866
# ╠═357d54cf-306d-4cf4-b10d-ddeff384a485
# ╠═5f7c448e-5a6d-4e30-a511-c019ca64c849
# ╠═2351dd03-0786-49b5-ad80-b41027899f52
# ╟─46718c25-652f-4152-8060-db70dda60ee9
# ╠═2bd9a7f7-f857-4a3b-a28d-6f43fb43614f
# ╠═c67c43ea-b94e-4cda-85e2-625f589f58ed
# ╠═42f3c8ae-5d90-44e7-8879-3147f103bb77
# ╠═2c965a95-8a6f-4274-9651-6a478ab62ecb
# ╟─15d346e4-1e3d-4ae7-bd08-7c259e7267c6
# ╠═cad8bd5c-3f93-4ced-8a51-6e4f724d2f26
# ╟─311213a4-6c79-444c-8ffa-d426dfc8e7ad
# ╠═4cb2a65c-0e30-4a70-9d58-120d6229ab40
# ╠═7cef0994-4fe6-43d9-84ea-8ba07311e7c5
# ╠═9dadaf86-4bc1-4f66-a99c-31cb7f97a7ae
# ╟─58c053dd-c7bf-4c85-8571-b02be39e5abf
# ╠═bdfc1901-d9f1-4b4a-802c-6a36851654f6
# ╟─681e0edf-e0f7-410b-88a1-da52eaef40ff
# ╠═52758d44-89d5-4a1c-b49b-38ba0879767f
# ╠═9c878c88-03ed-4c40-8405-12b400ccfd82
# ╠═dfa0cf55-d70d-4cc0-87a8-f8613bb2d446
# ╟─05e97420-5854-48dc-a334-20dcd3696c2b
# ╠═1c2206e9-f0d6-495c-bfea-c6c6bcf909f0
# ╟─a926e571-5e47-4794-be9e-735f29c3cd84
# ╠═08fccdfb-4ad7-4135-86db-0273a8a19845
# ╠═93f2446b-e6f0-4f93-8130-280db05de80d
# ╠═ec7a541b-cd89-4d6d-a6a3-047a3f00bff1
# ╠═1b8cb447-cc24-40b7-b9c6-d5ad31994c57
# ╠═191b71be-095e-408c-b931-d9073df815a9
# ╟─4fe1cf2d-eed3-4ebc-8aa2-e57b577f2205
# ╠═879ba393-c321-4500-a395-e23b02bb9e51
# ╠═79d0affe-24ca-4413-af04-dabded294ca7
# ╟─a07004f9-4987-43eb-8bb9-17c9eb5eff29
# ╠═12af4c5e-8fe1-4aa9-a5c0-93d84da7fb23
# ╠═350ac322-b5b1-4d7f-bb84-d4672727571b
# ╟─d3a8269f-396d-4c18-a6d5-38bc512174b7
# ╠═2614d280-3b66-442a-be2f-80972d6c53c6
# ╟─76111c96-ff4d-4485-aa20-f4cb9bf5e256
# ╠═a7b1d5fa-c362-48d6-84a3-67bd3891ce5d
# ╟─d424d26b-0edc-4327-beea-492bedfdc7e0
# ╠═74173885-ddad-4f95-9702-aecaf6a20e34
# ╟─45907280-0dfa-4db9-b2c4-2ed7be048d61
# ╠═cf152914-4d8a-40b2-8ef8-0e0412d6e7de
# ╟─398c10b8-1be5-4881-a23c-8feac4789086
# ╠═8476b871-c587-4ee6-96d5-7e953f2a84d1
# ╟─218d8c4d-7e19-4f08-94b4-d6537e7bc9b2
# ╠═d4323102-7e78-48f2-8d14-681cad8d6d86
# ╠═0ed5ff87-e51f-4c95-8f3e-9a645dda6f90
# ╠═b0f05dc9-bb30-4c64-af3d-c5d8a91c3879
# ╠═e38e1625-69d6-41f2-b474-d9e68d380f52
# ╟─dc5cf826-231c-4f9d-b755-c83a14f2ade1
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
