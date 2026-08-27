# Two-node graph-indexed, dimension-scalable benchmark

**Lead author and repository maintainer:** Reza Iraji  
**Paper coauthors:** Felipe Galarza-Jimenez and Majid Zamani


This is the strongest reviewer-facing example in the revision. It simultaneously exercises repeated visits, relational source-state dependence, graph indexing, nonlinear coupling, and state dimensions above two while retaining degree-2 certificates.

## Dynamics and graph

Let `x=(z_1,z_2,u)` belong to

```math
\mathcal X=[0,1]^2\times[-1,1]^{n-2},\qquad n\ge3,
```

and set

```math
q(u)=\frac1{n-2}\sum_{i=3}^n u_i^2,
\quad r_1=\frac25+\frac1{10}q,
\quad r_2=\frac3{10}+\frac2{25}q,
\quad P_\sigma(z)=z+(1-z)r_\sigma.
```

The modes are

```math
f_1(x)=\big(P_1(z_1),P_1(z_1),(3/5)u\big),
```

```math
f_2(x)=\big(P_2(z_2),P_2(z_1),(-7/10)u\big).
```

Use the two-node path-complete graph

```text
(1,1,1), (1,1,2), (1,2,2), (2,2,1).
```

For every edge `(p,sigma,q)`, destination coordinate `q` after the transition is exactly `P_sigma(z_p)`. The graph therefore selects the correct progress coordinate for every switching word.

## Specification

Both progress coordinates start in `[0,1/20]`. The finite-visit set requires both to lie in `[4/5,19/20]`. Starting from zero and repeatedly applying mode 2 keeps the coordinates equal and yields exactly four visits at times 5--8. The lower rate bound `r_sigma>=3/10` proves that no execution can have more than four visits.

## Four distinct relational certificates

Let

```math
C_0(a,b)=500\left[(b-a)\left(\frac65-b\right)-\frac1{20}(1-a)\right].
```

Define

```math
C_{p,q}(x,y)=C_0(x_p,y_q),\qquad p,q\in\{1,2\}.
```

Thus

```text
C_11=C0(x1,y1), C_12=C0(x1,y2),
C_21=C0(x2,y1), C_22=C0(x2,y2).
```

All four functions are degree 2, contain a mixed source/destination term, and are symbolically distinct. PC-CC1 and PC-CC2 reduce edge-wise to the scalar nonnegative factorizations in `ScalableExample`. PC-CC3 reduces to the same exact product-domain polynomial with fixed multipliers `s2=1`, `s3a=0`, `s3b=41/20` and margin `475/3904`.

## Controlled one-node comparison

A one-node certificate using either fixed progress coordinate with the same sparse degree-2 template fails PC-CC1:

```text
C0(z1, f2_1(x)) = -315 at (z1,z2)=(1,0),
C0(z2, f1_2(x)) = -240 at (z1,z2)=(0,1).
```

The average-coordinate version also fails (`-52.5` at `(z1,z2)=(0,1)` in mode 1). The graph-indexed family succeeds because its node labels switch the tracked coordinate consistently with the dynamics. This is a template-class comparison, not a claim that no unrestricted one-node polynomial certificate exists.

Run

```bash
python -m unittest discover -s tests -v
julia GraphIndexedExample/explicit_graph_certificate.jl 8
```
