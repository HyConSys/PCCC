# Reproducibility protocol

**Lead author and repository maintainer:** Reza Iraji  
**Paper coauthors:** Felipe Galarza-Jimenez and Majid Zamani

## Evidence hierarchy

The revised repository uses two evidence classes.

1. **Exact, solver-free evidence.** Rational-arithmetic scripts and deterministic regression tests establish the four-visit traces, the physical/normalized platoon equivalence, the scalable degree-two certificate, the graph-indexed degree-two certificate, the exact original PC-CC3 margin `475/3904`, and the matched sparse one-node counterexamples.
2. **Strict licensed SOS evidence.** The four-visit platoon ranked certificate is accepted only when every nontrivial Positivstellensatz/SOS block terminates `OPTIMAL` with primal status `FEASIBLE_POINT`.

No `SLOW_PROGRESS`, `ALMOST_OPTIMAL`, rounded iterate, or exploratory failed search is part of the reviewer-facing evidentiary chain.

## Solver-free verification

Run:

```bash
python scripts/run_all_checks.py
julia ComplexExample/verify_normalized_model.jl
julia ScalableExample/explicit_degree2_certificate.jl 8
julia GraphIndexedExample/explicit_graph_certificate.jl 8
```

`python scripts/run_all_checks.py` runs the regression suite, compiles Python sources, regenerates deterministic result files in a temporary directory, and compares them against the committed artifacts. The final clean clone completed all 14 tests successfully.

## Julia environment

Instantiate and precompile the committed environment:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate(); Pkg.precompile()'
```

The final reproduction used:

- Julia 1.12.6;
- TSSOS 1.5.2;
- MosekTools 0.15.10;
- Mosek.jl 11.2.0;
- MOSEK runtime/API 11.2.0.

`Mosek` is a transitive dependency of `MosekTools`, so `using Mosek` is not guaranteed to work from this project. To query manifest package versions on PowerShell, use:

```powershell
julia --project=. -e "using Pkg; Pkg.status(; mode=Pkg.PKGMODE_MANIFEST)" |
    Select-String "Mosek"
```

To query the MOSEK runtime/API version, use:

```powershell
julia --project=. -e "using MosekTools; println(MosekTools.Mosek.getversion())"
```

## Final four-visit platoon SOS verification

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
- target-local one-step graph closure;
- target-local backward propagation with the premise retained as a semialgebraic generator;
- nonnegative affine rank on the reachable target set;
- recurrent-node unit rank descent.

Every nontrivial block in the final clean-clone run terminated `OPTIMAL/FEASIBLE_POINT`. The largest block used Putinar order 4, 8,156 JuMP variables, and 12 top-level constraint objects. The two largest TL-PC2 blocks solved in approximately 0.209 s and 0.210 s in the final reproduction. The four-visit witness exhibited rank drops approximately `2.5840`, `2.1440`, and `1.7878`.

## Original PC-CC3 benchmark

Run:

```bash
julia ScalableExample/explicit_degree2_certificate.jl 8
julia GraphIndexedExample/explicit_graph_certificate.jl 8
```

The exact degree-two certificate has original PC-CC3 margin

```text
475/3904 > 0
```

and is non-vacuous over four visits. The graph-indexed construction uses four distinct relational certificates and documents the bounded matched sparse one-node comparison.

## Deterministic generated results

Regenerate:

```bash
python scripts/platoon_audit.py --json results/platoon_audit.json
python scripts/export_trace_data.py --outdir results
```

Committed generated artifacts are checked byte-for-byte modulo newline normalization by `scripts/run_all_checks.py`.

## Final reproduction machine

The final licensed SOS run was reproduced on:

- Microsoft Windows 11 Pro, version 10.0.26200, ARM64;
- Snapdragon(R) X 12-core X1E80100 @ 3.40 GHz;
- 12 physical cores and 12 logical processors;
- 68,171,038,720 bytes physical memory (approximately 63.5 GiB).

The manuscript should report the OS, CPU, RAM, Julia version, TSSOS version, MosekTools/Mosek.jl/MOSEK versions, SOS orders, wall times, JuMP variable counts, top-level constraint counts, and strict termination/primal statuses for the final platoon verifier.
