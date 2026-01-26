# Week 2 Lecture 1: Discrete problems
In this lecture we'll take a look at some high profile
computer-assisted proofs for discrete problems. The goal here is not
to fully understand these proofs, but rather to see examples of
problems for which computer-assistance could be beneficial.

We will look at three different problems:
- The four color theorem
- The boolean Pythagorean triples problem
- Goldbach's weak conjecture

Some takeaways from these examples are:
- Infinite problems can sometimes be reduced to finite problems using
  a pen and paper analysis. In some cases combined with a
  computer-assisted part.
- Modern computers are very fast and can handle a huge number of
  computations.
- For some problems the number of computations scale extremely fast.
- Computers are getting faster and faster, what was a monumental
  effort in the 70's is trivial today.

## The four color theorem
This problem was mentioned already in the first lecture and is one of
the first, and likely the most famous, computer-assisted proofs.

!!! note "Four color theorem (1976)"
    Any map can be colored using four colors in such a way that no two
    adjacent nodes have the same color.

![Four colored map of US states](assets/four-color-theorem.png)

Initially this doesn't look like a good problem for a
computer-assisted proofs. It is straightforward to check if a specific
map is four colorable, one simply writes a program that searches for
four colorings. There are, however, an infinite number of maps and
there is no way to check all of them with the computer.

The first, and probably most important, part of the proof is therefore
to reduce it to a finite number of cases. We will not go into details
how this is done, but the general idea is to start by assuming that
there is a minimal counterexample. They then make use of two related
concepts:

- Show there exists a *finite unavoidable set*. A set of
  configurations such that every map that satisfies some necessary
  conditions for being a minimal counterexample must have at least one
  configuration from this set.
- *Reducible configurations*, a configuration that cannot occur in a
  minimal counterexample. If a map contains a reducible configuration
  then the map can be reduced to a smaller map which, if it is four
  colorable, implies that the original map is four colorable. This in
  particular implies that the original map could not be a minimal
  counterexample.

The result then follows if one could show that all of the
configurations in the finite unavoidable set are reducible
configurations. In the original proof the unavoidable set consisted of
1834 configurations and was later reduced to 1,482. Each of these
configurations then had to be checked to be reducible. Just finding
the set of unavoidable configuration required a significant amount of
work, but to my understanding was to a large part done by hand.
Checking that each of the unavoidable configurations were reducible
was however done by the computer. Since this was still in the very
early days of computers there was also a lot of manual labor involved
in the process at this point.

In 2005 the proof was [formalized in
Roqc](https://www.ams.org/journals/notices/200811/tx081101382p.pdf)
(previously called Coq), which we will talk more about in Week 4.

## The boolean Pythagorean triple problem
The Pythagorean triple problem asks whether it is possible to color
each of the positive integers either red or blue, so that no
Pythagorean triple of integers \(a, b, c\) satisfying \(a^2 + b^2 =
c^2\) are all the same color? This was [shown to be false in
2016](https://doi.org/10.1007/978-3-319-40970-2_15), see also [this
website with some more
information](https://www.cs.utexas.edu/~marijn/ptn/). More precisely
we have the following theorem.

!!! note "Boolean Pythagorean triples theorem (2016)"
    The set ``\{1, \dots, 7824\}`` can be partitioned into two parts,
    such that no part contains a Pythagorean triple, while this is
    impossible for ``\{1, \dots, 7825\}``.

This problem is inherently finite, and it is maybe easier to imagine
that it could be done through a computer-assisted proof.

Let us start with the first part, showing that ``\{1, \dots, 7824\}``
can be partitioned into two parts such that no part contains a
Pythagorean triple. If we are given a partitioning then it is a
relatively straightforward exercise to verify that it satisfies the
condition. There is around 10000 Pythagorean triples below 7824, so a
very dedicated person could even do it by hand given enough time. In
practice this check is of course computer-assisted. Of course, one
first has to find a candidate partitioning, this uses a tool know as a
[SAT solver](https://en.wikipedia.org/wiki/SAT_solver). SAT solvers
are very useful tools for computer-assisted proofs, but tend to not
play big role in analysis problems so we want talk about it in this
course.

The second part, showing that this is impossible for ``\{1, \dots,
7825\}``, is again a finite problem. In this case it is however not
enough to find one partitioning, instead we have to verify that it is
impossible for **any** partitioning. There are, however, ``2^{7825}
\approx 3.63 \times 10^{2355}`` different ways to partition this set
and checking that all of these partitions contain a Pythagorean triple
is simply not feasible.

!!! note
    In cryptography one usually assumes that ``2^128 \approx 3.4
    \times 10^{38}`` is larger than what anyone could bruteforce.
    Using all the [energy in the observable
    universe](https://seirdy.one/posts/2021/01/12/password-strength/#conclusion-tldr)
    one could get as far as around ``2^{320}``.

However, the problem has a lot of symmetry and they managed to reduce
the problem to around a trillion cases. The proof that none of these
trillion partitions contain a Pythagorean triple consists of around
200 terabytes of propositional logic. This made it the [largest proof
ever](https://doi.org/10.1038/nature.2016.19990). This does however
compress to a mere 68 gigabytes in the end. Again, the actual
calculation is done using a SAT solver.

## Goldbach's weak conjecture
Goldbach's weak conjecture is a famous conjecture in number theory.

!!! note "Goldbach's weak conjecture"
    Every odd number greater than 5 can be written as the sum of three
    primes.

Similar to the Four color theorem this is again a problem that apriori
requires checking an infinite number of cases. In this case it was
however reduced a finite computation already in 1956, though with an
upper bound ``e^{e^{16.038}} \approx 8 \times 10^{4008659}`` way too
large to make a bruteforce approach of the finite number of remaining
numbers feasible.

In 2013 the conjecture was computationally confirmed up to ``8 875 694
145 621 773 516 800 000 000 000 \approx 8.875 \cdot 10^{30}``, see
[10.1080/10586458.2013.831742](https://doi.org/10.1080/10586458.2013.831742).
There is also a number of earlier results not going quite as far. The
computations makes use of a number of tricks to reduce the
computational time, but eventually boils down to a large brute force
check requiring about 40 000 core hours.

Simultaneously there was progress on improving the bound after which
the conjecture could be proved to hold for all odd numbers. This
number was eventually brought down to ``10^{27}`` by [Harald Helfgott
in 2013](https://doi.org/10.48550/arXiv.1312.7748). Together with the
computation above this gave a full proof for the result. The paper was
accepted for publication in Annals in 2015, though it seems like the
[final version has not actually been
finished](https://webusers.imj-prg.fr/~harald.helfgott/anglais/book.html).
Reducing the bound to ``10^{27}`` does by itself rely on a
computer-assisted proof. It uses tools from analysis and in this case
it therefore makes use of rigorous numerics for the computations. The
theory is however fairly involved and not something we will dive
deeper in.
