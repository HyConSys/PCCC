# Author: Reza Iraji
"""Two-node graph-indexed lift of the scalable nonlinear benchmark."""

from __future__ import annotations

from fractions import Fraction
from typing import Sequence

F = Fraction

NODES = (1, 2)
EDGES = ((1, 1, 1), (1, 1, 2), (1, 2, 2), (2, 2, 1))
X0_Z = (F(0), F(1, 20))
XVF_Z = (F(4, 5), F(19, 20))


def q_value(state: Sequence[F]) -> F:
    if len(state) < 3:
        raise ValueError("state dimension must be at least 3")
    return sum((value * value for value in state[2:]), F(0)) / (len(state) - 2)


def rate(state: Sequence[F], mode: int) -> F:
    q = q_value(state)
    if mode == 1:
        return F(2, 5) + F(1, 10) * q
    if mode == 2:
        return F(3, 10) + F(2, 25) * q
    raise ValueError("mode must be 1 or 2")


def progress(z: F, r: F) -> F:
    return z + (F(1) - z) * r


def step(state: Sequence[F], mode: int) -> tuple[F, ...]:
    z1, z2 = state[:2]
    r = rate(state, mode)
    if mode == 1:
        p = progress(z1, r)
        z1p, z2p = p, p
        beta = F(3, 5)
    elif mode == 2:
        z1p, z2p = progress(z2, r), progress(z1, r)
        beta = F(-7, 10)
    else:
        raise ValueError("mode must be 1 or 2")
    return (z1p, z2p, *(beta * value for value in state[2:]))


def scalar_certificate(a: F, b: F) -> F:
    return F(500) * ((b - a) * (F(6, 5) - b) - F(1, 20) * (F(1) - a))


def certificate(p: int, q: int, x: Sequence[F], y: Sequence[F]) -> F:
    if p not in NODES or q not in NODES:
        raise ValueError("graph nodes must be 1 or 2")
    return scalar_certificate(x[p - 1], y[q - 1])


def edge_coordinate_identity(edge: tuple[int, int, int], state: Sequence[F]) -> bool:
    p, mode, q = edge
    successor = step(state, mode)
    expected = progress(state[p - 1], rate(state, mode))
    return successor[q - 1] == expected


def slow_trajectory(dimension: int = 8, horizon: int = 10) -> list[tuple[F, ...]]:
    if dimension < 3:
        raise ValueError("dimension must be at least 3")
    state = (F(0), F(0), *(F(0) for _ in range(dimension - 2)))
    trajectory = [state]
    for _ in range(horizon):
        state = step(state, 2)
        trajectory.append(state)
    return trajectory


def in_initial_set(state: Sequence[F]) -> bool:
    return all(X0_Z[0] <= state[index] <= X0_Z[1] for index in (0, 1))


def in_finite_visit_set(state: Sequence[F]) -> bool:
    return all(XVF_Z[0] <= state[index] <= XVF_Z[1] for index in (0, 1))


def projection_certificate(coordinate: int, x: Sequence[F], y: Sequence[F]) -> F:
    return scalar_certificate(x[coordinate], y[coordinate])


def average_certificate(x: Sequence[F], y: Sequence[F]) -> F:
    xa = (x[0] + x[1]) / 2
    ya = (y[0] + y[1]) / 2
    return scalar_certificate(xa, ya)
