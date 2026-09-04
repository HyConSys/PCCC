# Path-Complete Closure Certificates (PC-CCs)

Reviewer-facing reproducibility package for **Formal Verification of Switched Systems via Path-Complete Closure Certificates**.

Authors: Reza Iraji, Felipe Galarza-Jimenez, and Majid Zamani. Reza Iraji is the repository maintainer.

## Verified claims

This repository accompanies the revised manuscript and reproduces its two complementary computational results.

1. **Four-visit nonlinear platoon -- graph-indexed reachability-rank criterion.** The nonlinear platoon dynamics, physical state set, four-visit persistence sets, and submitted two-node path-complete graph are unchanged. `ComplexExample/verify_target_local_ranked_pccc.jl` verifies the separate graph-indexed reachability-rank sufficient criterion. For every reported numerical SOS block, the solver reports termination status `OPTIMAL` and primal status `FEASIBLE_POINT`; these are solver-reported statuses, not mathematical strict-feasibility guarantees.
2. **Dimension-scalable original PC-CC benchmark.** `GraphIndexedExample/explicit_graph_certificate.jl` verifies the original PC-CC conditions for the two-node graph-indexed construction in dimensions 4, 8, and 16. The degree-two relational family has four distinct source/destination-indexed certificates, exhibits four visits, and has exact PC-CC3 margin `475/3904 > 0`, attained at `(0, 19/20, 2243/2440)`.
3. **Matched one-node/two-node comparison.** The same graph-indexed verifier checks the full convex-projection family `z_alpha = alpha z1 + (1-alpha) z2`, `alpha in [0,1]`. Exact residual formulas show every member of this specified one-node family violates PC-CC1, while the two-node family succeeds. This is not a nonexistence claim for unrestricted one-node certificates.

The platoon reachability-rank construction is a **separate sufficient proposition** and is not identified with original PC-CC3. The dimension-scalable graph-indexed benchmark independently exercises original PC-CC3 non-vacuously.

## Quick reproduction

Instantiate the Julia environment:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.status()'
```

Run the solver-free checks:

```bash
python scripts/run_all_checks.py
julia ComplexExample/verify_normalized_model.jl
julia GraphIndexedExample/explicit_graph_certificate.jl 8
```

Run the licensed SOS verification for the platoon:

```bash
julia --project=. ComplexExample/verify_target_local_ranked_pccc.jl
```

Publication acceptance policy for numerical SOS blocks:

- `termination_status == OPTIMAL`;
- `primal_status == FEASIBLE_POINT`;
- no `SLOW_PROGRESS`, `ALMOST_OPTIMAL`, or approximate iterate is reported as a certificate;
- these solver statuses are not mathematical strict-feasibility guarantees.

## Repository layout

- `ComplexExample/` -- nonlinear platoon model, normalized-coordinate equivalence, four-visit witness, and reachability-rank SOS verifier.
- `GraphIndexedExample/` -- dimension-scalable two-node original-PC-CC benchmark and full matched convex-projection comparison.
- `ScalableExample/` -- auxiliary scalar exact-arithmetic kernel used by the graph-indexed benchmark; it is not a separate headline experiment in the paper.
- `scripts/` -- deterministic analytical checks and trace generation.
- `tests/` -- solver-free regression and repository-integrity tests.
- `results/` -- deterministic generated evidence and the archived licensed SOS transcript.
- `REPRODUCIBILITY.md` -- reproduction instructions and environment metadata.

Public repository: https://github.com/HyConSys/PCCC
