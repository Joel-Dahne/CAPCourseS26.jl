# Week 4 Lab: Trying Lean

Since this is the only lab we will use Lean for we will avoid actually
installing Lean and instead make use of online versions.

One way to learn Lean is the [Natural number
game](https://adam.math.hhu.de/#/g/leanprover-community/nng4),
originally developed by Kevin Buzzard. This introduces you to the
basics of Lean by having you prove basic statements related to natural
numbers.

For this lab we will however not use this game, but instead look at
Lean proofs for some (very) basic analysis results. For this we will
use the [Live Lean](https://live.lean-live.org) to give us access to
Lean without installing it.

We will start by proving that a constant sequence converges. Copy and
paste the following code into [Live Lean](https://live.lean-live.org).
During the lab we will go through this example together, the details
are not contained in these notes.

``` lean-4
import Mathlib.Data.Real.Basic

-- 1. We define what it means for a sequence `s` to converge to a limit `a`.
--    Definition: For all ε > 0, there exists an N, such that for all n ≥ N, |s(n) - a| < ε.
def converges_to (s : ℕ → ℝ) (a : ℝ) :=
  ∀ ε > 0, ∃ N, ∀ n ≥ N, |s n - a| < ε

-- 2. We state the theorem: The sequence (λ n ↦ c) converges to c.
theorem limit_const (c : ℝ) : converges_to (λ n ↦ c) c := by
  -- Let ε be an arbitrary real number, and assume ε > 0 (hypothesis hε)
  intro ε hε

  -- We need to find an N. Since the sequence is constant, any N works.
  -- Let's use N = 0.
  use 0

  -- Now let n be any natural number, and assume n ≥ 0 (hypothesis hn).
  intro n hn

  -- State is: |(λ n ↦ c) n - c| < ε

  -- Step 1: Apply the function definition
  -- `dsimp` performs the beta-reduction: (λ n ↦ c) n ==> c
  dsimp

  -- State is now: |c - c| < ε

  -- Step 2: Arithmetic simplification
  -- We rewrite using the theorem `sub_self` (which states ∀ a, a - a = 0)
  rw [sub_self]

  -- State is now: |0| < ε

  -- (Optional Step 3): Simplify the absolute value
  -- We rewrite using `abs_zero` (which states |0| = 0)
  rw [abs_zero]

  -- Now the goal is 0 < ε. This is exactly our hypothesis hε.
  exact hε
```

Next we will prove that the identity function is continuous. Copy and
paste the following code into what you already have.

``` lean-4
def continuous_at (f : ℝ → ℝ) (x₀ : ℝ) :=
  ∀ ε > 0, ∃ δ > 0, ∀ x, |x - x₀| < δ → |f x - f x₀| < ε

theorem continuous_id (x₀ : ℝ) : continuous_at (λ x ↦ x) x₀ := by
  -- Let ε > 0 be given
  intro ε hε

  -- Choose δ = ε
  use ε

  -- We must show δ > 0 and the implication.
  -- The `constructor` tactic splits the "and" in the existence claim
  -- (∃ δ, (δ > 0) ∧ (condition))
  constructor

  -- Subgoal 1: Show δ > 0. Since δ = ε and ε > 0, this is true.
  exact hε

  -- Subgoal 2: Show that if |x - x₀| < δ then |f x - f x₀| < ε
  intro x hx
  -- The function is f(x) = x, so |f x - f x₀| is just |x - x₀|.
  -- We already know |x - x₀| < δ, and δ = ε.
  dsimp
  exact hx
```
