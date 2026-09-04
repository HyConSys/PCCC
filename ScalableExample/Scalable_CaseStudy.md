# Auxiliary scalar exact-arithmetic kernel

This directory contains the scalar degree-two construction used as an algebraic kernel for the paper's **two-node graph-indexed dimension-scalable benchmark**.

The headline scalable experiment in the revised manuscript is `GraphIndexedExample/`, reported for dimensions `n=4,8,16`. The scalar routines here are retained because they provide reusable exact checks for the common polynomial

```math
C_0(a,b)=500\left[(b-a)\left(\frac65-b\right)-\frac1{20}(1-a)\right]
```

and its PC-CC3 residual.

The exact PC-CC3 margin is

```text
475/3904 > 0
```

at

```text
(a*,b*,c*)=(0,19/20,2243/2440).
```

For the reviewer-facing graph-indexed result and the full matched one-node convex-projection comparison, use:

```bash
julia GraphIndexedExample/explicit_graph_certificate.jl 8
```

No separate SOS solver run is required for the scalable benchmark; the paper reports exact rational/analytic verification.