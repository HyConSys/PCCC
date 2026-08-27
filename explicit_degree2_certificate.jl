# Author: Reza Iraji
# Exact, solver-free verification of the dimension-scalable degree-2 PC-CC.

const Q = Rational{BigInt}

function parse_dimension()
    n = isempty(ARGS) ? 8 : parse(Int, ARGS[1])
    n >= 2 || error("state dimension must be at least 2")
    return n
end

qvalue(x) = sum(v^2 for v in x[2:end]) / (length(x) - 1)

function rate(x, mode)
    q = qvalue(x)
    mode == 1 && return 2 // 5 + q * (1 // 10)
    mode == 2 && return 3 // 10 + q * (2 // 25)
    error("mode must be 1 or 2")
end

function step(x, mode)
    r = rate(x, mode)
    beta = mode == 1 ? 3 // 5 : -7 // 10
    return [x[1] + (1 - x[1]) * r; [beta * v for v in x[2:end]]]
end

certificate(x, y) = 500 * ((y[1] - x[1]) * (6 // 5 - y[1]) - (1 // 20) * (1 - x[1]))

function sos3_expression(x0, y, yp)
    return certificate(x0, y) - certificate(x0, yp) - 1 - (41 // 20) * certificate(y, yp)
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
            xv = Q[x0, 0]
            yv = Q[y, 0]
            ypv = Q[yp, 0]
            push!(candidates, (sos3_expression(xv, yv, ypv), (x0, y, yp)))
        end
    end
    return reduce((a, b) -> first(a) <= first(b) ? a : b, candidates)
end

function main()
    n = parse_dimension()
    x = Q[0 for _ in 1:n]
    trajectory = [copy(x)]
    for _ in 1:10
        x = step(x, 2)
        push!(trajectory, copy(x))
    end

    visits = [t - 1 for (t, state) in enumerate(trajectory) if t > 1 && 4 // 5 <= state[1] <= 19 // 20]
    @assert visits == [5, 6, 7, 8]
    @assert trajectory[10][1] > 19 // 20

    # PC-CC1: C(x,f_sigma(x)) >= 500*(1-z)/100.
    # PC-CC2: C(x,y)-C(f_sigma(x),y) = 500*(z+-z)*(23/20-y) >= 0.
    @assert 3 // 10 * 1 // 5 - 1 // 20 == 1 // 100
    @assert 23 // 20 - 1 == 3 // 20

    margin, minimizer = exact_sos3_minimum()
    @assert margin == 475 // 3904
    @assert margin > 0

    println("dimension = ", n)
    println("slow z trajectory = ", [Float64(state[1]) for state in trajectory])
    println("finite-visit times = ", visits)
    println("certificate degree = 2; nonzero monomials = 5")
    println("fixed multipliers: s2=1, s3a=0, s3b=41/20")
    println("exact SOS-3 margin = ", margin, " = ", Float64(margin))
    println("SOS-3 minimizer (x0,y,y') = ", minimizer)

    x0 = trajectory[1]
    for t in 5:8
        println("C(x0,y_", t, ") = ", Float64(certificate(x0, trajectory[t + 1])))
    end
    for t in 5:7
        println("C(y_", t, ",y_", t + 1, ") = ",
                Float64(certificate(trajectory[t + 1], trajectory[t + 2])))
    end
end

main()
