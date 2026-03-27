### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 88bfc992-c3fb-4dbb-8e75-8df77635892a
begin
    using Arblib
    using IntervalArithmetic
    using ForwardDiff
    using LinearAlgebra
    using BenchmarkTools
end

# ╔═╡ 39960f4f-5096-4a21-8443-fef36fb1c570
md"""
# Week 9 Lab: Performance comparisons between Arblib.jl and IntervalArithmetic.jl

In this lab we will see how Arblib.jl and IntervalArithmetic.jl
compare when it comes to performance. In the process we will also look
at how to perform different types of computations in the two packages.

We will compare the performance for:

1. Basic arithmetic
2. Elementary functions
3. Linear algebra

We will do the comparisons between `Interval{Float64}` and `Arb` with
53 bits of precision as well as between `Interval{BigFloat}` and
`Arb`, both with 256 bits of precision.

Since IntervalArithmetic.jl doesn't support any special functions nor
does it have any routines for polynomials, we can't make any
comparisons for that.
"""

# ╔═╡ 0c57adb7-bd3c-4945-9e50-fe9734b87a37
md"""
## Basic arithmetic

Let us start by comparing performance for single arithmetic
computations. Doing so is not always so useful as some of the overhead
can dominate, but it is nevertheless a good starting point. Let us
take ``x = 1 / 3`` and ``y = \sqrt{2}`` as our input, we start by
computing them for the four cases we care about. We also include the
`Float64` case.
"""

# ╔═╡ 3d09e0ab-4182-4b6e-ab06-27d6a65efe16
x_f = 1 / 3

