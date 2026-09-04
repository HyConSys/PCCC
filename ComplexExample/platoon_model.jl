# Author: Reza Iraji
module PlatoonModel

export f1, f2, f_sigma, h_X, h_X0, h_Xvf,
       X0_GAP, XVF_GAP, corrected_witness, gap,
       normalized_f1, normalized_f2, normalized_f_sigma,
       normalized_h_X, normalized_h_X0, normalized_h_Xvf,
       NORMALIZED_X0_GAP, NORMALIZED_XVF_GAP,
       normalized_corrected_witness, normalized_gap,
       physical_to_normalized_gap, normalized_gap_to_physical,
       coordinate_model, assert_multiplier_configuration

# Physical coordinates: v = [follower velocity, leader velocity], both in [0,6].
const X0_GAP = (3.6, 3.8)
const XVF_GAP = (3.2, 3.55)

function f1(v)
    return [0.01 * v[2] + 0.9 * v[1] - 0.02 * v[1]^2,
            2.0 + 0.8 * v[2] - 0.04 * v[2]^2]
end

function f2(v)
    return [0.9 * v[1] - 0.02 * v[1]^2,
            2.0 + 0.8 * v[2] - 0.04 * v[2]^2]
end

const f_sigma = (f1, f2)

gap(v) = v[2] - v[1]

h_X(v) = [v[1], 6 - v[1], v[2], 6 - v[2], v[2] - v[1]]
h_X0(v) = [gap(v) - X0_GAP[1], X0_GAP[2] - gap(v)]
h_Xvf(v) = [gap(v) - XVF_GAP[1], XVF_GAP[2] - gap(v)]

function corrected_witness()
    state = [2.4, 6.0]
    states = [copy(state)]
    for _ in 1:8
        state = f1(state)
        push!(states, copy(state))
    end
    return states
end

# Normalized leader-gap coordinates:
#   a = leader velocity / 6,
#   d = (leader velocity - follower velocity) / 6,
# so w = [a,d], 0 <= d <= a <= 1. This affine coordinate change is
# mathematically equivalent to the physical model but substantially improves
# coefficient scaling in the SOS programs.
const NORMALIZED_X0_GAP = (3 // 5, 19 // 30)
const NORMALIZED_XVF_GAP = (8 // 15, 71 // 120)

physical_to_normalized_gap(v) = [v[2] / 6, (v[2] - v[1]) / 6]
normalized_gap_to_physical(w) = [6 * (w[1] - w[2]), 6 * w[1]]
normalized_gap(w) = w[2]

function normalized_f2(w)
    a, d = w
    next_a = 1 // 3 + (4 // 5) * a - (6 // 25) * a^2
    next_d = 1 // 3 - (1 // 10) * a - (3 // 25) * a^2 +
             (9 // 10) * d - (6 // 25) * a * d + (3 // 25) * d^2
    return [next_a, next_d]
end

function normalized_f1(w)
    next = normalized_f2(w)
    return [next[1], next[2] - (1 // 100) * w[1]]
end

const normalized_f_sigma = (normalized_f1, normalized_f2)

# These are the exact affine images of all five physical generators, divided
# only by the positive scale factor 6. Keeping the full transformed generator
# list isolates coordinate scaling without changing the low-order quadratic
# module through removal of a redundant inequality.
normalized_h_X(w) = [
    w[1] - w[2],
    1 - w[1] + w[2],
    w[1],
    1 - w[1],
    w[2],
]
normalized_h_X0(w) = [
    normalized_gap(w) - NORMALIZED_X0_GAP[1],
    NORMALIZED_X0_GAP[2] - normalized_gap(w),
]
normalized_h_Xvf(w) = [
    normalized_gap(w) - NORMALIZED_XVF_GAP[1],
    NORMALIZED_XVF_GAP[2] - normalized_gap(w),
]

function normalized_corrected_witness()
    state = [1.0, 0.6]
    states = [copy(state)]
    for _ in 1:8
        state = normalized_f1(state)
        push!(states, copy(state))
    end
    return states
end

function coordinate_model(name::AbstractString)
    normalized = lowercase(strip(name))
    if normalized in ("physical", "physical_velocity", "velocity")
        return (
            slug = "physical",
            description = "physical follower-leader velocities in [0,6]",
            f_sigma = f_sigma,
            h_X = h_X,
            h_X0 = h_X0,
            h_Xvf = h_Xvf,
            x0_gap = X0_GAP,
            xvf_gap = XVF_GAP,
            gap = gap,
            witness = corrected_witness,
            max_leader = 6.0,
            state_from_leader_gap = (leader, current_gap) -> [leader - current_gap, leader],
        )
    elseif normalized in ("normalized_gap", "normalized", "leader_gap")
        return (
            slug = "normalized_gap",
            description = "normalized leader-gap coordinates with transformed physical generators",
            f_sigma = normalized_f_sigma,
            h_X = normalized_h_X,
            h_X0 = normalized_h_X0,
            h_Xvf = normalized_h_Xvf,
            x0_gap = (Float64(NORMALIZED_X0_GAP[1]), Float64(NORMALIZED_X0_GAP[2])),
            xvf_gap = (Float64(NORMALIZED_XVF_GAP[1]), Float64(NORMALIZED_XVF_GAP[2])),
            gap = normalized_gap,
            witness = normalized_corrected_witness,
            max_leader = 1.0,
            state_from_leader_gap = (leader, current_gap) -> [leader, current_gap],
        )
    end
    error(
        "Unknown PCCC_COORDINATES=$(repr(name)). Use physical or normalized_gap."
    )
end

function assert_multiplier_configuration(tau_3a::Real, tau_3b::Real)
    if isapprox(tau_3a, 1.0; atol = 1e-12, rtol = 0.0) && tau_3b >= 0
        error("tau_3a = 1 cancels C_pq in SOS-3 and cannot certify genuine repeated visits with a nonnegative tau_3b. Use tau_3a != 1 or an alternating multiplier scheme.")
    end
    tau_3a < 0 && error("SOS premise multipliers must be nonnegative.")
    tau_3b < 0 && error("SOS premise multipliers must be nonnegative.")
    return nothing
end

end
