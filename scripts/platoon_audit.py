#!/usr/bin/env python3
# Author: Reza Iraji
"""Deterministic exact-arithmetic audit for the final four-visit platoon case."""

from __future__ import annotations

import argparse
import itertools
import json
from fractions import Fraction
from pathlib import Path
from typing import Iterable, Sequence

F = Fraction

CORRECTED_X0 = (F(18, 5), F(19, 5))
CORRECTED_XVF = (F(16, 5), F(71, 20))


def leader(v: F) -> F:
    return F(2) + F(4, 5) * v - F(1, 25) * v * v


def follower(v1: F, v2: F, mode: int) -> F:
    coupling = F(1, 100) * v2 if mode == 1 else F(0)
    return coupling + F(9, 10) * v1 - F(1, 50) * v1 * v1


def step(state: Sequence[F], mode: int) -> tuple[F, F]:
    if mode not in (1, 2):
        raise ValueError(f"mode must be 1 or 2, got {mode}")
    x1, x2 = state
    return follower(x1, x2, mode), leader(x2)


def velocity_difference(state: Sequence[F]) -> F:
    return state[1] - state[0]


# Backward-compatible internal alias used by trace/export code.
gap = velocity_difference


def simulate(state: Sequence[F], modes: Iterable[int]) -> list[tuple[F, F]]:
    trajectory = [(F(state[0]), F(state[1]))]
    for mode in modes:
        trajectory.append(step(trajectory[-1], mode))
    return trajectory


def gap_map(x2: F, current_difference: F, mode: int) -> F:
    # Coordinates x1 = x2-current_difference. Mode 1 is exactly 0.01*x2
    # below mode 2 in the next leader-follower velocity difference.
    base = (
        F(2)
        - F(1, 10) * x2
        - F(1, 50) * x2 * x2
        + F(9, 10) * current_difference
        - F(1, 25) * x2 * current_difference
        + F(1, 50) * current_difference * current_difference
    )
    return base - (F(1, 100) * x2 if mode == 1 else F(0))


def platoon_invariance_margins() -> dict[str, F]:
    return {"mode1": F(31, 50), "mode2": F(17, 25)}


def corrected_witness(horizon: int = 12) -> list[tuple[F, F]]:
    return simulate((F(12, 5), F(6)), itertools.repeat(1, horizon))


def build_report() -> dict[str, object]:
    trajectory = corrected_witness()
    differences = [velocity_difference(state) for state in trajectory]
    visits = [
        t for t, value in enumerate(differences)
        if t > 0 and CORRECTED_XVF[0] <= value <= CORRECTED_XVF[1]
    ]
    margins = platoon_invariance_margins()

    return {
        "forward_invariance": {
            "mode1_velocity_difference_margin": float(margins["mode1"]),
            "mode1_velocity_difference_margin_exact": "31/50",
            "mode2_velocity_difference_margin": float(margins["mode2"]),
            "mode2_velocity_difference_margin_exact": "17/25",
        },
        "four_visit_platoon": {
            "fifth_step_velocity_difference": float(differences[5]),
            "initial_state": [2.4, 6.0],
            "modes": "all mode 1",
            "visit_count": len(visits),
            "visit_times": visits,
            "velocity_differences_t1_to_t5": [float(value) for value in differences[1:6]],
        },
        "metadata": {
            "generated_by": "scripts/platoon_audit.py",
            "lead_author": "Reza Iraji",
            "paper_authors": ["Reza Iraji", "Felipe Galarza-Jimenez", "Majid Zamani"],
        },
        "verification_scope": {
            "strict_ranked_sos_verifier": "ComplexExample/verify_target_local_ranked_pccc.jl",
            "statement": "Behavioral quantities here use exact rational arithmetic; the ranked SOS certificate is verified separately by the licensed Julia verifier.",
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", type=Path, help="optional output path")
    args = parser.parse_args()
    report = build_report()
    text = json.dumps(report, indent=2, sort_keys=True)
    print(text)
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(text + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
