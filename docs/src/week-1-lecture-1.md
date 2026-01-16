# Week 1 Lecture 1 - Introduction to computer-assisted proofs
The main goal of this first lecture is to give you an idea of what to
expect about the course. We will take a look at the structure of the
course and an overview of the content we will cover.

The course consists of 15 weeks which we will split into 3 different
parts. The 3 parts are

1. Introduction to computer-assisted proofs (≈ Week 1-4)
2. Introduction to rigorous numerics (≈ Week 5-10)
3. Computer-assisted proofs in practice (≈ Week 11-15)

Each week will follow roughly the same pattern. The Monday and
Wednesday sessions will be lectures where I present material, the
Friday session will be a computer lab where you get to try out what we
have discussed during the lectures.

## Computer labs
For the computer labs we will make use of
[Julia](https://julialang.org). We will talk more about Julia during
the first computer lab on Friday. A very brief description is that the
Julia language is designed for high performance scientific computing.
Version 1.0 was released in 2018, so it is a relatively young language
compared to for example C, Fortran, Python and Matlab.

The main goal for the Friday session is to make sure that you are all
able to install Julia and get it up and running. In general the course
will not assume familiarity with Julia, it should hopefully be
possible for you to pick it up as we go.

This web page you are reading now is generated using Julia. In fact,
[the repository](https://github.com/Joel-Dahne/CAPCourseS26.jl)
associated with this course is structured as a Julia package. We will
talk more about this later on.

## Part 1: Introduction to computer-assisted proofs
What is a computer-assisted proof? This is not an obvious question and
the answer will depend on who you ask. For the purposes of this course
there will be an answer to this question, but getting there requires a
bit of background.

Let us start by considering a slightly different question, what is
computer-assisted **mathematics**? In this case it could be more or
less anything that involves a computer. Examples could include

- Numerical simulations, such as solving some PDE using numerical
  methods or computing images of the Cantor set.
- Analysing data, in particular in applied mathematics you might have
  actual datasets you want to analyse. But you could also analyse
  large databases of knots.
- Symbolical computations, for example computing integrals or handling
  very large expressions using e.g. Sage, WolframAlpha, Mathematica or
  Maple.
- Using LLMs or other similar tools for solving mathematical problems
  or writing manuscripts.

More or less anything where you make use of the computer to help you
in your mathematical research. One could even include things like:

- Using Arxiv to find articles.
- Writing your article in LaTeX.
- Communicating with your collaborators using email.

We are however interested in something slightly different, not
computer-assisted **mathematics** but computer-assisted **proofs**.
The name implies that it should involve proofs, but that is true for
most of mathematics so doesn't restrict us much. We will however mean
something more specific, for our purposes a computer-assisted proof is
a mathematical proof of some mathematical statement which requires a
computer to **verify**. The key here is that the computer is involved
in the verification, not only the construction of the proof. Some
things which are not computer-assisted proofs with this definition are:

- Using an LLM to generate a human readable mathematical proof.
- Using numerical simulations to generate an hypothesis which is then
  proved using pen and paper.
- Using symbolical computations to compute a nasty integral, where the
  answer can be verified by hand.

What would be an example of a computer-assisted proof then? What does
it mean to use a computer to verify a proof? The prototypical example
would be something that requires a lot of calculations. Showing that
the fifth decimal in $\pi$ is 9 you could do by hand, showing that the
millionth decimal is 1 you probably couldn't. There is, however,
nothing fundamentally different between computing the fifth decimal or
the millionth decimal. In theory you could compute the millionth
decimal by hand, it would just take you a veeery long time. For the
computer it takes less than a second.

For the first part of the course we will look at three different kinds
of computer-assisted proofs:

1. Computer-assisted proofs for discrete problems
2. Computer-assisted proofs for continuous problems
3. Formal proofs

For discrete problems it is relatively easy to imagine that computers
could be helpful. An example is problems which reduce to checking a
finite number of cases. The most famous problem in this setting is
probably the [four color
theorem](https://en.wikipedia.org/wiki/Four_color_theorem), which says
that any map can be colored using four colors in such a way that no
two adjacent regions have the same color. This was proved in 1976
using a computer-assisted proof. For this they reduced the problem,
using pen and paper, to checking 1834 possible counterexamples. These
1834 possible counterexamples were then checked to be four colorable
with the help of the computer.

For continuous problems it is not as obvious how computers could be
used. Numerical analysis is a field of mathematics which deals with
computing **approximate** solutions to continuous problems. When
numerically solving a problem you introduce discretization errors and
rounding errors and these make it so that the final result cannot be
fully trusted. A good numerical method will give you a good
approximation most of the time, but it is in general not proved to
always do so. For mathematical proofs these errors are problematic, it
is not enough for the result to be approximately correct. How to deal
with this is what most of this course will be about. We look at a
subfield of numerical analysis called **rigorous numerical analysis**,
which allows us to control these errors.

Finally, we will talk about formal proofs.
[Wikipedia](https://en.wikipedia.org/wiki/Formal_proof) gives the
following description of formal proofs

> In logic and mathematics, a formal proof or derivation is a finite
> sequence of sentences (known as well-formed formulas when relating
> to formal language), each of which is an axiom, an assumption, or
> follows from the preceding sentences in the sequence, according to
> the rule of inference. It differs from a natural language argument
> in that it is rigorous, unambiguous and mechanically verifiable.

Formal proofs are not necessarily computer-assisted, though for
anything non-trivial the size of the expressions quickly outgrow
anything a human could verify and in practice formal proofs hence
require computers for the verification. For writing formal proofs one
makes use of special purpose software called **proof assistants** or
**interactive theorem provers**, example of such softwares are:

- [Isabelle](https://isabelle.in.tum.de/) - Cambridge 1986
- [Rocq](https://rocq-prover.org/) (previously named Coq) - Inria 1989
- [Agda](https://wiki.portal.chalmers.se/agda/pmwiki.php) - Chalmers 2007 (1999)
- [Idris](https://www.idris-lang.org/) - Edwin Brady 2007
- [Lean](https://lean-lang.org/) - Microsoft Research 2013

In particular the last one, Lean, has gained a lot of moment in the
last couple of years.

Using the term computer-assisted for a formal proof is however maybe
slightly misleading. In this case the computer is not merely assisting
in verifying the proof, it is doing the entire verification completely
by itself. We will talk a little bit about formal proofs later in the
course, but only with the goal of understanding the difference between
a formal proof and a regular computer-assisted proof.

## Part 2: Introduction to rigorous numerics
The second part of the course is where we will actually start learning
how to build computer-assisted proofs. We will look at the field of
rigorous numerical analysis, which is a subfield of numerical
analysis. The goal of numerical analysis is to compute
**approximations**, this is also true for rigorous numerical analysis.
The difference with rigorous numerical analysis is that in addition to
computing an approximation you also compute **rigorous upper bounds**
for the error of your approximation.

As a simple example, consider the problem of computing $e^2$. In
classical analysis you would do

``` @repl
exp(2)
```

Which tells you that $e^2 \approx 7.38905609893065$ In rigorous
numerics you would also compute an approximation, but you would
include an upper bound on the error of your approximation.

``` @repl
using Arblib
exp(Arb(2, prec = 53))
```

Which again tells you that $e^2 \approx 7.38905609893065$, but it now
includes the extra information that the error of this approximation is
at most $1.39 \cdot 10^{-15}$, so that $e^2 \in [7.38905609893065 \pm
1.39 \cdot 10^{-15}]$. How is this upper bound for the error computed?
That is what we will talk about! It is both fairly technical and
surprisingly easy.

To achieve this we will make use of something called interval
arithmetic. In regular numerical analysis one works with floating
points, these are inherently approximations since they cannot
represent most real numbers exactly. In interval arithmetic one works
with pairs of floating points, one representing a lower bound and one
representing an upper bound. So instead of e.g. $\pi \approx
3.141592653589793$ we would have $\pi \in [3.141592653589793,
3.1415926535897936]$. Another format is to use one floating point
representing the midpoint and another the radius, so $\pi \in
[3.14159265358979 \pm 3.34 \cdot 10^{-15}]$. When doing this it is not
a problem that most real numbers cannot be represented by floating
points, we can always pick the bounds to be floating points. Once we
have an interval representation we will still need to do computations
with them, exactly how to do this in a rigorous way is probably the
most technical part of rigorous numerics.

The content we will cover over the six weeks are:

- **Mathematical foundations of floating point arithmetic:** floating
  point formats, rounding
- **Basics of interval arithmetic:** basic arithmetic, elementary
  functions, special functions
- **Basic rigorous numerics:** isolating roots, computing integrals,
  enclosing extrema
- **Automatic differentiation:** forward (and backwards)
  differentiation, Taylor arithmetic
- **Improved rigorous numerics:** isolating roots, computing
  integrals, enclosing extrema

A sneak peak at some of the things we will learn how to do, in this
case using the [Arblib.jl](https://github.com/kalmarek/Arblib.jl/)
package for interval arithmetic package and some algorithms
implemented in
[ArbExtras.jl](https://github.com/Joel-Dahne/ArbExtras.jl).

Enclose roots of functions. For example finding the unique zero of
$x + e^x$ on the interval $[-0.6, -0.5]$

``` @repl
using Arblib, ArbExtras
ArbExtras.refine_root(x -> x + exp(x), Arb((-3 // 5, -1 // 2)))
```

Enclose integrals of analytic functions. For example enclosing
$\int_0^5 \sin(e^x)\ dx$

``` @repl
using Arblib
Arblib.integrate(x -> sin(exp(x)), 0, 5)
```

Enclose the minimum of the function. For example enclosing the minimum
of the Bessel function $J_4(x)$ on the interval $[1, 2]$.

``` @repl
using Arblib, ArbExtras, SpecialFunctions
ArbExtras.minimum_enclosure(x -> besselj(Arb(4), x), Arf(1), Arf(2))
```

## Part 3: Computer-assisted proofs in practice
In the last part of the course we will look at how computer-assisted
proofs are actually used in the literature. The goal will be to look
at examples of papers making use of computer-assisted proofs. Exactly
how we do this and what we will look is however yet to be determined
and will depend on your interests. Some areas we could take a closer
look at are:

- PDEs:. This is the field most of my research takes place in.
- Dynamical systems:. This is probably the field with the longest
  history of computer-assisted proofs and there is a number of
  interesting things we could look at here.

One could also discuss things one a more meta level:

- What exactly does it take to publish a paper with a
  computer-assisted proof? How does one prepare the code? How does one
  publish the code? How does one connect the paper and the code?
- What type of problems are amendable to a computer-assisted approach?
  These are things we will touch upon during the course, but one could
  maybe gain something from discussing it in more detail.

One could also dive deeper into different algorithms for
computer-assisted proofs:

- Rigorous integration of ODEs
- Finite element methods
- Spectral methods
- Physics-Informed Neural Networks (PINNs)

Alternatively, one can study the lower level details of interval
arithmetic, more related to the field of computer algebra.

We don't have to decide what to do yet, but as we get further into the
course we'll come back to this.
