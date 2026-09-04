# Author: Reza Iraji
from __future__ import annotations

import json
import random
import sys
import unittest
from fractions import Fraction as F
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
sys.path.insert(0, str(ROOT / "ScalableExample"))
sys.path.insert(0, str(ROOT / "GraphIndexedExample"))

import platoon_audit as platoon
import scalable_model as scalable
import graph_indexed_model as graph_model


class PlatoonFinalTests(unittest.TestCase):
    def test_four_visit_witness(self) -> None:
        trajectory = platoon.corrected_witness(10)
        visits = [
            t for t, state in enumerate(trajectory)
            if t > 0 and platoon.CORRECTED_XVF[0] <= platoon.gap(state) <= platoon.CORRECTED_XVF[1]
        ]
        self.assertEqual(visits, [1, 2, 3, 4])
        expected = [
            3.2552,
            3.2794996608,
            3.399123884430082,
            3.5359885383919654,
            3.6654133881372535,
        ]
        for actual, target in zip((float(platoon.gap(s)) for s in trajectory[1:6]), expected):
            self.assertAlmostEqual(actual, target, places=12)

    def test_mode_one_is_velocity_difference_worst_case(self) -> None:
        for x2 in (F(1), F(3), F(6)):
            for d in (F(1), F(16, 5), F(18, 5)):
                self.assertLessEqual(platoon.gap_map(x2, d, 1), platoon.gap_map(x2, d, 2))

    def test_forward_invariance_margins(self) -> None:
        margins = platoon.platoon_invariance_margins()
        self.assertEqual(margins["mode1"], F(31, 50))
        self.assertEqual(margins["mode2"], F(17, 25))

    def test_final_ranked_verifier_guardrails(self) -> None:
        text = (ROOT / "ComplexExample" / "verify_target_local_ranked_pccc.jl").read_text(encoding="utf-8")
        self.assertIn("MOI.OPTIMAL", text)
        self.assertIn("MOI.FEASIBLE_POINT", text)
        self.assertIn("STRICT SUBMITTED-GRAPH TARGET-LOCAL RANKED SOS CERTIFICATE VERIFIED", text)
        self.assertIn("(1, 1, 1)", text)
        self.assertIn("(1, 2, 2)", text)
        self.assertIn("(2, 2, 1)", text)
        self.assertIn("(1, 1, 2)", text)
        self.assertNotIn("MOI.SLOW_PROGRESS", text)
        self.assertNotIn("MOI.ALMOST_OPTIMAL", text)


class ScalableOriginalPCCCTests(unittest.TestCase):
    def test_four_visits_multiple_dimensions(self) -> None:
        for dimension in (2, 4, 8, 16):
            trajectory = scalable.slow_trajectory(dimension, 10)
            visits = [
                t for t, state in enumerate(trajectory)
                if t > 0 and scalable.XVF_Z[0] <= state[0] <= scalable.XVF_Z[1]
            ]
            self.assertEqual(visits, [5, 6, 7, 8])

    def test_relational_degree_two_structure(self) -> None:
        x = (F(1, 10), F(0))
        y = (F(9, 10), F(0))
        base = scalable.certificate(x, y)
        self.assertNotEqual(base, scalable.certificate((F(1, 5), F(0)), y))
        dx = F(1, 100)
        dy = F(1, 100)
        mixed = (
            scalable.certificate((x[0] + dx, F(0)), (y[0] + dy, F(0)))
            - scalable.certificate((x[0] + dx, F(0)), y)
            - scalable.certificate(x, (y[0] + dy, F(0)))
            + scalable.certificate(x, y)
        ) / (dx * dy)
        self.assertEqual(mixed, F(500))

    def test_exact_pc_cc3_margin(self) -> None:
        margin, _ = scalable.sos3_exact_minimum()
        self.assertEqual(margin, F(475, 3904))
        self.assertGreater(margin, 0)

    def test_pc_cc3_nonvacuous_on_four_visit_witness(self) -> None:
        trajectory = scalable.slow_trajectory(8, 10)
        x0 = trajectory[0]
        for t in range(5, 8):
            y = trajectory[t]
            yp = trajectory[t + 1]
            self.assertGreaterEqual(scalable.certificate(x0, y), 0)
            self.assertGreaterEqual(scalable.certificate(y, yp), 0)
            self.assertLessEqual(scalable.certificate(x0, yp), scalable.certificate(x0, y) - 1)


