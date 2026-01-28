# Week 2 Lecture 2: Integer arithmetic

In this lecture we will focus not on any specific computer-assisted
proof, but rather on one of the fundamental building blocks for
computer-assisted proofs, integer arithmetic. The lecture will also
serve as a bit of introduction to parts of the Julia programming
language. It could be useful to open a Julia REPL on the side while
reading this and experiment with some of the code shown.

To make use of computers for proofs we need to be able to trust the
computations they do. For numerical analysis, which relies on floating
point numbers and approximations, trusting the computer requires a bit
of work. This is what we will get to later in the course when we talk
about rigorous numerics. For integer arithmetic most people would
however probably agree that the computer can be trusted to do it
right.

When we in a couple of weeks get to rigorous numerics and more closely
study floating points we will see that everything in the end reduces
to integer arithmetic. So it makes sense to look a bit closer at this
and understand how it works.

## Integer types

There are many different ways to represent integers on the computer,
the most important aspects in the choice of representation being the
size of the integers and if one needs negative integers or not. For
our purposes we will mostly work with integer types that do allow
negative numbers, called signed integers. We will briefly talk about
unsigned integers at the end of this section.

For the size one could either have a fixed predetermined size that can
represent integers up to some fixed bound, or a variable size that can
represent arbitrarily large integers (until your computer runs out of
memory). Julia has the types `Int8`, `Int16`, `Int32`, `Int64` and
`Int128` for representing fixed-width integers, where the number
indicates the number of bits used to store the integer. The minimum
and maximum integer that is representable using these types can be
found using `typemin` and `typemax` respectively.

``` @repl
typemin(Int8)
typemax(Int8)

typemin(Int16), typemax(Int16)

typemin(Int32), typemax(Int32)

typemin(Int64), typemax(Int64)

typemin(Int128), typemax(Int128)
```

The default integer type on most modern computers is `Int64`, the
`Int` type in Julia is a shorthand for the default type. If you
directly write an integer it will be of type `Int`.

``` @repl
Int
typeof(5)
```

For representing arbitrary-sized integers Julia has the type `BigInt`.
In this case there is no `typemin` or `typemax` defined

``` @repl
typemin(BigInt)
typemax(BigInt)
```

You can convert an integer from one type to any other type. If the
integer is too large to be represented in the new type an error is
thrown.

``` @repl
Int16(5)
typeof(Int16(5))

BigInt(1000)
big(1000) # Shorthand for BigInt(1000) in this case

Int8(300) # 300 doesn't fit in one Int8
```

You can see exactly what bits are used to represent an integer using
`bitstring`

``` @repl
bitstring(7)
bitstring(2^14)
bitstring(Int32(2^14))
bitstring(Int16(2^14))
bitstring(Int8(2^14)) # Too small to fit 2^14
bitstring(BigInt(2^14)) # bitstring doesn't work for BigInt
```

