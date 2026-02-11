# Week 4 Lecture 1: Formal proofs

This week we will take a slight detour in our study of
computer-assisted proofs and talk about formal proofs.
Computer-assisted proofs and formal proofs are related, in the sense
that they both make use of the computer for verification. However,
they are very different in what they aim to do and practical use of
them looks very different.

Computer-assisted proofs aim to tackle the problem of humans being
bad (or at least slow) at performing large scale computations. Using
pen and paper one reduces the problem to a computational problem,
which is then handled by the computer.

Formal proofs aim to tackle the problem of humans making errors in
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
    mathematicians would include formal proofs in the general field of
    computer-assisted proofs.

## Some recent developments and resources

The interest in formal proofs has seen a rise in recent years. This is
likely driven by a combination of the tools for formal proofs
maturing, making them more accessible, and the rise of generative AI
giving hope for semi-automatic translation from pen and paper proofs
to formal proofs.

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
for computing bounds for ``\log 2``. He also mentions in a project
[log
book](https://github.com/AlexKontorovich/PrimeNumberTheoremAnd/wiki/Terence-Tao's-personal-log#day-13-jan-27-2026)
that some of the original papers contain minor errors in the constants
coming from the use of non-rigorous floating point arithmetic.

Some other resources:

- For PDEs there was recently a [Lean for
PDE](https://www.slmath.org/workshops/1180) workshop organized at
SLMath.
- Terence Tao has some [Youtube
  videos](https://www.youtube.com/@TerenceTao27) showing what
  formalizing a proof in Lean could look like in practice.

## A glimpse of Lean

Most (but not all) of the recent developments in formal proofs make
use of [Lean](https://lean-lang.org/). To get a feeling for what we
are dealing with, let us take a brief look at what statements written
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
  source](https://github.com/teorth/analysis/blob/main/analysis/Analysis/Section_2_1.lean))
- Section 10.2: Local maxima, local minima, and derivatives ([Lean
  source](https://github.com/teorth/analysis/blob/main/analysis/Analysis/Section_10_2.lean))
- Section 11.4: Basic properties of the Riemann integral ([Lean
  source](https://github.com/teorth/analysis/blob/main/analysis/Analysis/Section_11_4.lean)):
  Primarily Theorem 11.4.5.