# ╔═╡ 5603b0e1-cfed-4d91-8e26-97483100b3a9
x_I = interval(Float64, 1 // 3)

# ╔═╡ f7f94e3b-0288-42b6-8b8a-10a965f31b9f
x_B = Arb(1 // 3, prec = 53)

# ╔═╡ 95db6914-b42e-438d-9913-749aa2b423dc
x_I_big = interval(BigFloat, 1 // 3)

# ╔═╡ a6582704-b87a-444e-8b50-d09e864b72ae
x_B_big = Arb(1 // 3, prec = 256)

# ╔═╡ 9f5ea225-0f02-4506-84c0-ba3979694b2b
md"""
**TASK:** Add similar code for ``y = \sqrt{2}``
"""

# ╔═╡ ac4de23c-52bf-4a86-9008-bb6ef20299fc
md"""
We can benchmark the performance for the `Float64` version with
"""

# ╔═╡ bb5a4aaa-3060-4fd4-a130-80c153fb21ca
#@benchmark $x_f + $y_f # TODO: Uncomment this to run it

# ╔═╡ 1d294676-7f9e-4362-8ad6-7fece61bcb9c
md"""
**TASK:** Add benchmarks for the other cases as well
"""

# ╔═╡ 31d4a908-1718-4bf5-b0fc-67d8275a5ed6
md"""
Note that for `Arb` and `Interval{BigFloat}` the minimum time and the
mean time are very different. The reason for this is garbage
collection (GC), the percent of time spent on garbage collection is
seen in the right column. You can also look at the number of
allocations.
"""

# ╔═╡ afcf69ba-0472-473b-b07d-f033e79b9a48
md"""
**TASK:** Do the same for multiplication
"""

# ╔═╡ ac961f9c-43ca-4f8b-b4ef-d174558f52f6
md"""
**TASK:** Do the same for division
"""

# ╔═╡ bc9d2b06-c6bd-4428-b39c-3a54d1cf6c51
md"""
Let us next look at a function which consists of a combination of
arithmetic operations. Let us take an explicit degree 5 polynomial and
evaluate it using a Horner scheme.

``` math
p(x) = x - 2x^2 + 3x^3 - 4x^4 + 5x^5 = ((((5x - 4)x + 3)x - 2)x + 1)x
```
"""

# ╔═╡ 5aa0ab4e-90ac-4a75-ad98-1a9ca3e4e217
md"""
**TASK:** Implement `p(x)` in Julia code and benchmark it for all types of ``x``.
"""

# ╔═╡ b05ef1aa-eb8e-471c-991b-5d97ff9b572c
p(x) = 0 # TODO: Implement this

# ╔═╡ dcad25d8-92c2-46b5-b37f-94b11ce56061
md"""
We can also evaluate this on the complex value ``x + iy``.
"""

# ╔═╡ 864ee4b5-14a1-474b-8aa0-583c2f2912c6
md"""
**TASK:** Benchmark it for complex values. 

**Hint:** You can use `complex(x, y)` to create a complex number. For `Arb` you however have to do `Acb(x, y)`, otherwise you get `Complex{Arb}` instead of `Acb`.
"""

# ╔═╡ 576fd628-b261-4aaf-87cd-0bdaa22812ae
md"""
Finally, let us look at one of the tricks that the Arblib.jl library
has, mutable arithmetic. This allows us to reduce the number of
allocations, improving performance. Allowing these types of low-level
optimizations was one of the motivations for developing the Arblib.jl
library. In this case we implement ``p(x)`` as
"""

# ╔═╡ 95ec744c-d46f-43c3-89a3-d0814774502c
function p!(res, x)
    # res = 5x
    Arblib.mul!(res, x, 5)

    # res = 5x - 4
    Arblib.add!(res, res, -4)

    # res = (5x - 4) * x
    Arblib.mul!(res, res, x)

    # res = (5x - 4) * x + 3
    Arblib.add!(res, res, 3)

    # res = ((5x - 4) * x + 3) * x
    Arblib.mul!(res, res, x)

    # res = ((5x - 4) * x + 3) * x - 2
    Arblib.add!(res, res, -2)

    # res = (((5x - 4) * x + 3) * x - 2) * x
    Arblib.mul!(res, res, x)

    # res = (((5x - 4) * x + 3) * x - 2) * x + 1
    Arblib.add!(res, res, 1)

    # res = ((((5x - 4) * x + 3) * x - 2) * x + 1) * x
    Arblib.mul!(res, res, x)

    return res
end

# ╔═╡ e42234d2-97b1-4cc8-900c-e1af62313b7f
md"""
With this we get
"""

# ╔═╡ e6b20ebb-07ff-4579-95b0-7cb8c76273f0
res_B = Arb(prec = 53)

# ╔═╡ e598c01f-e196-4b2a-9708-3d801683a3dd
res_B_big = Arb(prec = 256)

# ╔═╡ 5282dabf-8850-40d0-9ae7-ad80ddc2c2a9
#@benchmark p!($res_B, $x_B # TODO: Uncomment this to run it

# ╔═╡ bd5615c9-5350-4ca1-be2a-82faa3a3cb62
#@benchmark p!($res_B_big, $x_B_big) # TODO: Uncomment this to run it

# ╔═╡ 338ece25-c841-4a67-8699-31d6c5e3674c
md"""
!!! note "Remark"
    The code could be sped up by making use of `muladd` for performing
    the fused addition and multiplication. In this precise case when
    the coefficients are integers this is however slightly more
    awkward to implement.
"""

# ╔═╡ 1710644c-ef3a-429d-a492-467fae1e3085
md"""
## Elementary functions

Let us next look at computing some elementary functions. To begin
with, let us use the same value ``x`` as in the previous section.
"""

# ╔═╡ 491a422a-c2ed-4f91-8999-873b5e214c95
md"""
**TASK:**: Benchmark `exp`
"""

# ╔═╡ 9fadae22-07cb-4756-afd4-dc236507d9b3
md"""
**TASK:**: Benchmark `sin`
"""

# ╔═╡ 50da2040-b861-412d-8463-45c3f4b55858
md"""
For many elementary functions the performance depends on the value of
the input, this is for example true for ``\sin`` where an argument
reduction needs to be done for values outside of ``[-\pi/4, \pi/4]``.
Let us take ``z = 10^6 / 3``. We get
"""

# ╔═╡ 4b20d09d-9aac-4f9c-8898-f2eb21d86114
md"""
**TASK:** Compute ``z`` for all different types, similar to how we did for ``x``.
"""

# ╔═╡ eef73ea9-ca55-4b17-97a5-2245299ed53a
md"""
**TASK:** Benchmark `sin` on ``z``
"""

# ╔═╡ a130b414-1f3f-4c51-98cb-0c85ef355070
md"""
Let us next look at a function consisting of many elementary
functions. For this we take

``` math
f(x) = \sqrt{\arctan(\sin(x) + e^x)} - \cosh(\log(x))
```
"""

# ╔═╡ 143032a4-ce41-402a-9e68-5b4e4d81c31c
md"""
**TASK:** Implement ``f(x)``
"""

# ╔═╡ 5dd4770a-c317-4d02-a6d7-f1f6f332a903
f(x) = 0 # TODO: Implement this

# ╔═╡ 7b8f0bb2-ebf8-43ce-b0f6-703b9200d183
md"""
**TASK:** Benchmark ``f`` on ``x``
"""

# ╔═╡ dcbc869e-d916-4d03-bea2-694bbfce0e70
md"""
**TASK:** Benchmark $f$ on $x + iy$
"""

# ╔═╡ 1df311c9-33ba-4fb8-810b-22706f04c8e5
md"""
Finally, let us compare the computation of derivatives. For `Arb` we
use an `ArbSeries` of degree 1 and for `Interval` we use
ForwardDiff.jl.
"""

# ╔═╡ 4b697e97-da51-4779-b487-16e985b2885a
md"""
**TASK:** Benchmark computation of derivatives using `ForwardDiff.derivative(f, x)` for `Float64` and `Interval`
"""

# ╔═╡ 1528c275-b138-4be7-8a8b-1a96d3572a23
md"""
**TASK:** Benchmark computation of derivatives using `f(ArbSeries((x, 1)))`
"""

# ╔═╡ 6cb0ef99-e64c-49c5-977c-4fdefeefbe2d
md"""
## Linear algebra

For this we will look at matrix multiplication, inverses and the
computation of eigenvalues.

!!! note "Remark"
    Last lecture I said that IntervalArithmetic.jl supports solving
    linear systems; this seems to not actually be the case. It does
    support computing matrix inverses though, so we benchmark that
    instead.

For matrix multiplication let us take two ``100 \times 100`` matrices
``X`` and ``Y`` with ``(X)_{ij} = \rho^{|i - j|}`` with ``\rho = 1 /
3`` and ``Y_{ij} = 1 / (i - j + 0.5)``. For `Arb` we make two versions
of the matrix, one standard `Matrix{Arb}` and one `ArbMatrix`.
"""

# ╔═╡ 6ec145c8-d1c9-4668-b4cb-748defeddd96
N = 100

# ╔═╡ aef9ecfa-d99d-441e-a09e-630edd4fa3fa
ρ = 1 // 3

# ╔═╡ 1de51d90-3ee3-45f3-a356-fcaa45272065
X_f = [(1 / 3)^abs(i - j) for i = 1:N, j = 1:N]

# ╔═╡ ace09899-f709-447d-b581-c0b98649e20e
X_I = [interval(Float64, 1 // 3)^abs(i - j) for i = 1:N, j = 1:N];

# ╔═╡ ebc055ff-0c18-472f-82d3-5ccb42a89013
X_B = [Arb(1 // 3, prec = 53)^abs(i - j) for i = 1:N, j = 1:N];

# ╔═╡ 4b57344b-1fb4-4cdb-b1d1-08638947687d
X_B_AM = ArbMatrix(X_B, prec = 53);

# ╔═╡ 646fa64a-a822-4f7b-a8fa-8b706fa29407
X_I_big = [interval(BigFloat, 1 // 3)^abs(i - j) for i = 1:N, j = 1:N];

# ╔═╡ 18b94d27-4d7c-4ede-8ef9-bbce7ee82783
X_B_big = [Arb(1 // 3, prec = 256)^abs(i - j) for i = 1:N, j = 1:N];

# ╔═╡ 4962cad6-821d-44e2-ba59-985286210501
X_B_big_AM = ArbMatrix(X_B_big);

# ╔═╡ 2893fce5-eac2-4136-b511-5ac728ac5196
Y_f = [inv(i - j + 0.5) for i = 1:N, j = 1:N]

# ╔═╡ 8d206081-ef19-4948-ab8c-87cd7dcc0230
Y_I = [inv(interval(i - j + 0.5)) for i = 1:N, j = 1:N];

# ╔═╡ b1aac7f3-38a7-4aea-b241-e55426fe0dd5
Y_B = [inv(Arb(i - j + 0.5, prec = 53)) for i = 1:N, j = 1:N];

# ╔═╡ 0170f0cc-49ca-484c-bd2a-19b9b3d49c7d
Y_B_AM = ArbMatrix(Y_B, prec = 53);

# ╔═╡ 3381675a-1ab3-44b8-9048-ce8c896d417d
Y_I_big = [inv(interval(BigFloat, i - j + 0.5)) for i = 1:N, j = 1:N];

# ╔═╡ c63ef75c-8f02-4b88-9d2c-f1d45ed4d6ff
Y_B_big = [inv(Arb(i - j + 0.5, prec = 256)) for i = 1:N, j = 1:N];

# ╔═╡ a5a921dd-20fb-4923-ada1-f411f4018feb
Y_B_big_AM = ArbMatrix(Y_B_big);

# ╔═╡ 6b8dbb33-6454-4b57-b929-77d09d092f22
md"""
**TASK:** Benchmark `X * Y`
"""

# ╔═╡ d8f0c474-476e-4c5f-8406-bafa0282cbc4
md"""
**TASK:** Benchmark `inv(X)`
"""

# ╔═╡ 1df60e3d-d908-4d0c-9766-0484a68cc38f
md"""
Finally, let us look at computation of eigenvalues, in this case of
``Y``. Arblib only supports computation of eigenvalues for complex
matrices, so we convert them to `AcbMatrix` for the computation. There
is also no implementation of `eigvals` for `Matrix{Arb}` nor for
`Matrix{Interval{BigFloat}}`, so we exclude those.
"""

# ╔═╡ fcebfa8b-cc69-4d00-830c-8ef7a7eec384
#@benchmark eigvals($Y_f) # TODO: Uncomment to benchmark

# ╔═╡ 0e83df3c-5e69-4de3-8373-223387466e58
#@benchmark eigvals($Y_I) # TODO: Uncomment to benchmark

# ╔═╡ 3cd57c31-965e-47b8-8754-9240d2283bc4
#@benchmark eigvals($(AcbMatrix(Y_B_AM))) # TODO: Uncomment to benchmark

# ╔═╡ fb35e685-8f36-418d-be2c-f652a7de481a
#@benchmark eigvals($(AcbMatrix(Y_B_big_AM))) # TODO: Uncomment to benchmark

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Arblib = "fb37089c-8514-4489-9461-98f9c8763369"
BenchmarkTools = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
IntervalArithmetic = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[compat]
Arblib = "~1.7.0"
BenchmarkTools = "~1.6.3"
ForwardDiff = "~1.3.3"
IntervalArithmetic = "~1.0.3"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.5"
manifest_format = "2.0"
project_hash = "1253f58766501f8d71115ef2a27418ad614e9f1b"

[[deps.Arblib]]
deps = ["FLINT_jll", "LinearAlgebra", "Random", "ScopedValues", "Serialization", "SpecialFunctions"]
git-tree-sha1 = "23ad5b959003ceb775e13b6863240910eb356e73"
uuid = "fb37089c-8514-4489-9461-98f9c8763369"
version = "1.7.0"
weakdeps = ["ForwardDiff"]

    [deps.Arblib.extensions]
    ArblibForwardDiffExt = "ForwardDiff"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BenchmarkTools]]
deps = ["Compat", "JSON", "Logging", "Printf", "Profile", "Statistics", "UUIDs"]
git-tree-sha1 = "7fecfb1123b8d0232218e2da0c213004ff15358d"
uuid = "6e4b80f9-dd63-53aa-95a3-0cdb28fa8baf"
version = "1.6.3"

[[deps.CRlibm]]
deps = ["CRlibm_jll"]
git-tree-sha1 = "66188d9d103b92b6cd705214242e27f5737a1e5e"
uuid = "96374032-68de-5a5b-8d9e-752f78720389"
version = "1.0.2"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.CommonSubexpressions]]
deps = ["MacroTools"]
git-tree-sha1 = "cda2cfaebb4be89c9084adaca7dd7333369715c5"
uuid = "bbf7d656-a473-5ed7-a52c-81e309532950"
version = "0.3.1"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "9d8a54ce4b17aa5bdce0ea5c34bc5e7c340d16ad"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.18.1"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.0+1"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DiffResults]]
deps = ["StaticArraysCore"]
git-tree-sha1 = "782dd5f4561f5d267313f23853baaaa4c52ea621"
uuid = "163ba53b-c6d8-5494-b064-1a9d43ac40c5"
version = "1.1.0"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FLINT_jll]]
deps = ["Artifacts", "GMP_jll", "JLLWrappers", "Libdl", "MPFR_jll", "OpenBLAS32_jll"]
git-tree-sha1 = "b730e276143ad63360611f64243117d00276b632"
uuid = "e134572f-a0d5-539d-bddf-3cad8db41a82"
version = "301.400.1+0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.ForwardDiff]]
deps = ["CommonSubexpressions", "DiffResults", "DiffRules", "LinearAlgebra", "LogExpFunctions", "NaNMath", "Preferences", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "cddeab6487248a39dae1a960fff0ac17b2a28888"
uuid = "f6369f11-7733-5829-9624-2563aa707210"
version = "1.3.3"

    [deps.ForwardDiff.extensions]
    ForwardDiffStaticArraysExt = "StaticArrays"

    [deps.ForwardDiff.weakdeps]
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.GMP_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "781609d7-10c4-51f6-84f2-b8444358ff6d"
version = "6.3.0+2"

[[deps.HashArrayMappedTries]]
git-tree-sha1 = "2eaa69a7cab70a52b9687c8bf950a5a93ec895ae"
uuid = "076d061b-32b6-4027-95e0-9a2c6f6d7e74"
version = "0.2.0"

[[deps.IntervalArithmetic]]
deps = ["CRlibm", "MacroTools", "OpenBLASConsistentFPCSR_jll", "Printf", "Random", "RoundingEmulator"]
git-tree-sha1 = "2cce1fed119ca7b6cc230c4a3b85202478af7924"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "1.0.3"

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticArblibExt = "Arblib"
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticForwardDiffExt = "ForwardDiff"
    IntervalArithmeticIntervalSetsExt = "IntervalSets"
    IntervalArithmeticLinearAlgebraExt = "LinearAlgebra"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"
    IntervalArithmeticSparseArraysExt = "SparseArrays"

    [deps.IntervalArithmetic.weakdeps]
    Arblib = "fb37089c-8514-4489-9461-98f9c8763369"
    DiffRules = "b552c78f-8df3-52c6-915a-8e097449b14b"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.IrrationalConstants]]
git-tree-sha1 = "b2d91fe939cae05960e760110b328288867b5758"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.6"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "0533e564aae234aff59ab625543145446d8b6ec2"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.1"

[[deps.JSON]]
deps = ["Dates", "Logging", "Parsers", "PrecompileTools", "StructUtils", "UUIDs", "Unicode"]
git-tree-sha1 = "b3ad4a0255688dcb895a52fafbaae3023b588a90"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "1.4.0"

    [deps.JSON.extensions]
    JSONArrowExt = ["ArrowTypes"]

    [deps.JSON.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

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

[[deps.OpenBLAS32_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "46cce8b42186882811da4ce1f4c7208b02deb716"
uuid = "656ef2d0-ae68-5445-9ca0-591084a874a2"
version = "0.3.30+0"

[[deps.OpenBLASConsistentFPCSR_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "f2b3b9e52a5eb6a3434c8cca67ad2dde011194f4"
uuid = "6cdc7f73-28fd-5e50-80fb-958a8875b1af"
version = "0.3.30+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.7+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.4+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.12.1"

    [deps.Pkg.extensions]
    REPLExt = "REPL"

    [deps.Pkg.weakdeps]
    REPL = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

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

[[deps.Profile]]
deps = ["StyledStrings"]
uuid = "9abbd945-dff8-562f-b5e8-e1ebf5ef1b79"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.ScopedValues]]
deps = ["HashArrayMappedTries", "Logging"]
git-tree-sha1 = "ac4b837d89a58c848e85e698e2a2514e9d59d8f6"
uuid = "7e506255-f358-4e82-b7e4-beb19740aa63"
version = "1.6.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "5acc6a41b3082920f79ca3c759acbcecf18a8d78"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.7.1"

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

[[deps.StaticArraysCore]]
git-tree-sha1 = "6ab403037779dae8c514bad259f32a447262455a"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.4"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StructUtils]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "fa95b3b097bcef5845c142ea2e085f1b2591e92c"
uuid = "ec057cc2-7a8d-4b58-b3b3-92acb9f63b42"
version = "2.7.1"

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

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"

[[deps.p7zip_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.7.0+0"
"""

# ╔═╡ Cell order:
# ╟─39960f4f-5096-4a21-8443-fef36fb1c570
# ╠═88bfc992-c3fb-4dbb-8e75-8df77635892a
# ╟─0c57adb7-bd3c-4945-9e50-fe9734b87a37
# ╠═3d09e0ab-4182-4b6e-ab06-27d6a65efe16
# ╠═5603b0e1-cfed-4d91-8e26-97483100b3a9
# ╠═f7f94e3b-0288-42b6-8b8a-10a965f31b9f
# ╠═95db6914-b42e-438d-9913-749aa2b423dc
# ╠═a6582704-b87a-444e-8b50-d09e864b72ae
# ╟─9f5ea225-0f02-4506-84c0-ba3979694b2b
# ╟─ac4de23c-52bf-4a86-9008-bb6ef20299fc
# ╠═bb5a4aaa-3060-4fd4-a130-80c153fb21ca
# ╟─1d294676-7f9e-4362-8ad6-7fece61bcb9c
# ╟─31d4a908-1718-4bf5-b0fc-67d8275a5ed6
# ╟─afcf69ba-0472-473b-b07d-f033e79b9a48
# ╟─ac961f9c-43ca-4f8b-b4ef-d174558f52f6
# ╟─bc9d2b06-c6bd-4428-b39c-3a54d1cf6c51
# ╟─5aa0ab4e-90ac-4a75-ad98-1a9ca3e4e217
# ╠═b05ef1aa-eb8e-471c-991b-5d97ff9b572c
# ╟─dcad25d8-92c2-46b5-b37f-94b11ce56061
# ╟─864ee4b5-14a1-474b-8aa0-583c2f2912c6
# ╟─576fd628-b261-4aaf-87cd-0bdaa22812ae
# ╠═95ec744c-d46f-43c3-89a3-d0814774502c
# ╟─e42234d2-97b1-4cc8-900c-e1af62313b7f
# ╠═e6b20ebb-07ff-4579-95b0-7cb8c76273f0
# ╠═e598c01f-e196-4b2a-9708-3d801683a3dd
# ╠═5282dabf-8850-40d0-9ae7-ad80ddc2c2a9
# ╠═bd5615c9-5350-4ca1-be2a-82faa3a3cb62
# ╟─338ece25-c841-4a67-8699-31d6c5e3674c
# ╟─1710644c-ef3a-429d-a492-467fae1e3085
# ╟─491a422a-c2ed-4f91-8999-873b5e214c95
# ╟─9fadae22-07cb-4756-afd4-dc236507d9b3
# ╟─50da2040-b861-412d-8463-45c3f4b55858
# ╟─4b20d09d-9aac-4f9c-8898-f2eb21d86114
# ╟─eef73ea9-ca55-4b17-97a5-2245299ed53a
# ╟─a130b414-1f3f-4c51-98cb-0c85ef355070
# ╟─143032a4-ce41-402a-9e68-5b4e4d81c31c
# ╠═5dd4770a-c317-4d02-a6d7-f1f6f332a903
# ╟─7b8f0bb2-ebf8-43ce-b0f6-703b9200d183
# ╟─dcbc869e-d916-4d03-bea2-694bbfce0e70
# ╟─1df311c9-33ba-4fb8-810b-22706f04c8e5
# ╟─4b697e97-da51-4779-b487-16e985b2885a
# ╟─1528c275-b138-4be7-8a8b-1a96d3572a23
# ╟─6cb0ef99-e64c-49c5-977c-4fdefeefbe2d
# ╠═6ec145c8-d1c9-4668-b4cb-748defeddd96
# ╠═aef9ecfa-d99d-441e-a09e-630edd4fa3fa
# ╠═1de51d90-3ee3-45f3-a356-fcaa45272065
# ╠═ace09899-f709-447d-b581-c0b98649e20e
# ╠═ebc055ff-0c18-472f-82d3-5ccb42a89013
# ╠═4b57344b-1fb4-4cdb-b1d1-08638947687d
# ╠═646fa64a-a822-4f7b-a8fa-8b706fa29407
# ╠═18b94d27-4d7c-4ede-8ef9-bbce7ee82783
# ╠═4962cad6-821d-44e2-ba59-985286210501
# ╠═2893fce5-eac2-4136-b511-5ac728ac5196
# ╠═8d206081-ef19-4948-ab8c-87cd7dcc0230
# ╠═b1aac7f3-38a7-4aea-b241-e55426fe0dd5
# ╠═0170f0cc-49ca-484c-bd2a-19b9b3d49c7d
# ╠═3381675a-1ab3-44b8-9048-ce8c896d417d
# ╠═c63ef75c-8f02-4b88-9d2c-f1d45ed4d6ff
# ╠═a5a921dd-20fb-4923-ada1-f411f4018feb
# ╟─6b8dbb33-6454-4b57-b929-77d09d092f22
# ╟─d8f0c474-476e-4c5f-8406-bafa0282cbc4
# ╟─1df60e3d-d908-4d0c-9766-0484a68cc38f
# ╠═fcebfa8b-cc69-4d00-830c-8ef7a7eec384
# ╠═0e83df3c-5e69-4de3-8373-223387466e58
# ╠═3cd57c31-965e-47b8-8754-9240d2283bc4
# ╠═fb35e685-8f36-418d-be2c-f652a7de481a
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
