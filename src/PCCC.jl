module PCCC

"""
Reviewer-facing reproducibility package for the paper
"Formal Verification of Switched Systems via Path-Complete Closure Certificates".

The executable verification artifacts live in `ComplexExample/`,
`ScalableExample/`, `GraphIndexedExample/`, and `scripts/`.
This minimal module exists so the repository is a valid Julia package
environment and `Pkg.instantiate()` / precompilation complete cleanly.
"""
const REVIEWER_PACKAGE = true

end # module PCCC
