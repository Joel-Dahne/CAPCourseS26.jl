# Week 10 Lecture 1: Computer-assisted proofs in practice

Last week we finished the second phase of the course, Introduction to
computer-assisted proofs. We will now move into the third, and final,
phase of the course, Computer-assisted proofs in practice.

During this phase we will look at existing papers in analysis that
make use of computer-assisted proofs. The goal is both to see
examples of how a mathematical problem can be reduced to a rigorous
computation, and to see new examples of algorithms in rigorous
numerics.

For this lecture, we will look at some categories of papers and
methods and discuss which of them we are interested in diving deeper
into.

!!! notes "Remark"
    Most of the papers discussed below are either my own or a
    selection of papers that I'm somewhat familiar with.

## Spectral geometry

We are here interested in how eigenvalues of the Laplacian, i.e.
solutions to ``\Delta u = \lambda u``, depend on the domain.

My papers:

- [Computation of tight enclosures for laplacian
   eigenvalues](https://doi.org/10.1137/20m1326520) With Bruno Salvy (2020)
   [[Code](https://github.com/Joel-Dahne/MethodOfParticularSolutions.jl)]
- [A counterexample to Payne's nodal line conjecture with few
   holes](https://doi.org/10.1016/j.cnsns.2021.105957) With
   Javier Gómez-Serrano and Kimberly Hou (2021)
   [[Code](https://github.com/Joel-Dahne/PaynePolygon.jl)]
- [Monotonicity of the first Dirichlet eigenvalue of regular
  polygons](https://doi.org/10.48550/arXiv.2601.16285)  With
  Javier Gómez-Serrano and Joana Pech-Alberich (2025)
  [[Code](https://github.com/Joel-Dahne/SpectralRegularPolygon.jl)]

Others:

- [Any three eigenvalues do not determine a
  triangle](https://doi.org/10.1016/j.jde.2020.11.002) Javier
  Gómez-Serrano and Gerard Orriols (2019) [Code is attached as
  supplementary material]

The papers all make use of the Method of Particular Solutions (MPS)
for approximating the eigenfunctions. Error bounds are computed by
controlling the approximation on the boundary of the domains. Some of
them also make use of rigorous finite element methods (FEM) for
computing indices of the eigenvalues. The paper [Monotonicity of the
first Dirichlet eigenvalue of regular
polygons](https://doi.org/10.48550/arXiv.2601.16285) also has a lot of
asymptotic computations.

## Cusped waves

My papers:

- [Highest Cusped Waves for the Burgers-Hilbert
   Equation](https://doi.org/10.1007/s00205-023-01904-6) With
   Javier Gómez-Serrano (2022)
   [[Code](https://github.com/Joel-Dahne/BurgersHilbertWave.jl)]
- [Highest Cusped Waves for the Fractional KdV
   Equations](https://doi.org/10.1016/j.jde.2024.05.016) (2023)
   [[Code](https://github.com/Joel-Dahne/HighestCuspedWave.jl)]

The papers make use of spectral methods for computing approximate
solutions. The rigorous verification is then done using a fixed point
argument. For the fractional KdV equation a significant amount of work
is required to handle the singular endpoints.

## Self-similar blowup

My papers:

- [Self-Similar Singular Solutions to the Nonlinear Schrödinger and
   the Complex Ginzburg-Landau
   Equations](https://arxiv.org/abs/2410.05480) With Jordi-Lluís
   Figueras (2024) [[Code](https://github.com/Joel-Dahne/CGL.jl)]

The existence of the self-similar solutions is proved using a
combination of a rigorous ODE solver and asymptotic analysis at
infinity.

## Methodological papers

- [Rigorous numerics for analytic solutions of differential equations:
  the radii polynomial approach](https://doi.org/10.1090/mcom/3046)
  Allan Hungria, Jean-Philippe Lessard and J. D Mireles James (2016)
  [No code?]

The paper discusses an approach for solving differential equations
using spectral methods. The radii polynomial approach is a structured
way to set up the fixed point problem around the approximate solution.

- [Validated Saddle-Node Bifurcations and Applications to Lattice
  Dynamical Systems](https://doi.org/10.1137/16M1061011) Evelyn Sander
  and Thomas Wanner (2016) [No code?]

They describe a constructive version of the implicit function theorem
and use this to study branches of solutions.

- [Rigorous Computation of Solutions of Semilinear PDEs on Unbounded
  Domains via Spectral Methods](https://doi.org/10.1137/23M1607507)
  Matthieu Cadiot, Jean-Philippe Lessard, and Jean-Christophe Nave
  (2024) [No code?]

## Longer papers

- [Smooth imploding solutions for 3D compressible
  fluids](https://doi.org/10.1017/fmp.2024.12) Tristan Buckmaster,
  Gonzalo Cao-Labora, Javier Gómez-Serrano (2022) [Code is attached as
  supplementary material (though I couldn't locate the supplementary
  material)]
- Stable nearly self-similar blowup of the 2D Boussinesq and 3D Euler
  equations with smooth data: [Part 1:
  Analysis](https://arxiv.org/abs/2210.07191) [Part 2: Rigorous
  numerics](https://arxiv.org/abs/2305.05660) Jiajie Chen, Thomas Hou
  (2023) [[Code](https://jiajiechen94.github.io/codes)]
- [Nonuniqueness of Leray-Hopf solutions to the unforced
  incompressible 3D Navier-Stokes
  Equation](https://doi.org/10.48550/arXiv.2509.25116) Thomas Hou,
  Yixuan Wang, Changhe Yang (2026)
  [[Code](https://github.com/HouGroup2026/3d-navier-stokes-nonuniqueness)]
