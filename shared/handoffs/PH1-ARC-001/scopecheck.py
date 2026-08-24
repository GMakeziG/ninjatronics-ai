#!/usr/bin/env python3
"""Verify the D-05 scope statement is present and identically worded in the five
documents named by PH1-WP-02 acceptance criterion 2."""
import io, re, sys
PAT = re.compile(
    r"maximum reachable \*{0,2}account trust level in Phase 1 is \*{0,2}Level 2, "
    r"User Confirmed \(70%\)")
FILES = ["docs/planning/DECISION_LOG.md",          # ADR-010 supersession note
         "docs/product/PRODUCT_CHARTER.md",
         "docs/planning/PRODUCT_REQUIREMENTS.md",
         "docs/planning/MVP_REFINED.md",
         "docs/product/TRUST_MODEL.md"]
ok = True
for f in FILES:
    s = io.open(f, encoding="utf-8").read()
    s = re.sub(r"^\s*>\s?", " ", s, flags=re.M)   # flatten blockquotes
    s = re.sub(r"\s+", " ", s)
    n = len(PAT.findall(s))
    print(f"{n} occurrence(s)  {f}")
    ok = ok and n >= 1
print("RESULT:", "PASS - identical statement present in all five" if ok else "FAIL")
sys.exit(0 if ok else 1)
