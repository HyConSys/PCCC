# Author: Reza Iraji
"""Dimension-scalable nonlinear switched benchmark and explicit PC-CC."""

from __future__ import annotations

from fractions import Fraction
from typing import Sequence

F = Fraction

X0_Z = (F(0), F(1, 20))
XVF_Z = (F(4, 5), F(19, 20))


def q_value(state: Sequence[F]) -> F:
    if len(state) < 2:
        raise ValueError("state dimension must be at least 2")
    return sum((value * value for value in state[1:]), F(0)) / (len(state) - 1)


def rate(state: Sequence[F], mode: int) -> F:
    q = q_value(state)
    if mode == 1:
        return F(2, 5) + F(1, 10) * q
    if mode == 2:
        return F(3, 10) + F(2, 25) * q
    raise ValueError("mode must be 1 or 2")


def step(state: Sequence[F], mode: int) -> tuple[F, ...]:
    z = state[0]
    r = rate(state, mode)
    beta = F(3, 5) if mode == 1 else F(-7, 10)
    return (z + (F(1) - z) * r, *(beta * value for value in state[1:]))


def certificate(x: Sequence[F], y: Sequence[F]) -> F:
    xz, yz = x[0], y[0]
    return F(500) * ((yz - xz) * (F(6, 5) - yz) - F(1, 20) * (F(1) - xz))


def sos3_expression(x0z: F, yz: F, ypz: F, *, s3b: F = F(41, 20)) -> F:
    x0 = (x0z, F(0))
    y = (yz, F(0))
    yp = (ypz, F(0))
    return certificate(x0, y) - certificate(x0, yp) - F(1) - s3b * certificate(y, yp)


def sos3_exact_minimum() -> tuple[F, tuple[F, F, F]]:
    # E is linear in x0, concave in y, and convex in y'. Therefore x0 and y
    # can be restricted to endpoints and y' to its clipped stationary point.
    candidates: list[tuple[F, tuple[F, F, F]]] = []
    for x0 in X0_Z:
        for y in XVF_Z:
            # dE/dy' = -5*(100*x0 + 205*y - 610*y' + 366)
            stationary = (F(100) * x0 + F(205) * y + F(366)) / F(610)
            yp_values = [XVF_Z[0], XVF_Z[1]]
            if XVF_Z[0] <= stationary <= XVF_Z[1]:
                yp_values.append(stationary)
            for yp in yp_values:
                candidates.append((sos3_expression(x0, y, yp), (x0, y, yp)))
    return min(candidates, key=lambda item: item[0])


def slow_trajectory(dimension: int = 8, horizon: int = 10) -> list[tuple[F, ...]]:
    if dimension < 2:
        raise ValueError("dimension must be at least 2")
    state = (F(0), *(F(0) for _ in range(dimension - 1)))
    trajectory = [state]
    for _ in range(horizon):
        state = step(state, 2)
        trajectory.append(state)
    return trajectory
