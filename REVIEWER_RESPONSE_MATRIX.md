# Reviewer response matrix

**Lead author and repository maintainer:** Reza Iraji  
**Paper coauthors:** Felipe Galarza-Jimenez and Majid Zamani

This matrix reflects the final reviewer-facing evidence after the strict four-visit platoon SOS verification. “Verified” means the supporting derivation/code exists and every numerical SOS block used for a claim meets the strict `OPTIMAL / FEASIBLE_POINT` policy.

## Decision letter

| Issue | Final resolution | Status |
|---|---|---|
| Contribution appears to combine known approaches | Retain the original PC-CC theorem, sharpen the persistence/relational motivation, and add a minimal target-local ranked sufficient proposition for the repeated-visit platoon | Manuscript integration ready |
| Benefit of closure certificates is unclear | Four actual finite-set visits are certified on the submitted platoon graph; a scalable benchmark separately exercises original PC-CC3 non-vacuously | Verified |
| Simulations are unconvincing | Replace the unsupported degree-six result with the strict four-visit platoon SOS verification and exact scalable original-PC-CC3 benchmark | Verified |
| Submitted convex program cannot certify repeated visits | Acknowledge the `s^(3,a)=1` cancellation; do not defend that result. The corrected platoon uses premise-preserving target-local SOS implications plus SOS-R; the scalable benchmark uses valid original-PC-CC3 multipliers | Verified correction |
| Forward invariance is missing | Exact reachability reduction, low-branch separation, and forward-invariant `R1` rectangle are supplied | Verified |
| Theorem/SOS presentation is unclear | Add path-lifting lemma, call the direct SOS encoding a sufficient proposition, and explicitly distinguish original PC-CC3 from the ranked extension | Manuscript integration ready |

## Reviewer 1

| Comment | Final response | Status |
|---|---|---|
| Explain why the approach is needed | Contrast safety invariance with persistence: the verified witness enters `X_vf` four times, so an invariance barrier cannot prove the required property | Manuscript edit ready |
| Benchmark beyond 2D | Add scalable/graph-indexed examples through dimension 16 with degree-two certificates | Verified |
| Compare to other methods | Give the structural barrier comparison; do not fabricate an external runtime comparison | Manuscript edit ready |
| Graph/system notation too similar | Rename the graph consistently and reserve a distinct symbol for the switched system | Final manuscript QA |
| Theorem proof too long / path uniqueness unclear | Use the path-lifting lemma; state that compatible paths need not be unique | Support text ready |
| SOS result should not be a corollary | Present it as “SOS sufficient conditions for PC-CCs” | Support text ready |

## Reviewer 3

| Comment | Final response | Status |
|---|---|---|
| Show genuine repeated visits | Platoon has four verified visits with active recurrent SOS descent; scalable benchmark exercises original PC-CC3 non-vacuously | Verified |
| Clarify graph/dynamics connection | Add framing sentence before the theorem and path-lifting lemma | Support text ready |
| Position within infinite-horizon verification | State persistence as `F G \neg X_vf` and add primary temporal-verification references | Bibliography integration required |
| Abstract | Replace with `manuscript/ABSTRACT_REPLACEMENT.tex` | Ready |

## Reviewer 5

| Comment | Final response | Status |
|---|---|---|
| Unit-multiplier SOS-3 cancellation | Explicitly concede the error and remove the submitted degree-six claim | Verified correction |
| Two-node certificates lose source-state dependence | Platoon closure depends on source state through `W_{\ell_{pq}}(x)`; graph-indexed benchmark has four distinct mixed source/destination polynomials | Verified |
| Show graph benefit | Matched sparse one-node PC-CC1 residuals are `-315`, `-240`, `-105/2`, while the two-node family succeeds | Verified within matched sparse class |
| Forward invariance | Exact low-branch separation, `R0 -> R1`, and `R1` invariance are supplied | Verified |
| Completeness | Do not claim unrestricted completeness or polynomial-degree completeness | Limitation text ready |
| `|V|^3` scaling | Report original-PC-CC block counts and ranked formulation block counts separately | Support text ready |
| Figure/notation/grammar/running header | Apply during final six-page integration and visual PDF QA | Final manuscript QA |
| Solver times/problem sizes | Final platoon transcript reports SOS order, polynomial degree, wall time, JuMP variables, top-level constraints, termination and primal status for every block; the reproduction environment is also recorded (MOSEK 11.2.0; Snapdragon X 12-core; 68,171,038,720 bytes RAM; Windows 11 Pro ARM64) | Verified |

## Final four-visit platoon evidence

- Physical plant, physical domain, `X0`, `Xvf`, and submitted two-node graph are unchanged.
- Exact witness visits: `1,2,3,4`.
- Low-`a` zero-visit separation margin: `56/1875`.
- Reachable target: `T = R1 \cap Xvf` with forward-invariant `R1`.
- Explicit closure:
  ```math
  C_{p,q}(x,y)=Z(y)-W_{\ell_{pq}}(x),
  ```
  with `C11,C12,C21` degree at most two and `C22` degree at most four.
- Affine rank:
  ```math
  R(a,d)=\frac{91/120-Z(a,d)}{19/1200}.
  ```
- 4/4 one-step closure blocks, 8/8 target-local propagation blocks, rank nonnegativity, and 2/2 SOS-R blocks all return `OPTIMAL / FEASIBLE_POINT`.
- Largest SOS block: Putinar order 4, 8,156 JuMP variables, 12 top-level constraint objects; final reproduction times for the two order-4 TL-PC2 blocks were approximately 0.209 s and 0.210 s.
- Witness rank drops: approximately `2.5840`, `2.1440`, `1.7878`.
- Exact console record: `results/final_ranked_platoon_sos.txt`.

The ranked formulation is a **separate sufficient proposition** and must not be described as original PC-CC3.

## Direct original-PC-CC3 evidence

The scalable/graph-indexed benchmark supplies the direct original-PC-CC1--PC-CC3 validation:

- four visits;
- degree-two relational certificates;
- dimensions through 16;
- fixed multipliers `s^(2)=1`, `s^(3,a)=0`, `s^(3,b)=41/20`;
- exact PC-CC3 margin `475/3904 > 0`;
- matched sparse one-node residuals `-315`, `-240`, `-105/2`.

## Response posture

1. Thank Reviewer 5 for identifying the cancellation and state plainly that the submitted numerical result was removed.
2. Present the strict same-plant/same-graph four-visit platoon ranked SOS result as the replacement engineering experiment.
3. Present the scalable graph-indexed example as the direct non-vacuous original-PC-CC3 experiment and higher-dimensional evidence.
4. Keep all graph-benefit and nonexistence claims limited to the documented template classes.
5. Report only strict verified numerical evidence; exploratory failed searches are not part of the reviewer-facing package.
