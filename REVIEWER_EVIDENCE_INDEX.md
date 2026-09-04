# Reviewer evidence index

**Lead author and repository maintainer:** Reza Iraji  
**Paper coauthors:** Felipe Galarza-Jimenez and Majid Zamani

This index connects each major review concern to the final reproducible artifact.

| Review concern | Resolution | Primary evidence | Status |
|---|---|---|---|
| Contribution appears to combine known methods | Original PC-CC theorem is retained; a minimal target-local ranked path-complete proposition is added for repeated visits on the platoon | `manuscript/THEOREM_AND_SOS_EDITS.tex` | Ready for manuscript integration |
| Benchmark is only two-dimensional | Exact nonlinear scalable/graph-indexed benchmarks are verified through dimensions 16 | `ScalableExample/`, `GraphIndexedExample/` | Verified |
| Repeated-visit evidence is vacuous | Platoon has four actual visits with active recurrent SOS descent; scalable benchmark directly exercises original PC-CC3 non-vacuously | `ComplexExample/verify_target_local_ranked_pccc.jl`, `ScalableExample/`, `GraphIndexedExample/` | Verified |
| Submitted degree-6/four-visit result is questionable | The unsupported result and its legacy search artifacts are removed from the reviewer-facing package and replaced by the strict ranked-platoon result | `SIMULATION_RESULTS.md`, `results/final_ranked_platoon_sos.txt` | Verified correction |
| Unit `s^(3,a)` cancels PC-CC3 term | The cancellation is acknowledged in the response; final platoon verification uses premise-preserving target-local SOS implications rather than the invalid fixed multiplier | `ComplexExample/verify_target_local_ranked_pccc.jl`, `REVIEWER_RESPONSE_MATRIX.md` | Verified correction |
| Two-node functions collapse to destination-only functions | Final platoon closure depends on source state through `W_{ell_pq}(x)`; graph-indexed benchmark has four distinct mixed source/destination polynomials | `ComplexExample/verify_target_local_ranked_pccc.jl`, `GraphIndexedExample/` | Verified |
| Show graph benefit over one node | Matched sparse one-node templates fail PC-CC1 exactly while the two-node graph-indexed family succeeds | `GraphIndexedExample/Graph_Indexed_CaseStudy.md` | Verified within matched sparse class |
| Forward invariance is missing | Exact low-branch separation, `R0 -> R1`, and `R1` invariance establish the reachable visit set `T` | `ComplexExample/verify_target_local_ranked_pccc.jl`, `ComplexExample/Complex_CaseStudy.md` | Verified |
| Solver times/model sizes missing | Every final platoon SOS block reports order, degree, status, time, variables, and constraints; largest reported block has 8,156 JuMP variables | `SIMULATION_RESULTS.md`, `results/final_ranked_platoon_sos.txt` | Verified; CPU/RAM metadata pending |
| Numerical scaling may obscure result | Equivalent normalized leader/velocity-difference coordinates are algebraically checked against the physical dynamics | `ComplexExample/verify_normalized_model.jl`, `ComplexExample/platoon_model.jl` | Verified |
| Rich graph scaling unclear | Direct original-PC-CC counts and target-local ranked block counts are stated separately | `manuscript/THEOREM_AND_SOS_EDITS.tex` | Documented |
| Theorem proof/path existence unclear | Path-lifting lemma supplied; compatible path need not be unique | `manuscript/THEOREM_AND_SOS_EDITS.tex` | Ready for manuscript integration |
| Persistence positioning missing | Revision materials frame persistence as an infinite-horizon property and preserve direct original-PC-CC3 evidence | `manuscript/ABSTRACT_REPLACEMENT.tex`, `manuscript/SIMULATION_SECTION_REPLACEMENT.tex` | Citation integration required |

## Final platoon claim

Same nonlinear plant, same physical state domain, same four-visit `X0`/`Xvf` specification, and same submitted two-node path-complete graph. An explicit graph-indexed polynomial closure family of degrees 2/4 together with an affine nonnegative rank satisfies the target-local ranked persistence proposition. Every nontrivial Positivstellensatz/SOS block terminates `OPTIMAL / FEASIBLE_POINT`, and the recurrent mechanism is active on all three transitions between the four visits.

This result is **not** described as original PC-CC3.

## Direct original-PC-CC3 claim

The scalable/graph-indexed benchmark supplies the direct original-PC-CC1--PC-CC3 evidence:

- four visits;
- degree-two relational certificates;
- exact PC-CC3 margin `475/3904 > 0`;
- dimensions through 16;
- matched sparse one-node failures `-315`, `-240`, and `-105/2`.

## Claims intentionally limited

- No global nonexistence claim is made for unrestricted one-node or scalar polynomial PC-CCs.
- Failed degree sweeps and CEGIS runs are not part of this reviewer-facing package.
- The ranked platoon proposition is a separate sufficient condition, not a renaming of PC-CC3.
- The graph-benefit comparison is limited to the matched sparse template class.
- No unsupported external-tool runtime comparison is reported.
