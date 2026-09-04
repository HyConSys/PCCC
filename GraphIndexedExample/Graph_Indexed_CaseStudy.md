# Two-node graph-indexed dimension-scalable benchmark

**Paper authors:** Reza Iraji, Felipe Galarza-Jimenez, and Majid Zamani

This is the dimension-scalable **original PC-CC** benchmark reported in the revised paper for `n=4,8,16`.

## Dynamics and graph

Let

```math
x=(z_1,z_2,u)\in[0,1]^2\times[-1,1]^{n-2},\qquad n\ge3,
```

with

```math
q(u)=\frac1{n-2}\sum_{i=3}^n u_i^2,\quad
r_1=\frac25+\frac1{10}q,\quad
r_2=\frac3{10}+\frac2{25}q,
```

and `P_sigma(z)=z+(1-z)r_sigma`.

The modes are

```math
f_1(x)=(P_1(z_1),P_1(z_1),(3/5)u),
```

```math
f_2(x)=(P_2(z_2),P_2(z_1),(-7/10)u).
```

Use the two-node path-complete graph

```text
(1,1,1), (1,1,2), (1,2,2), (2,2,1).
```

For each edge `(p,sigma,q)`, the destination progress coordinate after the transition equals `P_sigma(z_p)`. Thus the graph indices retain the appropriate source and destination progress coordinates.

## Specification and four visits

Both progress coordinates start in `[0,1/20]`. The finite-visit set requires both to lie in `[4/5,19/20]`. From the origin under repeated mode 2, the trajectory visits exactly at times 5, 6, 7, and 8 and exits at time 9.

## Four distinct degree-two relational certificates

Define

```math
C_0(a,b)=500\left[(b-a)\left(\frac65-b\right)-\frac1{20}(1-a)\right],
```

and

```math
C_{p,q}(x,y)=C_0(x_p,y_q).
```

Hence

```text
C11=C0(x1,y1)
C12=C0(x1,y2)
C21=C0(x2,y1)
C22=C0(x2,y2)
```

are four distinct mixed source/destination degree-two certificates.

PC-CC1 and PC-CC2 reduce edge-wise to exact nonnegative scalar factorizations. PC-CC3 uses

```text
s2=1, s3a=0, s3b=41/20
```

and the exact residual has global minimizer

```text
(a*,b*,c*)=(0,19/20,2243/2440)
```

with

```text
min Delta = 475/3904 > 0.
```

The four-visit witness makes the PC-CC3 antecedent non-vacuous.

## Full matched convex-projection one-node comparison

Consider the specified one-node family

```math
\widehat C_\alpha(x,y)=C_0(z_\alpha(x),z_\alpha(y)),\qquad
z_\alpha=\alpha z_1+(1-\alpha)z_2,\quad \alpha\in[0,1].
```

Two exact PC-CC1 witness residuals are

```math
r_A(\alpha)=500\left(\frac{3\alpha}{4}-\frac{12}{25}\right)
           =15(25\alpha-16),
```

and

```math
r_B(\alpha)=500\left(\frac3{20}+\frac{41\alpha}{100}
                    -\frac{119\alpha^2}{100}\right)
           =-5(119\alpha^2-41\alpha-15).
```

For `alpha < 16/25`, `r_A(alpha) < 0`. For `alpha >= 16/25`,

```math
r_B'(\alpha)=205-1190\alpha=-5(238\alpha-41)<0,
```

so `r_B` is decreasing on `[16/25,1]`, and

```math
r_B(16/25)=-4689/125<0.
```

Therefore every member of this specified convex-projection family violates PC-CC1, while the two-node graph-indexed family succeeds. The coordinate projections and average are only special cases. This comparison does not exclude unrestricted one-node certificates.

## Reproduction

```bash
julia GraphIndexedExample/explicit_graph_certificate.jl 8
python scripts/run_all_checks.py
```