class GraphIndexedOriginalPCCCTests(unittest.TestCase):
    def test_submitted_graph_is_path_complete(self) -> None:
        nodes = {1, 2}
        edges = set(graph_model.EDGES)
        alphabet = {sigma for _, sigma, _ in edges}
        seen = {frozenset(nodes)}
        frontier = [frozenset(nodes)]
        while frontier:
            subset = frontier.pop()
            for sigma in alphabet:
                nxt = frozenset(q for p, label, q in edges if p in subset and label == sigma)
                self.assertTrue(nxt)
                if nxt not in seen:
                    seen.add(nxt)
                    frontier.append(nxt)
        self.assertEqual(seen, {frozenset({1, 2})})

    def test_four_distinct_relational_certificates(self) -> None:
        x = (F(1, 10), F(1, 5), F(0))
        y = (F(4, 5), F(9, 10), F(0))
        values = {
            (p, q): graph_model.certificate(p, q, x, y)
            for p in graph_model.NODES for q in graph_model.NODES
        }
        self.assertEqual(len(set(values.values())), 4)

    def test_matched_sparse_one_node_residuals(self) -> None:
        for dimension in (3, 8):
            state1 = (F(1), F(0), *(F(0) for _ in range(dimension - 2)))
            state2 = (F(0), F(1), *(F(0) for _ in range(dimension - 2)))
            self.assertEqual(graph_model.projection_certificate(0, state1, graph_model.step(state1, 2)), F(-315))
            self.assertEqual(graph_model.projection_certificate(1, state2, graph_model.step(state2, 1)), F(-240))
            self.assertEqual(graph_model.average_certificate(state2, graph_model.step(state2, 1)), F(-105, 2))


class RepositoryIntegrityTests(unittest.TestCase):
    def test_manifest_matches_final_package(self) -> None:
        manifest = json.loads((ROOT / "metadata" / "reproducibility_manifest.json").read_text(encoding="utf-8"))
        self.assertEqual(manifest["lead_author"], "Reza Iraji")
        self.assertEqual(manifest["intended_public_repository"], "rezairaji60/PCCC")
        self.assertEqual(manifest["verified_results"]["platoon"]["positive_time_visits"], 4)
        self.assertEqual(manifest["verified_results"]["scalable_original_pccc"]["original_pc_cc3_exact_margin"], "475/3904")

    def test_reviewer_package_has_no_obsolete_search_files(self) -> None:
        obsolete = [
            "ComplexExample/pccc_onenode.jl",
            "ComplexExample/pccc_twonode.jl",
            "ComplexExample/strict_search.jl",
            "ComplexExample/pccc_onenode_results.txt",
            "ComplexExample/pccc_twonode_results.txt",
            "ScalableExample/sos_verify_degree2.jl",
            "REVIEWER_SIMULATION_AUDIT.md",
            "pccc_diagram.pdf",
            "pccc_diagram.png",
        ]
        for relative in obsolete:
            self.assertFalse((ROOT / relative).exists(), relative)
        self.assertFalse((ROOT / "SimpleExample").exists())

    def test_key_documents_do_not_claim_platoon_sos_failure(self) -> None:
        for relative in (
            "README.md",
            "REPRODUCIBILITY.md",
            "SIMULATION_RESULTS.md",
            "ComplexExample/Complex_CaseStudy.md",
            "manuscript/SIMULATION_SECTION_REPLACEMENT.tex",
        ):
            text = (ROOT / relative).read_text(encoding="utf-8").lower()
            self.assertNotIn("no strict corrected-platoon sos certificate", text, relative)
            self.assertNotIn("no corrected-platoon certificate is claimed", text, relative)


if __name__ == "__main__":
    unittest.main()
