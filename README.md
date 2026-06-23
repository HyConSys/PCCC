# Path-Complete Closure Certificates (PC-CCs)

Simulation code and examples for Path-Complete Closure Certificates (PC-CCs) applied to nonlinear switched systems.

![PC-CC Diagram](pccc_diagram.pdf)

This repository currently includes:

* **Code of Simple Example**: one-node and two-node graph.
  * *See [Simple_Case_Study.md](SimpleExample/Simple_CaseStudy.md) for a detailed explanation of the scenario where the system escapes the target set after a single step (Vacuous PC-CC3), successfully certified at Degree 2.*
  * Scripts: `SimpleExample/S_pccc_onenode.jl` & `SimpleExample/S_pccc_twonode.jl`
* **Code of Complex Example**: one-node and two-node graph.
  * *See [Complex_Case_Study.md](ComplexExample/Complex_CaseStudy.md) for a detailed explanation of the scenario where the system remains inside the target set for up to 4 consecutive time steps (Non-Vacuous PC-CC3), successfully certified at Degree 6.*
  * Scripts: `ComplexExample/pccc_onenode.jl` & `ComplexExample/pccc_twonode.jl`
