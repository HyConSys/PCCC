# Four-visit nonlinear platoon case study

**Lead author and repository maintainer:** Reza Iraji  
**Paper coauthors:** Felipe Galarza-Jimenez and Majid Zamani

## Physical model

The state is `x=[x1,x2]`, where `x1` and `x2` are follower and leader velocities. Thus `x2-x1` is a **leader-follower velocity difference**, not an inter-vehicle spacing.

```math
f_1(x)=\begin{bmatrix}0.01x_2+0.9x_1-0.02x_1^2\\2+0.8x_2-0.04x_2^2\end{bmatrix},\qquad
f_2(x)=\begin{bmatrix}0.9x_1-0.02x_1^2\\2+0.8x_2-0.04x_2^2\end{bmatrix}.
```

```math
\mathcal X=\{x:0\le x_1\le6,\ 0\le x_2\le6,\ x_2\ge x_1\}.
```

The four-visit persistence sets are

```math
\mathcal X_0=\{x\in\mathcal X:3.6\le x_2-x_1\le3.8\},
```

```math
\mathcal X_{\rm vf}=\{x\in\mathcal X:3.2\le x_2-x_1\le3.55\}.
```

The submitted two-node path-complete graph is retained exactly:

```text
(1,1,1), (1,2,2), (2,2,1), (1,1,2).
```

The all-mode-1 trajectory from `x(0)=(2.4,6)` visits `X_vf` at positive times `1,2,3,4`, with velocity differences

```text
3.2552
3.2794996608
3.399123884430082
3.5359885383919654
```

and leaves at time 5 with difference `3.6654133881372535`.

## Forward invariance

The physical domain is forward invariant. The leader update lies in `[2,5.36]`; the follower update lies in `[0,4.74]` for mode 1 and `[0,4.68]` for mode 2. The next-step velocity difference is bounded below by `0.62` in mode 1 and `0.68` in mode 2.

## Normalized coordinates and exact reachability reduction

For conditioning, use the invertible affine coordinates

```math
a=x_2/6,\qquad d=(x_2-x_1)/6,
```

so `0 <= d <= a <= 1`. The dynamics are

```math
a^+=\frac13+\frac45a-\frac6{25}a^2,
```

```math
d_2^+=\frac13-\frac1{10}a-\frac3{25}a^2+\frac9{10}d-\frac6{25}ad+\frac3{25}d^2,
```

```math
d_1^+=d_2^+-\frac1{100}a.
```

The normalized initial and finite-visit intervals are

```math
\frac35\le d\le\frac{19}{30},\qquad
\frac8{15}\le d\le\frac{71}{120}.
```

The exact preflight used in the final verifier establishes:

- the branch `a < 5/6` has zero visits, with exact separation margin `56/1875`;
- the potentially visiting branch starts in
  ```math
  R_0=[5/6,1]\times[3/5,19/30];
  ```
- after one transition under either mode it enters
  ```math
  R_1=[5/6,67/75]\times[4069/7500,5/6];
  ```
- `R1` is forward invariant;
- the reachable target is
  ```math
  T=R_1\cap X_{\rm vf}
   =[5/6,67/75]\times[4069/7500,71/120].
  ```

This is an exact reachability reduction; it does not alter the physical plant or specification.

## Explicit target-local ranked path-complete certificate

Define

```math
Z(a,d)=1-a+d.
```

Mode 1 minimizes the next `Z` value, so set

```math
W_1(w)=Z(f_1(w)),\qquad W_2(w)=W_1(f_1(w)).
```

For the submitted graph, the shortest positive path lengths are

```math
\ell_{11}=\ell_{12}=\ell_{21}=1,\qquad \ell_{22}=2.
```

Use the explicit relational family

```math
C_{p,q}(x,y)=Z(y)-W_{\ell_{pq}}(x).
```

Hence

```math
\deg C_{11}=\deg C_{12}=\deg C_{21}\le2,
\qquad \deg C_{22}\le4.
```

The affine recurrence rank is

```math
R(a,d)=\frac{\frac{91}{120}-Z(a,d)}{\frac{19}{1200}}.
```

The ranked condition is a separate sufficient persistence condition and is **not** relabeled as the original PC-CC3 condition.

## SOS verification and solver-status acceptance

Run

```bash
julia --project=. ComplexExample/verify_target_local_ranked_pccc.jl
```

The verifier checks:

1. one-step graph closure on the full normalized physical state domain;
2. target-local backward propagation to every reachable visit state, retaining the premise as a semialgebraic generator;
3. nonnegativity of `R` on `T`;
4. recurrent-node unit descent of `R` for graph nodes 1 and 2;
5. non-vacuity on all three transitions between the four visits.

The reproduced final run returned `OPTIMAL/FEASIBLE_POINT` for every nontrivial SOS block. On the witness, the three rank drops are approximately

```text
2.58403853473683
2.14404862004549
1.78776782997151
```

all strictly larger than one.

The final console banner is

```text
SUBMITTED-GRAPH REACHABILITY--RANK SOS CERTIFICATE VERIFIED
four visits = VERIFIED
non-vacuous recurrence descent = VERIFIED
plant / physical sets / submitted graph = UNCHANGED
```

`verify_normalized_model.jl` independently checks the physical/normalized coordinate equivalence and four-visit trajectory.
