# Reproducibility protocol

**Paper authors:** Reza Iraji, Felipe Galarza-Jimenez, and Majid Zamani
**Repository maintainer:** Reza Iraji

This protocol is aligned with the revised manuscript and the August 28, 2026 response to reviewers.

## Evidence classes

1. **Exact, solver-free evidence.** Rational-arithmetic scripts and deterministic regression tests establish the four-visit traces, physical/normalized platoon equivalence, the dimension-scalable two-node original-PC-CC construction, the exact PC-CC3 margin `475/3904`, and the full matched convex-projection one-node comparison.
2. **Licensed SOS evidence for the platoon reachabilityâ€“rank criterion.** A reported SOS block is accepted only when the solver returns termination status `OPTIMAL` and primal status `FEASIBLE_POINT`. These are solver-reported statuses and are not mathematical strict-feasibility guarantees.

No `SLOW_PROGRESS`, `ALMOST_OPTIMAL`, rounded iterate, or exploratory failed search is used as reviewer-facing evidence.

## Solver-free verification

Run:

```bash
python scripts/run_all_checks.py
julia ComplexExample/verify_normalized_model.jl
julia GraphIndexedExample/explicit_graph_certificate.jl 8
```

The Python command runs the regression/integrity suite, compiles Python sources, regenerates deterministic result files in a temporary directory, and compares them with the committed artifacts.

## Julia environment

Instantiate and precompile:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
```

Final reproduction environment:

- Julia 1.12.6
- TSSOS 1.5.2
- MosekTools 0.15.10
- Mosek.jl 11.2.0
- MOSEK runtime/API 11.2.0
- Microsoft Windows 11 Pro 10.0.26200, ARM64
- Snapdragon(R) X 12-core X1E80100 @ 3.40 GHz
- 12 physical cores / 12 logical processors
- approximately 63.5 GiB RAM

## Four-visit nonlinear platoon

Run:

```bash
julia --project=. ComplexExample/verify_target_local_ranked_pccc.jl
```

The verifier keeps the submitted graph

```text
(1,1,1), (1,2,2), (2,2,1), (1,1,2)
```

and the physical nonlinear plant and sets unchanged. It verifies:

- exact reachability preflight and four-visit witness;
- one-step graph closure;
- target-local backward propagation with the relational premise retained as a semialgebraic generator;
- nonnegativity of the affine rank on the reachable target set;
- recurrent-node unit rank descent.

All 4/4 one-step, 8/8 propagation, rank-nonnegativity, and 2/2 recurrent-node blocks in the archived run report `OPTIMAL/FEASIBLE_POINT`. The six order-2 propagation blocks use 256 variables and 12 top-level constraints. The two order-4 propagation blocks use 8,156 variables and 12 top-level constraints and solve in about 0.20 s each. Rank blocks use at most order 2 and 241 variables. The witness rank drops are approximately `2.5840`, `2.1440`, and `1.7878`.

This computation verifies the **separate graph-indexed reachabilityâ€“rank sufficient criterion**. It is not presented as original PC-CC3.

## Dimension-scalable original PC-CC benchmark

Run:

```bash
julia GraphIndexedExample/explicit_graph_certificate.jl 8
```

The paper reports dimensions `n=4,8,16`. The two-node graph-indexed family

```math
C_{p,q}(x,y)=C_0(x_p,y_q)
```

uses four distinct mixed source/destination degree-two certificates. PC-CC1 and PC-CC2 are checked exactly. PC-CC3 uses

```text
s2 = 1
s3a = 0
s3b = 41/20
```

and has global minimum

```text
475/3904 > 0
```

at

```text
(a*, b*, c*) = (0, 19/20, 2243/2440).
```

The all-mode-2 witness has exactly four visits at times 5â€“8.

## Full matched convex-projection comparison

For the specified one-node family

```math
z_\alpha=\alpha z_1+(1-\alpha)z_2,\qquad \alpha\in[0,1],
```

the verifier checks the exact PC-CC1 residual formulas

```math
r_A(\alpha)=15(25\alpha-16),
```

and

```math
r_B(\alpha)=-5(119\alpha^2-41\alpha-15).
```

Hence `r_A(alpha) < 0` for `alpha < 16/25`. On `[16/25,1]`,

```math
r_B'(\alpha)=205-1190\alpha<0
```

and

```math
r_B(16/25)=-4689/125<0.
```

Therefore every member of this specified convex-projection family fails PC-CC1, while the two-node graph-indexed family succeeds. This comparison does **not** exclude unrestricted one-node certificates.

## Public repository

https://github.com/HyConSys/PCCC