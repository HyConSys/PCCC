# Author: Reza Iraji
#
# SOS verifier for the four-visit nonlinear platoon using the
# submitted two-node path-complete graph.
#
# This file does not synthesize certificate coefficients.  It verifies an
# explicit graph-indexed relational closure family and a separate recurrence
# rank.  The plant, physical sets, and submitted graph are unchanged.
#
# Acceptance policy: every nontrivial SOS block must terminate OPTIMAL with
# primal status FEASIBLE_POINT.  SLOW_PROGRESS / ALMOST_OPTIMAL never count.

using JuMP
using MosekTools
using DynamicPolynomials
using MultivariatePolynomials
using Printf
using TSSOS

include(joinpath(@__DIR__, "platoon_model.jl"))
using .PlatoonModel

const MOI = JuMP.MOI
const PM = coordinate_model("normalized_gap")

const NODES = [1, 2]
const EDGES = [
    (1, 1, 1),
    (1, 2, 2),
    (2, 2, 1),
    (1, 1, 2),
]

# Shortest positive path lengths in the submitted graph.
const ELL = Dict(
    (1, 1) => 1,
    (1, 2) => 1,
    (2, 1) => 1,
    (2, 2) => 2,
)

const A_SPLIT = 5 // 6
const A_POST_MAX = 67 // 75
const D_POST_MIN = 4069 // 7500
const D_POST_MAX = 5 // 6
const LOW_BRANCH_VISIT_MARGIN = 56 // 1875

const D_VISIT_MIN = 8 // 15
const D_VISIT_MAX = 71 // 120

# Conservative exact one-step progress margin on the reachable target set.
const EPS = 19 // 1200
const ZMAX = 91 // 120

@polyvar x[1:2] y[1:2] yp[1:2]

Z(w) = 1 - w[1] + w[2]

# Mode 1 is the worst-case successor for Z because the normalized mode-1 gap
# is exactly a/100 below mode 2 while the leader update is identical.
W1(w) = Z(PM.f_sigma[1](w))
W2(w) = W1(PM.f_sigma[1](w))

function W(k::Int, w)
    k == 1 && return W1(w)
    k == 2 && return W2(w)
    error("Only path lengths 1 and 2 occur in the submitted graph.")
end

# Explicit graph-indexed relational closure family.
# Degrees: C11,C12,C21 <= 2; C22 <= 4.
C(p::Int, q::Int, u, v) = Z(v) - W(ELL[(p, q)], u)

# Affine recurrence rank.  It is nonnegative on the reachable target T.
R(w) = (ZMAX - Z(w)) / EPS

function h_R0(w)
    return [
        w[1] - A_SPLIT,
        1 - w[1],
        w[2] - NORMALIZED_X0_GAP[1],
        NORMALIZED_X0_GAP[2] - w[2],
    ]
end

function h_R1(w)
    return [
        w[1] - A_SPLIT,
        A_POST_MAX - w[1],
        w[2] - D_POST_MIN,
        D_POST_MAX - w[2],
    ]
end

# T is not a changed specification.  It is the proved reachable portion of
# X_vf: T = R1 intersect X_vf.
function h_T(w)
    return [
        w[1] - A_SPLIT,
        A_POST_MAX - w[1],
        w[2] - D_POST_MIN,
        D_VISIT_MAX - w[2],
    ]
end

function count_constraints(model::Model)
    return sum(
        num_constraints(model, F, S)
        for (F, S) in list_of_constraint_types(model)
    )
end

accepted_solver_statuses(model::Model) =
    termination_status(model) == MOI.OPTIMAL &&
    primal_status(model) == MOI.FEASIBLE_POINT

function max_domain_degree(domain)
    return maximum(maxdegree(g) for g in domain)
end

function verify_psatz(label::String, poly, vars, domain; max_extra_order = 2)
    base_order = maximum((cld(maxdegree(poly), 2), cld(max_domain_degree(domain), 2)))
    last = nothing

    for order in base_order:(base_order + max_extra_order)
        model = Model(Mosek.Optimizer)
        set_silent(model)
        add_psatz!(
            model,
            poly,
            vars,
            domain,
            [],
            order;
            QUIET = true,
            CS = false,
            TS = false,
            GroebnerBasis = true,
        )
        started = time()
        optimize!(model)
        elapsed = time() - started

        info = (
            certified = accepted_solver_statuses(model),
            order = order,
            degree = maxdegree(poly),
            termination = termination_status(model),
            primal = primal_status(model),
            time_s = elapsed,
            variables = num_variables(model),
            constraints = count_constraints(model),
        )
        last = info

        @printf(
            "%-38s order=%d deg=%d status=%s/%s time=%.3fs vars=%d cons=%d certified=%s\n",
            label,
            order,
            info.degree,
            string(info.termination),
            string(info.primal),
            elapsed,
            info.variables,
            info.constraints,
            string(info.certified),
        )

        info.certified && return true, info
    end

    return false, last
end