For fixed-width integers negative values are represented using [two's
complement](https://en.wikipedia.org/wiki/Two%27s_complement), whereas
arbitrary-sized integers usually have a separate bit that keeps track
of the sign. The details here are not so important for our purposes
though.

``` @repl
bitstring(-7)
bitstring(Int32(-7))
bitstring(Int16(-7))
```

## Arithmetic

How arithmetic of integers is done depends on their type.

For `Int32` and `Int64` basic arithmetic is typically implemented
directly in hardware on the CPU. So you don't write a program for
multiplying two such integers, you use the implementation on the CPU.
The correctness of this procedure is therefore dependent on the
correctness of the CPU, which for even remotely modern CPU you can
assume.

For smaller integer types, e.g. `Int8` and `Int16`, arithmetic is
often times handled by converting them to `Int32` or `Int64`, doing
the operation and then converting back. One would in general not
expect these operations to be any faster than those for `Int32` and
`Int64`. Some hardware might have specialized instructions for these,
in which case it could be much faster though.

For `BigInt` the arithmetic is implemented in software. Internally
they are built up of a list of `Int64` that is treated as one large
integer. Operations are then implemented by combining several
operations for `Int64` values. For addition this is relatively simple
and something you could implement yourself with a bit of time. For
multiplication this becomes extremely complicated and requires both
highly sophisticated mathematical methods and carefully crafted
implementations to achieve top performance. The `BigInt` type in Julia
is internally based on the [GMP library](https://gmplib.org/) which
contains highly specialized code for operating on such integers.

## Overflow

For fixed-width integer types we have to somehow handle when the value
is too large to be represented by the type. For conversion to integer
types we have already seen that it throws an error if the value
doesn't fit.

``` @repl
Int8(300) # 300 doesn't fit in one Int8
```

When doing arithmetic on integers it does however not throw an error,
instead the result wraps around.

``` @repl
typemin(Int8), typemax(Int8) # Recall these values
typemax(Int8) + Int8(1)

typemin(Int64), typemax(Int64) # Recall these values
typemax(Int64) + 1
```

When this happens it is called **integer overflow**. The behavior here
does however depend on the programming language used. For example in
C, integer overflow is considered undefined behavior and a program
which exhibits overflow is not guaranteed to work as expected. In
Julia, and many other languages, the behavior is well defined. For
`Int64` the behavior is isomorphic to ``\mathbb{Z}_{2^{64}}``, with
the representatives centered around zero.

This overflow behavior means that you have to be careful when working
with integers for mathematical purposes. For fixed-width integer
arithmetic to faithfully represent integer arithmetic you have to
ensure (prove) that your operations never overflow. In many cases
overflow is not a problem. For example, computing Pythagorean triples
up to 1784 using `Int64` will clearly not give you any issues with
overflow. But if you want to verify Goldbach's weak conjecture up to
``10^{30} \approx 2^{100}`` you won't be able to do it using `Int64`.
If you want to be on the safe side you can always use `BigInt`, which
never overflows (it will just crash if you run out of memory). In some
programming languages, e.g. Python, the default is that integers are
represented using an arbitrary-sized representation.

With these issues coming from overflow, why would one not simply use
`BigInt` all the time? The answer is performance, it is significantly
slower.

## Performance

Let us take a brief look how performance for various integer types
compare. Let us consider the problem of computing

``` math
\sum_{n = 1}^N n^b
```

for some integers ``N`` and ``b``. In Julia this could be implemented
as

``` @example 1
function f(N::Integer, b::Integer)
    # Writing just "0" would give us an Int64, zero(N) gives us a zero of the same type as N
    S = zero(N)
    # Same with one(N) here
    for n in one(N):N
        S += n^b
    end
    return S
end
```

Let us take ``b = 2``, we can evaluate the function using a variety of
types

``` @repl 1
f(1000, 2)
f(Int32(1000), Int32(2))
f(Int16(1000), Int16(2)) # This overflows!
f(BigInt(1000), BigInt(2))
```

To benchmark these different versions we use the Julia package
[BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl).

``` @repl 1
using BenchmarkTools
@benchmark f($1000, $2) samples = 10000 evals = 10
@benchmark f(Int32($1000), Int32($2)) samples = 10000 evals = 10
@benchmark f(Int16($1000), Int16($2)) samples = 10000 evals = 10
@benchmark f(BigInt($1000), BigInt($2)) samples = 5000 evals = 1
```

!!! note
    The `$`-signs in the code below are part of the BenchmarkTools
    interface and are there to avoid the compiler being too clever and
    optimizing away what we want to measure.

    The extra arguments `samples` and `evals` are not required. If you
    run the code yourself you can remove them. They are here to reduce
    the time to build this documentation.

The most important number in the above benchmarks is the minimum time.
The mean time is also important in practice, but is affected by
variables we are not controlling for here.

## Flint

While we are discussing integer arithmetic it is also natural to
introduce the library that will be the foundation for a lot of the
rigorous numerics we will get to later in the course. The
[FLINT](https://flintlib.org/) library is a C library with high
performance implementations of many computer algebra algorithms. FLINT
stands for "Fast Library for Number Theory", but much of the
functionality is useful outside of number theory as well.

We will not make use of Flint directly, instead we will use it through
the Julia package [Arblib.jl](https://github.com/kalmarek/Arblib.jl)
that wraps (most of) the parts of the library related to rigorous
numerics. In fact, there is not really any need for you to know about
the Flint library at all for what we will do in the course.

!!! note
    The reason for the library being called Flint but the Julia
    package being called Arblib is that the parts of Flint that Arblib
    wraps were previously a separate library called Arb (Arbitrary
    precision Real Balls). The Arb library, and several others, were
    merged into Flint in 2023.

The Flint library implements many standard computer algebra algorithms
over a large variety of different rings. Some of the rings it
implements are

- Integers
- Rational numbers
- Integers mod ``n``
- Real and complex numbers (this is the rigorous numerics part)
- Exact real and complex numbers (this is more symbolical in nature)
- Finite fields
- ``p``-adic numbers

For our purposes we will primarily deal with the real and complex
numbers, though these internally depend on the integers and rational
numbers. For these rings it implements a number of different
algorithms related to e.g. polynomials, matrices and special
functions. Unless specified otherwise, the Flint library can be
assumed to always return mathematically rigorous results.

In many areas the Flint implementations are the state of the art and
sometimes greatly outperform other implementations. It's used by many
programs for computationally heavy computations, for example
[Sage](https://www.sagemath.org/) uses it internally for many things.
