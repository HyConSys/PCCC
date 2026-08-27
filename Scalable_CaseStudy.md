# Dimension-scalable networked-coordination benchmark

**Lead author and repository maintainer:** Reza Iraji  
**Paper coauthors:** Felipe Galarza-Jimenez and Majid Zamani


This example is the recommended replacement for the unsupported degree-6 platoon claim.

## Model

For any state dimension `n >= 2`, let `x=(z,u)`, where `z` is a normalized coordination-progress variable and the components of `u` are disagreement modes of a networked team. Let

```math
\mathcal X=[0,1]\times[-1,1]^{n-1},\qquad
q(u)=\frac{1}{n-1}\sum_{i=2}^n u_i^2.
```

The two polynomial modes are

```math
z^+=z+(1-z)r_\sigma(u),
```

```math
r_1(u)=\frac25+\frac1{10}q(u),\qquad
r_2(u)=\frac3{10}+\frac2{25}q(u),
```

and `u_i^+=3u_i/5` in mode 1, `u_i^+=-7u_i/10` in mode 2. The nonlinear progress coordinate is coupled to all disagreement states through their normalized energy `q(u)`. The two modes model different communication regimes: each contracts the disagreement coordinates at a different rate and changes how disagreement affects task progress.

Use

```math
\mathcal X_0=\{x:0\le z\le1/20\},\qquad
\mathcal X_{\rm vf}=\{x:4/5\le z\le19/20\}.
```

## Four visits under arbitrary switching

Every mode satisfies `r_\sigma>=3/10`, so `z` is monotone. The slow execution uses mode 2, `u=0`, and `z(0)=0`; it visits `\mathcal X_{\rm vf}` at times 5, 6, 7, and 8 and exits at time 9. After any first visit, four transitions force `z>19/20`, so four is the global maximum.

## Explicit relational degree-2 certificate

For the one-node path-complete graph,

```math
C(x,y)=500\left[(y_1-x_1)\left(\frac65-y_1\right)-\frac1{20}(1-x_1)\right].
```

The polynomial has five nonzero monomials and includes `x_1y_1`. Its degree and support are independent of `n`.

PC-CC1 and PC-CC2 follow from direct nonnegative factorizations. PC-CC3 is certified with fixed multipliers

```math
s^{(2)}=1,\qquad s^{(3,a)}=0,\qquad s^{(3,b)}=41/20,
```

and the exact product-domain margin is `475/3904`.

Run the exact check with

```bash
julia ScalableExample/explicit_degree2_certificate.jl 8
```

or use `python -m unittest discover -s tests -v`. An optional TSSOS/MOSEK verification is provided in `sos_verify_degree2.jl`. It uses the exact aggregate abstraction `q(u) in [0,1]`, so the SDP size is independent of the ambient state dimension.
