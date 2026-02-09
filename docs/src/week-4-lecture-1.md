# Week 4 Lecture 1: Formal proofs

This week we will take a slight detour in our study of
computer-assisted proofs and talk about formal proofs.
Computer-assisted proofs and formal proofs are related, in the sense
that they both make use of the computer for verification. However,
they are very different in what they aim to do and practical use of
them looks very different.

Computer-assisted proofs aims to tackle the problem of humans being
bad (or at least slow) at performing large scale computations. Using
pen and paper one reduces the problem to a computational problem,
which is then handled by the computer.

Formal proofs aims to tackle the problem of humans making errors in
their logic. A formal proof covers the whole proof, from the statement
of the theorem to every step in the proof.

The goal of this week is not to make you experts in formal proofs, but
rather to give you enough of an idea of what a formal proof is to be
able to compare it to computer-assisted proofs. We will look at the
mathematical foundations for formal proofs, historical examples of
formal proofs as well as recent developments in the field.

!!! info
    As mentioned in the first lecture, different mathematicians mean
    different things when they say "computer-assisted proof". Some
    mathematics would include formal proofs in the general field of
    computer-assisted proofs.

## Some recent developments and resources

The interest in formal proofs has seen a rise in recent years. This is
likely drive by a combination of the tools for formal proofs maturing,
making them more accessible, and the rise of generative AI giving hope
for semi-automatic translation from pen and paper proofs to formal
proofs.

