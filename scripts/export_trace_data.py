#!/usr/bin/env python3
# Author: Reza Iraji
"""Export deterministic trace data used by the revised simulation section."""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
sys.path.insert(0, str(ROOT / "ScalableExample"))
sys.path.insert(0, str(ROOT / "GraphIndexedExample"))

import platoon_audit
import scalable_model
import graph_indexed_model


def write_platoon(path: Path) -> None:
    trajectory = platoon_audit.corrected_witness(12)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(["time", "velocity_difference", "in_Xvf"])
        for time, state in enumerate(trajectory):
            value = platoon_audit.velocity_difference(state)
            visit = platoon_audit.CORRECTED_XVF[0] <= value <= platoon_audit.CORRECTED_XVF[1]
            writer.writerow([time, f"{float(value):.15g}", int(visit)])


def write_scalable(path: Path) -> None:
    trajectory = scalable_model.slow_trajectory(8, 12)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(["time", "z", "in_Xvf", "C_x0_y"])
        x0 = trajectory[0]
        for time, state in enumerate(trajectory):
            visit = scalable_model.XVF_Z[0] <= state[0] <= scalable_model.XVF_Z[1]
            writer.writerow([
                time,
                f"{float(state[0]):.15g}",
                int(visit),
                f"{float(scalable_model.certificate(x0, state)):.15g}",
            ])


def write_graph_indexed(path: Path) -> None:
    trajectory = graph_indexed_model.slow_trajectory(8, 12)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.writer(handle, lineterminator="\n")
        writer.writerow(["time", "z1", "z2", "in_Xvf", "C_11_x0_y"])
        x0 = trajectory[0]
        for time, state in enumerate(trajectory):
            visit = graph_indexed_model.in_finite_visit_set(state)
            writer.writerow([
                time,
                f"{float(state[0]):.15g}",
                f"{float(state[1]):.15g}",
                int(visit),
                f"{float(graph_indexed_model.certificate(1, 1, x0, state)):.15g}",
            ])


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--outdir",
        type=Path,
        default=ROOT / "results",
        help="directory for generated CSV files (default: repository results/)",
    )
    args = parser.parse_args()
    args.outdir.mkdir(parents=True, exist_ok=True)
    write_platoon(args.outdir / "platoon_corrected_gap.csv")
    write_scalable(args.outdir / "scalable_progress.csv")
    write_graph_indexed(args.outdir / "graph_indexed_progress.csv")


if __name__ == "__main__":
    main()
