# Verified simulation results

**Lead author and repository maintainer:** Reza Iraji  
**Paper coauthors:** Felipe Galarza-Jimenez and Majid Zamani

## Reproducibility environment

The final reviewer-facing checks were reproduced on Microsoft Windows 11 Pro 10.0.26200 (ARM64) using Python 3.12, Julia 1.12.6, TSSOS 1.5.2, JuMP, MosekTools 0.15.10, Mosek.jl 11.2.0, and MOSEK 11.2.0. The final licensed SOS run used a Snapdragon(R) X 12-core X1E80100 @ 3.40 GHz CPU (12 physical cores, 12 logical processors) with 68,171,038,720 bytes of physical memory.

## Automated checks

```text
python scripts/run_all_checks.py
```

The command runs the final solver-free regression/integrity suite and regenerates deterministic result files. On the final clean clone it completed 14/14 tests successfully. `ComplexExample/verify_normalized_model.jl` independently confirms the normalized coordinates and four-visit witness.

## Four-visit nonlinear platoon: final verified result

The physical benchmark is unchanged:

- nonlinear two-car platoon dynamics;
- submitted two-node graph `(1,1,1)`, `(1,2,2)`, `(2,2,1)`, `(1,1,2)`;
- physical domain `0 <= x1 <= x2 <= 6`;
- initial velocity-difference band `[3.6,3.8]`;
- finite-visit velocity-difference band `[3.2,3.55]`.

Using normalized coordinates

```math
a=x_2/6,\qquad d=(x_2-x_1)/6,
```

the exact reachability preflight establishes a zero-visit low-`a` branch with separation margin `56/1875`, the potentially visiting rectangle

```math
R_0=[5/6,1]\times[3/5,19/30],
```

and the forward-invariant post-transition rectangle

```math
R_1=[5/6,67/75]\times[4069/7500,5/6].
```

Every reachable visit therefore lies in

```math
T=[5/6,67/75]\times[4069/7500,71/120].
```

The repeated-mode-1 witness from `x(0)=(2.4,6)` visits at times `1,2,3,4`, with physical velocity differences

```text
3.2552
3.2794996608
3.399123884430082
3.5359885383919654
```

and leaves at time 5 with `3.6654133881372535 > 3.55`.

### Explicit target-local ranked polynomial certificate

Define

```math
Z(a,d)=1-a+d,
```

```math
W_1(w)=Z(f_1(w)),\qquad W_2(w)=W_1(f_1(w)).
```

For submitted-graph shortest positive path lengths

```math
\ell_{11}=\ell_{12}=\ell_{21}=1,\qquad \ell_{22}=2,
```

use

```math
C_{p,q}(x,y)=Z(y)-W_{\ell_{pq}}(x).
```

Thus `C11`, `C12`, and `C21` have degree at most two and `C22` degree at most four. The affine recurrent rank is

```math
R(a,d)=\frac{91/120-Z(a,d)}{19/1200}.
```

`ComplexExample/verify_target_local_ranked_pccc.jl` strictly verifies:

- 4/4 one-step graph-closure blocks;
- 8/8 target-local backward-propagation blocks;
- rank nonnegativity on `T`;
- 2/2 recurrent-node unit-descent blocks.

Every nontrivial block terminates `OPTIMAL / FEASIBLE_POINT`. The largest reported block uses Putinar order 4, 8,156 JuMP variables, and 12 top-level constraint objects. In the final clean-clone reproduction, the two order-4 TL-PC2 blocks solved in approximately 0.209 s and 0.210 s, respectively. The exact reproduced console record is `results/final_ranked_platoon_sos.txt`.

On the four-visit witness, the three rank drops are

```text
2.58403853473683
2.14404862004549
1.78776782997151
```

all strictly above the required unit decrease.

This is a strict SOS certificate for the **target-local ranked path-complete persistence proposition**. It is not labeled as the original PC-CC3 condition.

## Direct original PC-CC3 benchmark

The scalable/graph-indexed benchmark independently validates the original PC-CC1--PC-CC3 framework:

- tested dimensions through 16;
- four positive-time visits;
- degree-two relational certificates;
- fixed multipliers `s2=1`, `s3a=0`, `s3b=41/20`;
- exact original-PC-CC3 margin `475/3904 > 0`;
- four distinct graph-indexed relational certificates;
- matched sparse one-node PC-CC1 residuals `-315`, `-240`, and `-105/2`.

The one-node comparison is limited to the documented matched sparse template class.

## Correction of the submitted numerical claim

The previous degree-six/four-visit platoon numerical claim is removed. The submitted implementation fixed `s^(3,a)=1`, which cancels the relevant closure term in SOS-3. No archived or exploratory failed search is part of the reviewer-facing evidentiary chain.

## Numerical acceptance policy

A numerical SOS block is reported only with

```text
termination = OPTIMAL
primal      = FEASIBLE_POINT
```

`SLOW_PROGRESS`, `ALMOST_OPTIMAL`, `TIME_LIMIT`, and approximate incumbents are never treated as proofs.
