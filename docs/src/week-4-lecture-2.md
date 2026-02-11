# Week 4 Lecture 2: Formal proofs

In this lecture we continue our discussion of formal proofs, this time
focusing on the foundations on which formal proofs are built. Let us
however start by a more informal discussion about formal proofs.

## What is the point of formal proofs?

For computer-assisted proofs the goal is fairly clear, we want to be
able to prove things that require computations that would not be
feasible to perform by hand. For formal proofs the goals are perhaps
less clear and to a large extent they depend on your point of view.

- **Correctness:** This is in some sense the primary goal of formal
  proofs. Many published proofs contain errors, in most cases these
  errors are likely trivially fixable but not in all cases. Formal
  proofs could reduce (or to some extent even eliminate) such errors.
  On a large scale the area of mathematics does however seem to be
  relatively stable to such errors, see for example the discussions in
  this [Mathoverflow
  post](https://mathoverflow.net/questions/338607/why-doesnt-mathematics-collapse-even-though-humans-quite-often-make-mistakes-in).
- **Mutating proofs:** Writing a formal proof takes a lot longer than
  writing a pen and paper proof. Once a formal proof has been written
  it can however be much more straightforward to make small
  adjustments to the statements and the proofs. For example for
  fine-tuning constants. Lean can then tell you exactly where your
  previous arguments fail and where updates are needed. See for
  example this [Mathstodon
  post](https://mathstodon.xyz/@tao/111360298114925842).
- **Automating routine parts:** Some proofs require large routine
  calculations. Even if these calculations are simple, the sheer size
  could make them difficult to both write and referee. Having Lean
  automatically generate proofs for such parts could then save a lot
  of time. The Lean tools for automatically generating proofs are
  steadily improving, so even if some things are out of reach today
  they might not stay that way.
- **Generative AI:** Combining formal proofs with generative AI has
  the potential of letting mathematicians write informal proofs which
  can then be automatically formalized by the AI. This is possible to
  some extent today and the situation will likely improve. Formal
  proofs also seem to be a good ground for training AI using
  reinforcement learning.
- **Large scale collaboration:** Formal proofs reduces the need to
  trust proofs from coauthors. This could allow for more large scale
  collaboration that we are currently used to in mathematics.

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
both of type `Nat` as well as `hnm` which is of type `n++ = m++` and
returns a value of type `n = m`. In most programming languages
treating `n = m` as a type doesn't make much sense, but in Lean it
does. What comes after the `:=` part is what in a normal programming
language would correspond to the implementation of the function.

A concrete example of this correspondence is implications. The
mathematical statement that ``P \implies Q`` corresponds to a function
that takes as input a value of type `P` and returns an output of type
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
depends on the type of the input.

``` @repl
function singleton_vector(x::T)::Vector{T} where {T}
  return [x]
end

typeof(singleton_vector(5))

typeof(singleton_vector("a"))
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

the output type `n = m` depends on the values of `n` and `m`. This
type would be impossible to represent in Julia (and in the vast
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
