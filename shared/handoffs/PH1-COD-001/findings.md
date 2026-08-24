# PH1-COD-001 Findings Summary

**Date:** 2026-08-23  
**Validated disposition:** BLOCK; three HIGH value-fidelity findings; no BLOCKER.

## HIGH

1. **Token-to-engine-field identity is not normatively bound:** placeholders declare only token and broad kind, allowing a conforming implementation to substitute the wrong authoritative field. Define a typed internal substitution map bound to exact snapshot identity, canonical field/path, raw type/value, currency/scale, formatter, and provenance.
2. **Digest construction is underspecified:** the schema requires only a 64-character hexadecimal shape. Define algorithm, version/domain prefix, canonical serialization, covered fields—including the complete token map—and cross-implementation mutation fixtures.
3. **Exact monetary display transformation is unspecified:** integer-minor-unit authority is stated, but currency scale, sign/zero-padding, locale behavior, and float prohibition are not operationally defined. Add an integer-only formatter contract and boundary fixtures.

## Scope effects

- Mode A's deterministic engine ownership passed review.
- The BLOCK applies to the Ledger value-fidelity scope and prevents approval of future Mode B token substitution until remediation and re-review.
- The review does not resolve the 70% ceiling/answer-threshold issue and does not close G2.

Full evidence: `result.md`. Independent validation: `validation.md`.
