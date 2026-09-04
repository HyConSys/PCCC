# Result provenance

**Lead author and repository maintainer:** Reza Iraji  
**Paper coauthors:** Felipe Galarza-Jimenez and Majid Zamani

This directory contains only deterministic or final reviewer-facing result artifacts.

## Final licensed platoon SOS record

`final_ranked_platoon_sos.txt` is the reproduced console record for

```bash
julia --project=. ComplexExample/verify_target_local_ranked_pccc.jl
```

Every nontrivial SOS block in that record terminated `OPTIMAL/FEASIBLE_POINT`. The file also records the four visit times and the three non-vacuous rank drops.

## Deterministic analytical artifacts

Regenerate with

```bash
python scripts/platoon_audit.py --json results/platoon_audit.json
python scripts/export_trace_data.py --outdir results
```

Files:

- `platoon_audit.json` — exact/rational behavioral and forward-invariance audit data;
- `platoon_corrected_gap.csv` — four-visit platoon trace for plotting;
- `scalable_progress.csv` — exact scalable benchmark trace;
- `graph_indexed_progress.csv` — exact graph-indexed benchmark trace.

`python scripts/run_all_checks.py` regenerates these deterministic files in a temporary directory and compares them with the committed copies.

Exploratory failed-search logs are intentionally excluded from the reviewer-facing package.
