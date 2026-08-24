# Orchestrator Validation — PH1-COD-001

**Date:** 2026-08-23  
**Reviewer:** Pi acting as active orchestrator (Nova role)  
**Disposition:** Review accepted; Ledger scope blocked pending remediation

## Runtime, transport, and independence

A real Codex session carried the independent Ledger reviewer role through Herdr as `ph1_cod_001` in pane `w1B:p6`, session `01a0318a-7f16-7ba3-a138-8064103485e2`. Persisted PH1-SEN-001 evidence and live pre-dispatch state confirmed Codex had not authored or modified the reviewed policy/value-fidelity controls. The review remained read-only and invoked no other agent/runtime.

The initial Codex process self-updated and exited. The buffered assignment prose then reached the shell; bash reported `Execute: command not found` and parsed a trailing capitalized `Hermes` prose clause as another nonexistent command. No Hermes binary/runtime was started, contacted, probed, dispatched, retried, or used as fallback. Codex was restarted and verified interactive before the assignment was safely resent.

## Scope and evidence validation

The returned review supplied the required approve/block verdict, fourteen-invariant checklist, traceability assessment, severity-ranked findings, exact evidence, remediation, G2 boundary, and read-only confirmation.

Independent source checks confirmed:

- `LLM_TRUST_BOUNDARY.md:181-194` states strong value-fidelity invariants, including integer minor units, no rounding/scaling, server-side substitution, snapshot binding, fixed pre-egress values, and Mode A fallback.
- `llm-egress-allowlist.schema.json:229-242` defines only a 64-hex digest shape plus token/kind declarations.
- `llm-egress-allowlist.schema.json:291-305` does not bind a placeholder to an exact canonical engine field/path, raw integer value, currency/minor-unit exponent, formatter, or provenance.
- The reviewed design does not define a digest algorithm, canonical serialization, complete covered object, or an exact integer-only display-format contract.
- Mode A deterministic ownership passed; the identified gaps concern future Mode B token substitution/rehydration.
- Zaifu remained clean; the Codex reviewer changed no financial rule, engine, fixture, policy, schema, or documentation.

## Finding validation

Validated count:

- BLOCKER: 0
- HIGH: 3

The three HIGH findings—token-to-field identity, digest construction, and exact monetary display transformation—are distinct and technically supported. Under the assignment's escalation rule, failed or unprovable fidelity invariants require a BLOCK verdict.

## Verdict

Accept the independent review. PH1-COD-001 status is **Remediation required / Ledger approval blocked**. The block prevents approval of future Mode B substitution design; it does not invalidate Mode A, resolve the 70% ceiling/answer-threshold question, or close G2. Claude-authored remediation followed by independent Codex re-review preserves runtime separation.
