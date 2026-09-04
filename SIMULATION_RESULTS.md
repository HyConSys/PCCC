# Verified simulation and exact-arithmetic results

**Paper authors:** Reza Iraji, Felipe Galarza-Jimenez, and Majid Zamani

## Four-visit nonlinear platoon

The physical benchmark is unchanged:

- domain `0 <= x1 <= x2 <= 6`;
- initial leader-follower velocity-difference band `[3.6,3.8]`;
- finite-visit band `[3.2,3.55]`;
- submitted graph `(1,1,1)`, `(1,2,2)`, `(2,2,1)`, `(1,1,2)`.

The repeated-mode-1 witness from `x(0)=(2.4,6)` has velocity differences

```text
t=1  3.2552
t=2  3.2794996608
t=3  3.399123884430082
t=4  3.5359885383919654
t=5  3.6654133881372535
```

so the finite-visit set is visited exactly at times 1-4 and exited at time 5.

Using normalized coordinates

```math
a=x_2/6,\qquad d=(x_2-x_1)/6,
```

the reachable visit set is

```math
T=[5/6,67/75]\times[4069/7500,71/120].
```

The explicit graph-indexed relational family is

```math
C_{p,q}(w,w')=Z(w')-W_{\ell_{pq}}(w),
```

with `C11,C12,C21` of degree at most 2 and `C22` of degree at most 4, together with the affine recurrent rank

```math
R(w)=\frac{91/120-Z(w)}{19/1200}.
```

The archived licensed run reports termination status `OPTIMAL` and primal status `FEASIBLE_POINT` for all 4/4 one-step, 8/8 propagation, rank-nonnegativity, and 2/2 recurrent-node blocks. These are solver-reported statuses, not mathematical strict-feasibility guarantees.

The six order-2 propagation blocks use 256 variables and 12 top-level constraints. The two order-4 propagation blocks use 8,156 variables and 12 top-level constraints and solve in about 0.20 s each. The rank blocks use at most order 2 and 241 variables.

Witness rank drops:

```text
2.58403853473683
2.14404862004549
1.78776782997151
```

This is the paper's **graph-indexed reachability-rank** computation, not original PC-CC3.

## Dimension-scalable original PC-CC benchmark

The paper reports `n=4,8,16` for the two-node graph-indexed construction. The four certificates are

```text
C11 = C0(x1,y1)
C12 = C0(x1,y2)
C21 = C0(x2,y1)
C22 = C0(x2,y2)
```

with

```math
C_0(a,b)=500\left[(b-a)\left(\frac65-b\right)-\frac1{20}(1-a)\right].
```

The all-mode-2 witness visits exactly at times 5-8. PC-CC1 and PC-CC2 are verified by exact inequalities/factorizations. PC-CC3 uses `s2=1`, `s3a=0`, and `s3b=41/20`, with global minimizer

```text
(0, 19/20, 2243/2440)
```

and exact margin

```text
475/3904 > 0.
```

The PC-CC3 antecedent is non-vacuous on the four-visit witness.

## Matched one-node comparison

For

```math
\widehat C_\alpha(x,y)=C_0(z_\alpha(x),z_\alpha(y)),\quad
z_\alpha=\alpha z_1+(1-\alpha)z_2,
```

the exact witness residuals are

```math
r_A(\alpha)=15(25\alpha-16),
```

and

```math
r_B(\alpha)=-5(119\alpha^2-41\alpha-15).
```

The first is negative for `alpha < 16/25`. The second is decreasing on `[16/25,1]` and satisfies `r_B(16/25)=-4689/125<0`. Hence every member of this specified convex-projection family fails PC-CC1, whereas the two-node family succeeds.

The special cases `alpha=1,0,1/2` recover residuals `-315`, `-240`, and `-105/2`, respectively. This is a matched-family comparison, not a claim about unrestricted one-node certificates.