A recent example of the use of formal proofs which is also somewhat
relevant to our study of computer-assisted proofs is the [Integrated
Explicit Analytic Number Theory
network](https://www.ipam.ucla.edu/news-research/special-projects/integrated-explicit-analytic-number-theory-network/).
They aim to formally verify effective inequalities with explicit
constants that arise in analytic number theory. From their description
you can read

> With unspecified constants, such bounds are well understood and can
> be found in many textbooks (and have even been formalized in several
> proof assistant languages, including Lean). However, with explicit
> constants, the results are only contained in a few papers which are
> full of routine but tedious computations. Furthermore, while bounds
> with unspecified constants are quite robust with respect to minor
> typos in the arguments, explicit constant bounds can be extremely
> fragile, with a single arithmetic error causing all subsequent
> bounds to be untrustworthy.

In a [Mathstodon post](https://mathstodon.xyz/@tao/116037574125913104)
Terence Tao mentions that some of these computations make use of
interval arithmetic for some of the internal calculations, for example
for computing bounds for ``\log 2``. He also mentions in a projects
[log
book](https://github.com/AlexKontorovich/PrimeNumberTheoremAnd/wiki/Terence-Tao's-personal-log#day-13-jan-27-2026)
that some of the original papers contain minor errors in the constants
coming from the use of non-rigorous floating point arithmetic.

Some other resources:

- For PDEs there was recently a [Lean for
PDE](https://www.slmath.org/workshops/1180) workshop organized at
SLMath.
- Terence Tao has some [Youtube
  videos](https://www.youtube.com/@TerenceTao27) showing how
  formalizing a proof in Lean could look like in practice.

## A glimpse of Lean

Most (but not all) of the recent developments in formal proofs make
use of [Lean](https://lean-lang.org/). To get a feeling for what we
are dealing with, let us take a brief look at how statements written
in Lean could look like.

For these examples we will make use of the [Lean formalization of
Analysis I](https://github.com/teorth/analysis#), a formalization of
the [Analysis I](https://terrytao.wordpress.com/books/analysis-i/)
textbook by Terence Tao. The emphasis in the book is on rigour and on
foundations and starts with set theory and construction of the natural
numbers.

We will look at some examples of statements from this book. To make
use of Lean's functionality for interactively working with statements
we will use VS Code to demo this. We do not include the details of the
demo here, but the chapters of the book we will look at are

- Section 2.1: The Peano axioms ([Lean
  source](https://github.com/teorth/analysis/blob/main/analysis/Analysis/Section_2_1.lean)
- )
- Section 10.2: Local maxima, local minima, and derivatives ([Lean
  source](https://github.com/teorth/analysis/blob/main/analysis/Analysis/Section_10_2.lean))
- Section 11.4: Basic properties of the Riemann integral ([Lean
  source](https://github.com/teorth/analysis/blob/main/analysis/Analysis/Section_11_4.lean)):
  Primarily Theorem 11.4.5.

## What is a formal proof?

We have now seen some examples of what formal proofs could look like
in practice. But how are these proofs actually checked? What
foundations are these built on?

To understand this we will take a brief look at three core concepts:
the correspondence between programs and proofs, the language used to
express them, and the architecture that allows us to trust the
software.

### The Curry-Howard Correspondence

The most fundamental concept to grasp is that in formal verification,
there is a deep structural link between logic and programming. This is
known as the **Curry-Howard correspondence** (or "Propositions as
Types").

In a standard programming language, you have **types** (like `int`,
`string`, `List`) and **values** or **programs** that inhabit those
types (like `5`, `"hello"`, `[1, 2]`).

In the world of formal proofs:

- A mathematical proposition (statement) is a Type.
- A proof of that proposition is a Program (value) of that Type.

Therefore, "checking a proof" is reduced to "type-checking a
program." If you write a function that claims to return an integer
but actually returns a string, the compiler throws a type error.
Similarly, if you write a proof that claims to prove Theorem X but
contains a logical gap, the formal system throws a type error.

You can see this correspondence directly in Lean code (at least if you
have some experience with functional programming languages). Take for
example

``` lean-4
/--
  Axiom 2.4 (Different natural numbers have different successors).
  Compare with Mathlib's `Nat.succ_inj`.
-/
theorem Nat.succ_cancel {n m:Nat} (hnm: n++ = m++) : n = m := by
  injection hnm
```

Here `Nat.succ_cancel` is a function that takes as input `n` and `m`,
both of type `Nat` as well as `hmn` which is of type `n++ = m++` and
returns a value of type `n = m`. In most programming languages
treating `n = m` as a type doesn't make much sense, but in Lean it
does. What comes after the `:=` part is what in a normal programming
language would correspond to the implementation of the function.

A concrete example of this correspondence is implications. The
mathematical statement that ``P \implies Q`` corresponds to a function
that takes an input a value of type `P` and returns an output of type
`Q`. The proof of the statement corresponds to the implementation of
the function.

### Dependent Type Theory

To make the Curry-Howard correspondence work for complex mathematics
one needs a type system that is **much** richer than what is found in
standard languages like C or Julia or even Haskell. There are
different approaches for this and different proof assistants use
different systems. The system Lean is based on is called **Dependent
Type Theory**.

Most standard programming languages have types like `Bool`, `Int` and
`Float64`. Many programming languages have types that depend on other
types. For example Julia has the `Vector{T}` type representing vectors
with elements of type `T`, e.g. `Vector{Int}` for vectors of type
`Int`. With this you can write functions where the type of the output
depends on the type of the output.

``` julia
singleton_vector(x::T)::Vector{T} where {T} = [x]
```

What dependent type theory adds to this is that it allows the type of
the output to depend on the **values** of the input. For example in

``` lean-4
/--
  Axiom 2.4 (Different natural numbers have different successors).
  Compare with Mathlib's `Nat.succ_inj`.
-/
theorem Nat.succ_cancel {n m:Nat} (hnm: n++ = m++) : n = m := by
  injection hnm
```

the output type `n + m` depends on the values of `n` and `m`. This
type would be impossible to represent in Julia (and in the wast
majority of programming languages).

This is critical for mathematics because it allows us to encode
predicates like "``n = m``" or "``f`` is continuous" as types.

### The Axiomatic Foundation

It is important to note that type theory is the language of the logic,
but it is not the mathematics itself. Just like in pen-and-paper math,
we still assume axioms.

Most formal libraries (like Lean's `Mathlib`) include axioms
equivalent to ZFC (Zermelo-Fraenkel Set Theory with Choice), which is
the standard foundation of modern mathematics. It would however be
possible, in Lean, to write proofs based on a different axiomatic
system.

### The Lean Kernel vs. The Lean Proof Assistant

One potential issue with formal proofs is *"How do we know the proof
software itself doesn't have a bug?"*

Systems like Lean are split into two distinct parts:

1. **The Proof Assistant (The Elaborator/Tactics):** This is the
   large, complex software layer (millions of lines of code) that
   helps you write the proof. It includes the VS Code interface, the
   "tactics" (commands like `induction` or `rewrite`), and automation.
   It is "smart" but potentially buggy.
2. **The Kernel (The Verifier):** This is a very small, isolated piece
   of code (often just a few thousand lines). Its **only** job is to
   check the final proof object constructed by the assistant against
   the rules of the logic (Dependent Type Theory).

Crucially, we do not need to trust the Proof Assistant. We only need
to trust the Kernel.

If the "smart" automation in the Assistant makes a mistake or has a
bug, it will generate a "proof object" that is nonsense. When the
Kernel tries to check this object, it will reject it. This
architecture drastically reduces the amount of the code you have to
trust. You don't need to verify the entire Lean software suite, you
only need to verify the small Kernel.

This isolation of a separate kernel is known as the "de Bruijn
criterion", see e.g. [Type Checking in Lean
4](https://ammkrn.github.io/type_checking_in_lean4/whats_a_kernel.html).