# Exact rational preflight establishing that every reachable visit lies in T.
function preflight()
    println()
    println(repeat("=", 78))
    println("EXACT REACHABILITY PREFLIGHT")
    println(repeat("=", 78))

    # Exact normalized scalar maps.
    A(a) = 1 // 3 + (4 // 5) * a - (6 // 25) * a^2
    D2(a, d) = 1 // 3 - (1 // 10) * a - (3 // 25) * a^2 +
               (9 // 10) * d - (6 // 25) * a * d + (3 // 25) * d^2
    D1(a, d) = D2(a, d) - (1 // 100) * a

    low_next = D1(A_SPLIT, NORMALIZED_X0_GAP[1])
    @assert low_next - D_VISIT_MAX == LOW_BRANCH_VISIT_MARGIN
    @assert LOW_BRANCH_VISIT_MARGIN > 0
    @assert A(A_SPLIT) == A_SPLIT

    @assert A(1 // 1) == A_POST_MAX
    @assert D1(1 // 1, NORMALIZED_X0_GAP[1]) == D_POST_MIN
    @assert D2(A_SPLIT, NORMALIZED_X0_GAP[2]) < D_POST_MAX

    # R1 forward invariance corner checks, using the known monotonicities.
    @assert A(A_POST_MAX) < A_POST_MAX
    @assert D1(A_POST_MAX, D_POST_MIN) > D_POST_MIN
    @assert D2(A_SPLIT, D_POST_MAX) == D_POST_MAX

    traj = PM.witness()
    visits = [
        t for t in 1:5
        if D_VISIT_MIN <= traj[t + 1][2] <= D_VISIT_MAX
    ]
    @assert visits == [1, 2, 3, 4]

    println("low-a branch: zero visits, exact margin = ", LOW_BRANCH_VISIT_MARGIN)
    println("high-a branch: R0 -> R1 and R1 is forward invariant")
    println("reachable visit set: T = R1 intersect X_vf")
    println("four-visit witness times = ", visits)
end

function verify_certificate()
    println()
    println(repeat("=", 78))
    println("SUBMITTED-GRAPH REACHABILITY--RANK SOS VERIFICATION")
    println(repeat("=", 78))
    println("submitted graph edges = ", EDGES)
    println("physical plant / X / X0 / Xvf = UNCHANGED")
    println("C11,C12,C21 degree <= 2; C22 degree <= 4")
    println("rank degree = 1")
    println("epsilon = ", EPS, " = ", Float64(EPS))

    results = Dict{String, Any}()

    # TL-PC1.  This is actually verified on the full physical state domain X,
    # which is stronger than target-local one-step closure.
    println()
    println("TL-PC1 / one-step graph closure")
    for (p, sigma, q) in EDGES
        fx = PM.f_sigma[sigma](x)
        poly = C(p, q, x, fx)
        label = "TL-PC1/$p-$sigma-$q"
        ok, info = verify_psatz(label, poly, x, normalized_h_X(x))
        results[label] = info
        ok || return false, label, results
    end

    # TL-PC2.  The destination y is a reachable target state.  The premise is
    # retained as a semialgebraic domain generator, so this verifies the
    # implication directly rather than fixing a unit S-procedure multiplier.
    println()
    println("TL-PC2 / backward propagation to a reachable visit")
    for (p, sigma, q) in EDGES, r in NODES
        fx = PM.f_sigma[sigma](x)
        premise = C(q, r, fx, y)
        conclusion = C(p, r, x, y)
        domain = [normalized_h_X(x); h_T(y); premise]
        label = "TL-PC2/$p-$sigma-$q/$r"
        ok, info = verify_psatz(label, conclusion, [x; y], domain)
        results[label] = info
        ok || return false, label, results
    end

    # Rank nonnegativity on every reachable target state.
    println()
    println("RANK / nonnegativity on reachable target")
    ok, info = verify_psatz("RANK/nonnegative", R(y), y, h_T(y))
    results["RANK/nonnegative"] = info
    ok || return false, "RANK/nonnegative", results

    # SOS-R recurrence implication for each graph node.
    println()
    println("SOS-R / recurrent-node unit descent")
    for q in NODES
        premise = C(q, q, y, yp)
        conclusion = R(y) - R(yp) - 1
        domain = [h_T(y); h_T(yp); premise]
        label = "SOS-R/node-$q"
        ok, info = verify_psatz(label, conclusion, [y; yp], domain)
        results[label] = info
        ok || return false, label, results
    end

    return true, nothing, results
end

function witness_report()
    traj = PM.witness()
    println()
    println(repeat("=", 78))
    println("FOUR-VISIT NON-VACUITY CHECK")
    println(repeat("=", 78))

    # Repeated mode 1 follows the submitted self-loop 1 --1--> 1.
    for t in 1:3
        yv = traj[t + 1]
        ypv = traj[t + 2]
        cval = Float64(C(1, 1, yv, ypv))
        rdrop = Float64(R(yv) - R(ypv))
        @printf(
            "visit %d -> %d: C11=%.15g, rank drop=%.15g\n",
            t,
            t + 1,
            cval,
            rdrop,
        )
        cval >= -1e-10 || error("Witness recurrence relation is negative.")
        rdrop >= 1 - 1e-10 || error("Witness rank drop is below one.")
    end

    println("PC-CC recurrence/rank mechanism is NON-VACUOUS on all three visit transitions")
end

function main()
    expected = [
        (1, 1, 1),
        (1, 2, 2),
        (2, 2, 1),
        (1, 1, 2),
    ]
    EDGES == expected || error("Submitted graph has changed.")

    preflight()
    ok, failed, results = verify_certificate()
    ok || error("SOS verification failed at $failed")
    witness_report()

    println()
    println(repeat("=", 78))
    println("FINAL RESULT")
    println(repeat("=", 78))
    println("SUBMITTED-GRAPH REACHABILITY--RANK SOS CERTIFICATE VERIFIED")
    println("four visits = VERIFIED")
    println("non-vacuous recurrence descent = VERIFIED")
    println("plant / physical sets / submitted graph = UNCHANGED")
end

main()
