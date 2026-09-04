# Author: Reza Iraji
# Exact, solver-free verification of the two-node graph-indexed degree-2 PC-CC.

const Q = Rational{BigInt}
const edges = ((1, 1, 1), (1, 1, 2), (1, 2, 2), (2, 2, 1))
const ALPHA_SPLIT = 16 // 25

function parse_dimension()
    n = isempty(ARGS) ? 8 : parse(Int, ARGS[1])
    n >= 3 || error("state dimension must be at least 3")
    return n
end

qvalue(x) = sum(v^2 for v in x[3:end]) / (length(x) - 2)

function rate(x, mode)
    q = qvalue(x)
    mode == 1 && return 2 // 5 + q * (1 // 10)
    mode == 2 && return 3 // 10 + q * (2 // 25)
    error("mode must be 1 or 2")
end

progress(z, r) = z + (1 - z) * r

function step(x, mode)
    r = rate(x, mode)
    if mode == 1
        p = progress(x[1], r)
        return [p; p; (3 // 5) .* x[3:end]]
    elseif mode == 2
        return [progress(x[2], r); progress(x[1], r); (-7 // 10) .* x[3:end]]
    end
    error("mode must be 1 or 2")
end

C0(a, b) = 500 * ((b - a) * (6 // 5 - b) - (1 // 20) * (1 - a))
C(p, q, x, y) = C0(x[p], y[q])

function sos3_expression(x0, y, yp)
    return C0(x0, y) - C0(x0, yp) - 1 - (41 // 20) * C0(y, yp)
end

function exact_sos3_minimum()
    x0bounds = (0 // 1, 1 // 20)
    ybounds = (4 // 5, 19 // 20)
    candidates = Tuple{Q, NTuple{3, Q}}[]
    for x0 in x0bounds, y in ybounds
        stationary = (100x0 + 205y + 366) / 610
        ypvalues = Q[ybounds[1], ybounds[2]]
        if ybounds[1] <= stationary <= ybounds[2]
            push!(ypvalues, stationary)
        end
        for yp in ypvalues
            push!(candidates, (sos3_expression(x0, y, yp), (x0, y, yp)))
        end
    end
    return reduce((a, b) -> first(a) <= first(b) ? a : b, candidates)
end

# Full matched convex-projection family from the submitted manuscript.
rA(alpha) = 15 * (25 * alpha - 16)
rB(alpha) = -5 * (119 * alpha^2 - 41 * alpha - 15)
rBprime(alpha) = 205 - 1190 * alpha

function verify_full_convex_projection_family()
    @assert rA(0 // 1) == -240
    @assert rA(ALPHA_SPLIT) == 0
    @assert rB(ALPHA_SPLIT) == -4689 // 125
    @assert rBprime(ALPHA_SPLIT) < 0
    @assert rBprime(1 // 1) < 0

    println("full matched convex-projection one-node family:")
    println("  r_A(alpha) = 15(25alpha-16) < 0 for alpha < 16/25")
    println("  r_B(alpha) = -5(119alpha^2-41alpha-15)")
    println("  r_B'(alpha) = 205-1190alpha < 0 on [16/25,1]")
    println("  r_B(16/25) = ", rB(ALPHA_SPLIT), " < 0")
    println("  therefore every alpha in [0,1] violates PC-CC1")
end

function main()
    n = parse_dimension()
    x = Q[0 for _ in 1:n]

    probe = Q[1 // 5, 2 // 5, [1 // 3 for _ in 3:n]...]
    for (p, mode, q) in edges
        successor = step(probe, mode)
        @assert successor[q] == progress(probe[p], rate(probe, mode))
    end

    trajectory = [copy(x)]
    for _ in 1:10
        x = step(x, 2)
        push!(trajectory, copy(x))
    end
    visits = [t - 1 for (t, state) in enumerate(trajectory)
              if t > 1 && all(4 // 5 <= state[index] <= 19 // 20 for index in 1:2)]
    @assert visits == [5, 6, 7, 8]

    println("C_11(x,y)=C0(x1,y1)")
    println("C_12(x,y)=C0(x1,y2)")
    println("C_21(x,y)=C0(x2,y1)")
    println("C_22(x,y)=C0(x2,y2)")

    # Special cases of the full convex-projection comparison.
    witness1 = Q[1, 0, [0 for _ in 3:n]...]
    witness2 = Q[0, 1, [0 for _ in 3:n]...]
    @assert C0(witness1[1], step(witness1, 2)[1]) == -315
    @assert C0(witness2[2], step(witness2, 1)[2]) == -240
    xa = (witness2[1] + witness2[2]) / 2
    successor2 = step(witness2, 1)
    ya = (successor2[1] + successor2[2]) / 2
    @assert C0(xa, ya) == -105 // 2

    margin, minimizer = exact_sos3_minimum()
    @assert margin == 475 // 3904
    @assert minimizer == (0 // 1, 19 // 20, 2243 // 2440)
    @assert margin > 0

    println("dimension = ", n)
    println("finite-visit times = ", visits)
    println("degree = 2 for every C_pq")
    println("fixed multipliers: s2=1, s3a=0, s3b=41/20")
    println("exact common PC-CC3 margin = ", margin, " at ", minimizer)
    println("matched one-node special cases = -315, -240, -105/2")
    verify_full_convex_projection_family()
end

main()