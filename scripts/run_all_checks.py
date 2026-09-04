#!/usr/bin/env python3
# Author: Reza Iraji
"""Run the solver-free reproducibility and repository-integrity suite."""

from __future__ import annotations

import compileall
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GENERATED_FILES = (
    "platoon_audit.json",
    "platoon_corrected_gap.csv",
    "scalable_progress.csv",
    "graph_indexed_progress.csv",
)


def run(*args: str, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, cwd=ROOT, check=True, text=True, capture_output=capture)


def normalized_text(path: Path) -> str:
    return path.read_text(encoding="utf-8").replace("\r\n", "\n").replace("\r", "\n")


def verify_generated_results() -> None:
    with tempfile.TemporaryDirectory(prefix="pccc-check-") as directory:
        out = Path(directory)
        run(sys.executable, "scripts/platoon_audit.py", "--json", str(out / "platoon_audit.json"), capture=True)
        run(sys.executable, "scripts/export_trace_data.py", "--outdir", str(out), capture=True)
        for name in GENERATED_FILES:
            committed = normalized_text(ROOT / "results" / name)
            regenerated = normalized_text(out / name)
            if committed != regenerated:
                raise RuntimeError(f"generated artifact is stale: results/{name}")


def verify_required_files() -> None:
    required = (
        "README.md",
        "REPRODUCIBILITY.md",
        "SIMULATION_RESULTS.md",
        "REVIEWER_EVIDENCE_INDEX.md",
        "REVIEWER_RESPONSE_MATRIX.md",
        "ComplexExample/platoon_model.jl",
        "ComplexExample/verify_normalized_model.jl",
        "ComplexExample/verify_target_local_ranked_pccc.jl",
        "ScalableExample/explicit_degree2_certificate.jl",
        "ScalableExample/scalable_model.py",
        "GraphIndexedExample/explicit_graph_certificate.jl",
        "GraphIndexedExample/graph_indexed_model.py",
        "manuscript/ABSTRACT_REPLACEMENT.tex",
        "manuscript/SIMULATION_SECTION_REPLACEMENT.tex",
        "manuscript/THEOREM_AND_SOS_EDITS.tex",
        "metadata/reproducibility_manifest.json",
    )
    for relative in required:
        if not (ROOT / relative).is_file():
            raise RuntimeError(f"missing reviewer-facing artifact: {relative}")


def main() -> None:
    verify_required_files()
    run(sys.executable, "-m", "unittest", "discover", "-s", "tests", "-v")

    compiled = compileall.compile_dir(ROOT / "scripts", quiet=1)
    compiled &= compileall.compile_dir(ROOT / "ScalableExample", quiet=1)
    compiled &= compileall.compile_dir(ROOT / "GraphIndexedExample", quiet=1)
    compiled &= compileall.compile_dir(ROOT / "tests", quiet=1)
    if not compiled:
        raise RuntimeError("Python bytecode compilation failed")

    verify_generated_results()
    print("All final PCCC reviewer-package checks passed.")


if __name__ == "__main__":
    main()
