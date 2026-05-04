# Week 15 Lecture 1: Publishing a computer-assisted proof

In this lecture we will discuss how to publish a computer-assisted
proof and how it compares to publishing traditional pen-and-paper
articles and numerical articles. We will also look at some examples of
how this can be done.

## Where to publish the code

A computer-assisted proof will necessarily include some amount of
code. Before we get into what this code should look like, let us start
with the most basic question: how should this code be published?

If the code is extremely short, one option is to explicitly give the
code directly in the paper. In that case there is essentially no
difference compared to publishing a traditional paper. This could be
the case if the computer is only used in a small part of the paper for
doing some relatively simple computation. For example, the proof for
Proposition II.2 discussed in Lab 3 could fall into this category, it
requires only a handful of lines of code.

As soon as the code gets a little bit longer, direct inclusion in the
paper is usually not a good idea. Instead you want to keep the code
separate and refer to it in the paper. There are essentially two ways
to do this:

1. Giving the code as supplementary material, which is published
   alongside the paper by the journal. For arXiv it is possible to
   upload the code together with the tex-file.
2. Putting the code on a website and linking to that in the paper.

The first approach is relatively simple and follows the usual paths
for publishing papers. As long as the paper is available, the code
should also be available. It does, however, have the drawback that
most publishers do not have good support for interacting with the
supplementary material. An example of a paper doing this is [Smooth
imploding solutions for 3D compressible
fluids](https://doi.org/10.1017/fmp.2024.12). However, I haven't
actually been able to figure out how to find the supplementary
material on the publishers website. The original [arXiv
version](https://arxiv.org/abs/2208.09445v1) has the code included if
you download the TeX Source, however the latest arXiv version doesn't
have the code included.

The second approach, putting the code on a website and linking to it
in the paper, the first question to ask is which website to put it on.

Arguably the most common website to use nowadays is Github. In that
case you create a (public) Github repository and link to that in the
paper. This is what I have done for all of my papers.

For example, the paper [Highest cusped waves for the fractional KdV
equations](https://doi.org/10.1016/j.jde.2024.05.016) contains links
to the Github repository
[HighestCuspedWave.jl](https://github.com/Joel-Dahne/HighestCuspedWave.jl).
In this case the journal treats the repository as a dataset and adds a
link to it. We also explicitly cite the repository in the paper, using
the Bibtex key

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
can be useful for example if an update is made to the paper and one
want to be able to distinguish the different versions of the code.

Some alternatives to Github would be
[Gitlab](https://about.gitlab.com/) and
[Codeberg](https://codeberg.org/). In principle one can use any
website, for example Dropbox or ones personal website.

An important consideration when considering where to host the code is
the longevity of it. Journals have systems in place to make sure that
the articles are available also in the future. If you put your code on
an arbitrary website, this might no longer be the case. This is
particularly bad for websites such as Dropbox (what happens if you
stop paying for it) or personal websites (what happens if you stop
maintaining the website or when you retire?). Github is also not
immune to this problem, Github doesn't give you any guarantees for how
long into the future your repository will be available.

One website that tries to improve on the issue of longevity is
[Zenodo](https://zenodo.org/). The allow you to update your code (or
link a Github repository) and archives it, also giving you a doi link
that you can reference. It is run by CERN and they clam:

> Your research is stored safely for the future in CERN’s Data Centre for as long as CERN exists

I haven't used this for any of my papers (though maybe I should do
that), but I have used it for Arblib.jl, it has a [Zenodo
page](https://zenodo.org/records/18512759) that both ensures the code
is archived and that is has a doi that can be used when citing it (you
can download a Bibtex entry from the website).

Note that the issues with publishing code is not unique to
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

- Reproducability: Are there instructions for how to reproduce the
  results in the paper? Can we reproduce the exact numbers and figures
  in the paper? Does the repository specify exactly what versions of
  the libraries it depends on?
- Documentation: Can you understand what the code does? Is there a
  high level description of the code? How does it reference the paper?
  Are there descriptions of individual functions? How do these
  reference for example equations or lemmas from the paper? Is it
  clear what part of the code is used for proving specific results in
  the paper?
- Tests: Are there any tests included with the code? Has there been
  any attempts at ensuring that the code is correct and computes what
  it claims to produce?
- Results: Can you see the results without running any of the code?
  This is particularly important for code which takes a long time to
  run, in which case you might want to precompute some of the data.

Note that these questions are not specific to computer-assisted
proofs. However, they are arguably more important for
computer-assisted proofs since the result relies on the correctness of
the code in a more direct way than many numerical papers.

Different authors have very different conventions for things like how
much documentation is provided or if there are any tests. Some of
these conventions also tend to depend on the programming language the
code is written in. For example, Julia makes it very easy to
explicitly specify the versions of all dependencies, whereas this is
harder in e.g. Python.

## My setup

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

- `README.md` contains high level documentation.
- `Manifest.toml` and `Project.toml` contain information about the
  exact packages used.
- `LICENSE` contains a software license (usually MIT)
- `proofs` contains Pluto notebooks that produce the results in the
  paper. They contain a brief description of what they compute and how
  it is done. All the numbers and figures appearing in the paper are
  coming from these notebooks. I also export the notebooks to HTML so
  that it is possible to see the computational results without having
  to run any code.
- `src` contains implementations that are shared between multiple
  notebooks or that are too large to be able to be able to put inside
  a single notebook.
- `test` contains tests for parts of the code. In particular, I try to
  test numerical parts of the code where small errors could give
  plausible looking, but incorrect, results.
