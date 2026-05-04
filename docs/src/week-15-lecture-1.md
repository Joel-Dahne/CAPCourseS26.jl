# Week 15 Lecture 1: Publishing a computer-assisted proof

In this lecture we will discuss how to publish a computer-assisted
proof and how it compares to publishing traditional pen-and-paper
articles and numerical articles. We will also look at some examples of
how this can be done.

## Where to publish the code

A computer-assisted proof will necessarily include some amount of
code. Before we get into what this code should look like, let us start
with the most basic question: how should this code be published?

If the code is extremely short, one option is to explicitly include
the code in the paper. In that case there is essentially no
difference compared to publishing a traditional paper. This could be
the case if the computer is only used in a small part of the paper for
doing some relatively simple computation. For example, the proof for
Proposition II.2 discussed in Lab 3 could fall into this category; it
requires only a handful of lines of code.

As soon as the code gets a little bit longer, direct inclusion in the
paper is usually not a good idea. Instead you want to keep the code
separate and refer to it in the paper. There are essentially two ways
to do this:

1. Giving the code as supplementary material, which is published
   alongside the paper by the journal. For arXiv it is possible to
   upload the code together with the TeX file.
2. Putting the code on a website and linking to that in the paper.

The first approach is relatively simple and follows the usual paths
for publishing papers. As long as the paper is available, the code
should also be available. It does, however, have the drawback that
most publishers do not have good support for interacting with the
supplementary material. An example of a paper doing this is [Smooth
imploding solutions for 3D compressible
fluids](https://doi.org/10.1017/fmp.2024.12). However, I haven't
actually been able to figure out how to find the supplementary
material on the publisher's website. The original [arXiv
version](https://arxiv.org/abs/2208.09445v1) has the code included if
you download the TeX source; however, the latest arXiv version doesn't
have the code included.

The second approach, putting the code on a website and linking to it
in the paper, raises the question of which website to use.

Arguably the most common website to use nowadays is GitHub. In that
case, you create a (public) GitHub repository and link to that in the
paper. This is what I have done for all of my papers.

For example, the paper [Highest cusped waves for the fractional KdV
equations](https://doi.org/10.1016/j.jde.2024.05.016) contains links
to the GitHub repository
[HighestCuspedWave.jl](https://github.com/Joel-Dahne/HighestCuspedWave.jl).
In this case the journal treats the repository as a dataset and adds a
link to it. We also explicitly cite the repository in the paper, using
the BibTeX key

```
@software{HighestCuspedWave,
  author = {Dahne, Joel},
  title = {HighestCuspedWave.jl},
  url = {https://github.com/Joel-Dahne/HighestCuspedWave.jl},
  version = {1.0.0},
  note = {Commit dffdae2ff11bf2f33cc1a5f9910bef10778ebfb4},
}
```

Note the commit hash included in the note. This ensures that one can
verify the exact version of the code that was used for the paper. This
can be useful, for example, if an update is made to the paper and you
want to be able to distinguish between different versions of the code.

Some alternatives to GitHub would be
[GitLab](https://about.gitlab.com/) and
[Codeberg](https://codeberg.org/). In principle, one can use any
website, for example Dropbox or one's personal website.

An important consideration when deciding where to host the code is
its longevity. Journals have systems in place to make sure that the
articles are available in the future. If you put your code on an
arbitrary website, this might no longer be the case. This is
particularly bad for websites such as Dropbox (what happens if you
stop paying for it) or personal websites (what happens if you stop
maintaining the website or when you retire?). GitHub is also not
immune to this problem; GitHub doesn't give you any guarantees for how
long into the future your repository will be available.

One website that tries to improve on the issue of longevity is
[Zenodo](https://zenodo.org/). They allow you to upload your code (or
link a GitHub repository) and archive it, also giving you a DOI link
that you can reference. It is run by CERN and they claim:

> Your research is stored safely for the future in CERN’s Data Centre for as long as CERN exists

I haven't used this for any of my papers (though maybe I should do
that), but I have used it for Arblib.jl. It has a [Zenodo
page](https://zenodo.org/records/18512759) that both ensures the code
is archived and that it has a DOI that can be used when citing it (you
can download a BibTeX entry from the website).

Note that the issue of publishing code is not unique to
computer-assisted proofs. It is similar for any paper (in any field)
which includes code. I believe journals are getting better processes
for handling this and hopefully the situation improves even further in
the future.

## What to publish with the code

Once you know where to put your code, the second question is exactly
what you should put there.

As an example, let us take a closer look at the repository
[SpectralRegularPolygon.jl](https://github.com/Joel-Dahne/SpectralRegularPolygon.jl),
associated with the paper [Monotonicity of the first Dirichlet
eigenvalue of regular polygons](https://arxiv.org/abs/2601.16285).

We will look at the following aspects:

- Reproducibility: Are there instructions for how to reproduce the
  results in the paper? Can we reproduce the exact numbers and figures
  in the paper? Does the repository specify exactly what versions of
  the libraries it depends on?
- Documentation: Can you understand what the code does? Is there a
  high-level description of the code? How does it reference the paper?
  Are there descriptions of individual functions? How do these
  reference, for example, equations or lemmas from the paper? Is it
  clear what part of the code is used for proving specific results in
  the paper?
- Tests: Are there any tests included with the code? Has there been
  any attempt at ensuring that the code is correct and computes what
  it claims to produce?
- Results: Can you see the results without running any of the code?
  This is particularly important for code that takes a long time to
  run, in which case you might want to precompute some of the data.

Note that these questions are not specific to computer-assisted
proofs. However, they are arguably more important for
computer-assisted proofs since the result relies on the correctness of
the code in a more direct way than many numerical papers.

Different authors have very different conventions for things like how
much documentation is provided or whether there are any tests. Some of
these conventions also tend to depend on the programming language the
code is written in. For example, in Julia it is very easy to
explicitly specify the versions of all dependencies, whereas this is
harder in e.g. Python. There are also more established standards for
how to write tests in Julia compared to, for example, C, which tends
to increase the chance that tests are written.

### My setup

I usually structure my repositories as a Julia package. This gives the
following structure:

```
.
├── proofs/
├── src/
├── test/
├── LICENCE
├── Manifest.toml
├── Project.toml
└── README.md
```

- `README.md` contains high-level documentation.
- `Manifest.toml` and `Project.toml` contain information about the
  exact packages used.
- `LICENSE` contains a software license (usually MIT).
- `proofs` contains Pluto notebooks that produce the results in the
  paper. They contain a brief description of what they compute and how
  it is done. All the numbers and figures appearing in the paper come
  from these notebooks. I also export the notebooks to HTML so that
  it is possible to see the computational results without having to
  run any code.
- `src` contains implementations that are shared between multiple
  notebooks or that are too large to be able to put inside a single
  notebook.
- `test` contains tests for parts of the code. In particular, I try to
  test numerical parts of the code where small errors could give
  plausible-looking, but incorrect, results.

How the Pluto notebooks are structured largely depends on what they
are meant to prove. When possible I try to keep a similar structure between
the notebook and the proof of the lemma in the paper. In general I
want the notebooks to contain descriptions of what is being computed
and why it is being computed. To get the full details you would have
to read the paper as well, but having some of the details in the
notebook makes it easier to follow. As an example, you can look at the
notebook for Lemma 2.7 in
[SpectralRegularPolygon.jl](https://github.com/Joel-Dahne/SpectralRegularPolygon.jl)
and compare to the lemma in the
[paper](https://arxiv.org/abs/2601.16285).

Writing tests for the code can increase your confidence in the code
being correct. For numerical code it is often a good idea to write
code that checks some of the invariances that you know your function
should satisfy. For example, the function `SRP.integral_log(m::Int,
a::Arb)` is supposed to compute the integral of ``\log(x)^m`` from
``0`` to ``a``. Due to the singularity at ``x = 0`` the integral
cannot be computed directly using (rigorous) numerical integration.
However, if we compute `SRP.integral_log(m, b) - SRP.integral_log(m,
a)` this gives us the integral from ``a`` to ``b``, which we can
compute using numerical integration. We can thus check that this
property is satisfied by writing a test like

``` julia
@testset "integral_log" begin
    # Check that the difference when integrating to a and when
    # integrating to b is the same as the integral from a to b.
    a = Arb(0.25)
    b = Arb(0.5)
    z = Acb(0.4, 0.6)
    for m = 0:5
        @test Arblib.overlaps(
            SRP.integral_log(m, b) - SRP.integral_log(m, a),
            Arb(Arblib.integrate(x -> log(x)^m, a, b)),
        )
    end
end
```

## How to present computer-assisted computations in the paper

Another thing to consider is how to present the computer-assisted
computations when writing the paper. If time permits we will discuss
some of this during the lecture.
