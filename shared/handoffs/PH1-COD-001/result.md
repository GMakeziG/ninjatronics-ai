## PH1-COD-001 Ledger review

  ### 1. Verdict

  BLOCK

  Mode A’s deterministic boundary is correctly stated and preserves engine
  ownership. However, the future Mode B substitution design is not specified
  tightly enough to prove exact token-to-value fidelity. A digest binds a
  response to an engine snapshot, but the policy/schema do not normatively
  define or bind the internal token-to-engine-field mapping, canonical digest
  input, monetary type metadata, or exact display transformation.

  Consequently, an implementation could substitute the wrong authoritative field
  —or format integer minor units incorrectly—while satisfying the documented
  snapshot-digest and response-validation requirements. Under the assignment’s
  escalation rule, these failed/insufficiently evidenced value-fidelity
  invariants require BLOCK.

  ### 2. Runtime identity and independence

  Runtime: Codex carrying the independent Ledger reviewer role.

  I did not author, implement, modify, or integrate PH1-SEN-001. The reviewed
  commit identifies Claude Code carrying the Sentinel policy-author role, while
  the central tranche evidence records Codex as eligible and uninvolved in the
  reviewed financial/value controls:

  - /home/gerso/Development/ninjatronics-ai/shared/handoffs/PH1-CLD-001/tranche-
    1-results.md:93-98

  - /home/gerso/Development/ninjatronics-ai/shared/handoffs/PH1-SEN-001/
    result.md:514-517

  - /home/gerso/Development/ninjatronics-ai/shared/handoffs/PH1-SEN-001/
    result.md:1028-1030

  No other agent or runtime was invoked. Hermes was not used or attempted.

  ### 3. Value-fidelity invariant checklist

   Invariant                  Outcome                  Exact evidence and
                                                       assessment
  ━━━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━  ━━━━━━━━━━━━━━━━━━━━━━━━━━
   VF-1 — provider never      PASS                     Mode A makes
   calculates                                          deterministic engines
                                                       the sole source of
                                                       values, verdicts,
                                                       labels, and citations:
                                                       docs/security/
                                                       LLM_TRUST_BOUNDARY.md:10
                                                       8-110. The provider
                                                       abstraction produces
                                                       none of these: :398-402.
                                                       Schema repeats the
                                                       boundary at docs/
                                                       security/llm-egress-
                                                       allowlist.schema.json:10
                                                       6. This agrees with the
                                                       engine’s one-directional
                                                       deterministic ownership
                                                       in docs/architecture/
                                                       FINANCIAL_ENGINE.md:20-
                                                       31,327-331.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-2 — integer minor       FAIL                     The requirement is
   units, never float                                  explicit at
                                                       LLM_TRUST_BOUNDARY.md:18
                                                       2; the engine represents
                                                       monetary outputs as
                                                       integer cents, e.g.
                                                       FINANCIAL_ENGINE.md:53,8
                                                       4,116-119,187-197,341-
                                                       365. But the future
                                                       substitution design
                                                       defines only token and
                                                       broad kind, with no
                                                       internal typed mapping
                                                       contract, currency,
                                                       minor-unit exponent, or
                                                       serialization
                                                       representation:
                                                       schema :237-242,291-304.
                                                       Exact integer
                                                       preservation through
                                                       rehydration is therefore
                                                       asserted but not
                                                       specified/testable.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-3 — no rounding/        FAIL                     Prohibition appears at
   scaling/unit conversion                             LLM_TRUST_BOUNDARY.md:18
                                                       3, but the sole
                                                       implementation direction
                                                       is an undefined “one-way
                                                       presentation transform.”
                                                       No exact formatter,
                                                       scale/currency metadata,
                                                       or integer-to-display
                                                       rule is specified. The
                                                       authoritative engine
                                                       itself contains
                                                       explicitly defined
                                                       integer-division/
                                                       rounding cases
                                                       (FINANCIAL_ENGINE.md:303
                                                       -306,487-488,601-602),
                                                       demonstrating why
                                                       transformation rules
                                                       cannot safely be
                                                       implicit.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-4 — no inference or     PASS                     Exact engine output or
   prose restatement                                   omission is required at
                                                       LLM_TRUST_BOUNDARY.md:18
                                                       4; numeric model output
                                                       is rejected at :186 and
                                                       schema :110,278-280.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-5 — one-way server      FAIL                     The direction is stated
   substitution                                        at
                                                       LLM_TRUST_BOUNDARY.md:18
                                                       5 and schema :108, but
                                                       no normative
                                                       token→specific snapshot-
                                                       field mapping is
                                                       defined. A token
                                                       declares only token and
                                                       kind (schema:237-
                                                       242,299-304). Thus
                                                       {{M1}} can be mapped to
                                                       the wrong money field
                                                       while remaining one-way
                                                       and authoritative in
                                                       type.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-6 — reject model        PASS                     Policy
   numeric literals                                    LLM_TRUST_BOUNDARY.md:18
                                                       6; response contract
                                                       schema:278-280;
                                                       tokenized outbound
                                                       grammar schema:320-325;
                                                       negative cases
                                                       LLM_TRUST_BOUNDARY.md:61
                                                       9-623.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-7 — reject              PASS, broker-enforced    Policy
   undeclared tokens                                   LLM_TRUST_BOUNDARY.md:18
                                                       7; schema annotation
                                                       llm-egress-
                                                       allowlist.schema.json:11
                                                       1; negative test
                                                       LLM_TRUST_BOUNDARY.md:62
                                                       3. This relationship is
                                                       not expressible by the
                                                       current JSON Schema
                                                       alone, but it is
                                                       explicitly assigned to
                                                       response validation.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-8 — required tokens     PASS, broker-enforced    Policy
   must appear                                         LLM_TRUST_BOUNDARY.md:18
                                                       8; schema :112,265-270;
                                                       negative test
                                                       LLM_TRUST_BOUNDARY.md:62
                                                       3.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-9 — bind                FAIL                     Snapshot checking is
   substitution to                                     required at
   snapshot                                            LLM_TRUST_BOUNDARY.md:18
                                                       9 and schema :229-232.
                                                       However, only a 64-
                                                       character digest shape
                                                       is defined. There is no
                                                       canonical snapshot
                                                       serialization, digest
                                                       algorithm, included-
                                                       field definition, or
                                                       binding of the token map
                                                       itself. Snapshot
                                                       equality therefore does
                                                       not establish token-to-
                                                       field equality.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-10 — prohibit           PASS                     Policy
   partial substitution                                LLM_TRUST_BOUNDARY.md:19
                                                       0; full-discard behavior
                                                       in schema :116; negative
                                                       test
                                                       LLM_TRUST_BOUNDARY.md:62
                                                       9.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-11 — substitution       FAIL                     Requirement appears at
   set fixed before egress                             LLM_TRUST_BOUNDARY.md:19
                                                       1, but neither policy
                                                       nor schema defines the
                                                       internal substitution-
                                                       table structure or
                                                       requires its exact
                                                       contents to be covered
                                                       by the digest. The
                                                       invariant cannot be
                                                       independently verified
                                                       from the design.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-12 — confidence         PASS                     Numeric confidence/trust
   label only                                          values are denied at
                                                       LLM_TRUST_BOUNDARY.md:19
                                                       2,279; schema permits
                                                       only HIGH/MEDIUM/LOW
                                                       at :212-214. Canonical
                                                       bands remain external at
                                                       docs/product/
                                                       TRUST_MODEL.md:311-320.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-13 — citations          PASS                     Mode A citations resolve
   attached server-side                                to actual records/
                                                       outputs at
                                                       LLM_TRUST_BOUNDARY.md:13
                                                       3-135; model generation/
                                                       reformatting is
                                                       prohibited at :193. This
                                                       traces to the engine’s
                                                       requirement that
                                                       recommendations be
                                                       traceable at
                                                       FINANCIAL_ENGINE.md:327-
                                                       331.
  ─────────────────────────  ───────────────────────  ──────────────────────────
   VF-14 — unverifiable       PASS as policy           Required at
   fidelity falls back to                              LLM_TRUST_BOUNDARY.md:19
   Mode A                                              4; degradation includes
                                                       response/substitution
                                                       failure at :149-156;
                                                       schema mandates full
                                                       discard and Mode A
                                                       at :116. This does not
                                                       cure the design gaps
                                                       above because an
                                                       incorrectly constructed
                                                       token map may appear
                                                       verifiable.

  ### 4. Source-to-policy/schema traceability

  Traceability is generally accurate:

  - Integer-minor-unit authority correctly traces from ADR-007 and the engine’s
    integer *_cents outputs to VF-2/VF-3: LLM_TRUST_BOUNDARY.md:696;
    FINANCIAL_ENGINE.md:53,84,116-119,187-197,341-365.

  - Engine ownership and traceability correctly flow from
    FINANCIAL_ENGINE.md:327-331 to MA-4/MA-9 and VF-1/VF-13.

  - The schema correctly mirrors the authoritative verdict and risk enums:
      - Engine: FINANCIAL_ENGINE.md:361-366,382-399
      - Schema: llm-egress-allowlist.schema.json:204-219

  - primary_risk values match the engine algorithm at FINANCIAL_ENGINE.md:394-
    399.

  - Confidence-label ownership remains in TRUST_MODEL.md:311-320; the schema
    mirrors only its label enum at llm-egress-allowlist.schema.json:212-214.

  - The six mandatory explanation components trace correctly from
    EXPLAINABILITY.md:148-165 to MA-6 at LLM_TRUST_BOUNDARY.md:119-121.

  - The policy correctly identifies the tranche illustration’s SAFER_TO_WAIT
    conflict and chooses the authoritative engine enum without inventing a rule:
    LLM_TRUST_BOUNDARY.md:731-738.

  Traceability is incomplete at the crucial rehydration seam: no authoritative
  source or policy control defines how a placeholder is associated with one
  exact engine-output field, how that association is serialized and digested, or
  how integer minor units become exact display text. The traceability matrix’s
  assertion at LLM_TRUST_BOUNDARY.md:710 therefore overstates what VF-1 through
  VF-14 currently demonstrate.

  ### 5. Findings

  #### HIGH — F-1: Token-to-engine-field identity is not normatively bound

  Evidence:

  - LLM_TRUST_BOUNDARY.md:185,189,191
  - llm-egress-allowlist.schema.json:108,229-242,291-304

  Impact: A conforming broker could bind {{M1}} to the wrong monetary field from
  the correct engine snapshot. The digest could still match, the token would be
  declared with kind money, all tokens could resolve, and the response could
  pass validation. The user would receive an authoritative but semantically
  incorrect value.

  Required remediation: Before Mode B implementation/approval, define a server-
  internal typed substitution-map contract binding each unique token to:

  - Exact engine snapshot identity and canonical field/path
  - Raw value type
  - Exact integer-minor-unit value for money
  - Currency and minor-unit exponent where applicable
  - Date/reference type as applicable
  - Approved display formatter
  - Provenance/citation reference where relevant

  Bind the complete mapping—not merely an unspecified snapshot—to the integrity
  digest and require exact token-key uniqueness.

  #### HIGH — F-2: Digest construction and verification are underspecified

  Evidence:

  - LLM_TRUST_BOUNDARY.md:189,254,354-355
  - llm-egress-allowlist.schema.json:229-232

  Impact: A 64-hex-character shape proves neither which algorithm was used nor
  which fields/order/encoding were covered. Different serializers or omitted
  fields can produce an apparently valid implementation that does not reliably
  detect swapped or stale mappings.

  Required remediation: Define the digest algorithm, domain/version prefix,
  canonical serialization, complete covered object—including token mapping—and
  byte encoding. Add cross-implementation fixtures proving identical digests and
  rejection after any mapped field, type, currency, scale, token, or source path
  changes.

  #### HIGH — F-3: Exact monetary display transformation is not specified

  Evidence:

  - Fidelity prohibition and undefined presentation exception:
    LLM_TRUST_BOUNDARY.md:182-183

  - Engine integer-money authority: FINANCIAL_ENGINE.md:53,84,116-119,187-
    197,341-365

  - Placeholder declarations carry only kind: llm-egress-
    allowlist.schema.json:237-242,299-304

  Impact: Implementations can interpret an integer minor-unit value
  inconsistently, use floating point, apply an incorrect scale, drop trailing
  minor units, or apply unintended rounding while claiming a server-side display
  transformation.

  Required remediation: Define an integer-only formatting contract, including
  currency/minor-unit metadata, sign handling, zero-padding, locale behavior,
  and prohibited float conversion. Add boundary fixtures for zero, negative
  values, large integers, one-minor-unit values, currencies with differing
  minor-unit exponents if supported, and exact engine-output/display pairs.

  ### 6. G2 boundary

  This review does not resolve the Phase 1 70% trust-ceiling versus answer-
  threshold issue, does not change confidence bands or financial rules, and does
  not close G2.

  That issue remains explicitly unsettled at docs/product/TRUST_MODEL.md:18-
  24,204-220,338 and assigned to PH1-WP-03/G2 at docs/security/
  LLM_TRUST_BOUNDARY.md:749-750,767.

  ### 7. Commands/checks and read-only confirmation

  Performed only targeted, read-only checks:

  - Read the PH1-COD-001 assignment first with sed.
  - Captured git status --short in both repositories before review.
  - Located authorized artifacts using rg --files.
  - Read/search-compared the policy, schema, financial engine, explainability
    standard, trust model, local handoff, central PH1-SEN-001 evidence, and PH1-
    CLD-001 tranche evidence using sed and rg -n.

  - Verified integrated commit 0cc5741 and its six-file boundary with git show.
  - Ran final git status --short, git diff --check, git diff --stat, and git
    diff --cached --stat in both repositories.

  No file was created, modified, deleted, staged, committed, or formatted.

  Final status matched baseline:

  - /home/gerso/Development/zaifu: clean.
  - /home/gerso/Development/ninjatronics-ai: unchanged pre-existing untracked
    directories:
      - shared/handoffs/PH1-COD-001/
      - shared/handoffs/PH1-SEN-002/

  Recommended next owner: active orchestrator for independent validation,
  persistence, and remediation routing.

