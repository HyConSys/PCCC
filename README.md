# Path-Complete Closure Certificates (PC-CCs)

Reviewer-facing reproducibility package for **Formal Verification of Switched Systems via Path-Complete Closure Certificates**.

Authors: Reza Iraji, Felipe Galarza-Jimenez, and Majid Zamani. Reza Iraji is the lead author and repository maintainer.

## Verified claims

This repository contains only the experiments used in the revised manuscript:

1. **Four-visit nonlinear platoon.** The nonlinear platoon dynamics, physical state set, four-visit persistence sets, and submitted two-node path-complete graph are unchanged. `ComplexExample/verify_target_local_ranked_pccc.jl` verifies an explicit target-local ranked path-complete SOS certificate. Every nontrivial SOS block must terminate `OPTIMAL` with primal status `FEASIBLE_POINT`.
2. **Scalable original PC-CC3 benchmark.** `ScalableExample/explicit_degree2_certificate.jl` verifies a degree-two relational certificate with four visits and exact PC-CC3 margin `475/3904 > 0`.
3. **Graph-indexed comparison.** `GraphIndexedExample/explicit_graph_certificate.jl` verifies four distinct relational degree-two certificates and a matched sparse one-node comparison.

The ranked platoon condition is a separate sufficient persistence condition; it is **not** relabeled as the original PC-CC3 condition. The scalable and graph-indexed examples exercise original PC-CC3 non-vacuously.

## Quick reproduction

Instantiate the Julia environment:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.status()'
```

Run the solver-free checks:

```bash
python scripts/run_all_checks.py
julia ComplexExample/verify_normalized_model.jl
julia ScalableExample/explicit_degree2_certificate.jl 8
julia GraphIndexedExample/explicit_graph_certificate.jl 8
```

Run the licensed SOS verification for the platoon:

```bash
julia --project=. ComplexExample/verify_target_local_ranked_pccc.jl
```

Publication acceptance policy for numerical SOS blocks:

- `termination_status == OPTIMAL`;
- `primal_status == FEASIBLE_POINT`;
- no `SLOW_PROGRESS`, `ALMOST_OPTIMAL`, or approximate iterate is reported as a certificate.

## Repository layout

- `ComplexExample/` — nonlinear platoon model, normalized-coordinate equivalence, and final strict ranked SOS verifier.
- `ScalableExample/` — exact scalable degree-two original PC-CC benchmark.
- `GraphIndexedExample/` — exact graph-indexed benchmark and matched sparse comparison.
- `scripts/` — deterministic analytical checks and trace generation.
- `tests/` — solver-free regression and repository-integrity tests.
- `results/` — deterministic generated evidence used for figures/tables.
- `manuscript/` — revision-ready LaTeX inserts for the abstract, theory/SOS changes, and simulation section.
- `REVIEWER_EVIDENCE_INDEX.md` and `REVIEWER_RESPONSE_MATRIX.md` — mapping from reviewer concerns to verified evidence.
