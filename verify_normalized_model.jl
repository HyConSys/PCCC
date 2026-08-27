# Author: Reza Iraji
# Solver-free equivalence check for the normalized leader-gap platoon model.

include(joinpath(@__DIR__, "platoon_model.jl"))
using .PlatoonModel

function assert_close(a, b; atol = 1e-12)
    isapprox(a, b; atol = atol, rtol = 0.0) || error("mismatch: $a != $b")
end

# Check the affine coordinate transformation, all transformed semialgebraic
# generators, and both mode dynamics.
for physical in ([0.0, 0.0], [1.5, 3.0], [2.4, 6.0], [5.5, 6.0])
    normalized = physical_to_normalized_gap(physical)
    recovered = normalized_gap_to_physical(normalized)
    for index in eachindex(physical)
        assert_close(recovered[index], physical[index])
    end

    physical_domain = h_X(physical)
    normalized_domain = normalized_h_X(normalized)
    length(physical_domain) == length(normalized_domain) || error("domain-generator counts differ")
    for index in eachindex(physical_domain)
        assert_close(normalized_domain[index], physical_domain[index] / 6)
    end

    physical_initial = h_X0(physical)
    normalized_initial = normalized_h_X0(normalized)
    for index in eachindex(physical_initial)
        assert_close(normalized_initial[index], physical_initial[index] / 6)
    end

    physical_finite_visit = h_Xvf(physical)
    normalized_finite_visit = normalized_h_Xvf(normalized)
    for index in eachindex(physical_finite_visit)
        assert_close(normalized_finite_visit[index], physical_finite_visit[index] / 6)
    end

    for mode in (1, 2)
        physical_successor = f_sigma[mode](physical)
        normalized_successor = normalized_f_sigma[mode](normalized)
        recovered_successor = normalized_gap_to_physical(normalized_successor)
        for index in eachindex(physical_successor)
            assert_close(recovered_successor[index], physical_successor[index])
        end
    end
end

# Check the corrected repeated-visit witness in both coordinate systems.
physical_trace = corrected_witness()
normalized_trace = normalized_corrected_witness()
length(physical_trace) == length(normalized_trace) || error("trace lengths differ")
for index in eachindex(physical_trace)
    recovered = normalized_gap_to_physical(normalized_trace[index])
    for state_index in 1:2
        assert_close(recovered[state_index], physical_trace[index][state_index])
    end
end

visit_times = [
    time - 1
    for (time, state) in enumerate(normalized_trace)
    if time > 1 && NORMALIZED_XVF_GAP[1] <= normalized_gap(state) <= NORMALIZED_XVF_GAP[2]
]
visit_times == [1, 2, 3, 4] || error("unexpected visit times: $visit_times")

println("normalized leader-gap model matches the physical platoon dynamics")
println("all normalized domain generators equal the physical generators divided by 6")
println("normalized visit times = ", visit_times)
println("normalized initial set = ", NORMALIZED_X0_GAP)
println("normalized finite-visit set = ", NORMALIZED_XVF_GAP)
