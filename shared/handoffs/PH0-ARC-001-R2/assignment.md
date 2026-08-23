# Assignment: PH0-ARC-001

## Assignment: PH0-ARC-001

**Title:** Product Charter, User Journeys, and Acceptance Criteria

**Assigned to:** Archivist

**Phase:** 0

**Assigned by:** Nova

**Effort estimate:** 3-4 hours

---

## Objective

Write the product charter, user journeys, functional/nonfunctional requirements, acceptance criteria, and glossary for Zaifu's MVP. These documents complete the Phase 0 gate criteria for the Archivist domain.

## Scope

### Must include:

1. **Product Charter** (docs/product/PRODUCT_CHARTER.md)
   - Problem statement (people can't make confident financial decisions)
   - Target users (individuals who want decision support, not just data)
   - Product principles (from PHILOSOPHY.md — 8 immutable principles)
   - Scope: what Zaifu IS (Decision Operating System for Personal Finance)
   - Scope: what Zaifu IS NOT (budgeting app, money tracker, investment advisor)
   - Non-goals (bank aggregation, multi-user household, investments, taxes for MVP)
   - Success metrics (user completes setup in 5 min, feels understood, makes confident decision)

2. **User Journeys** (docs/planning/USER_JOURNEYS.md)
   - Onboarding journey (new user → adds checking + paycheck + rent → asks first question)
   - "Can I afford this?" journey (the core MVP flow)
   - "Enter a bill" journey
   - "Review forecast" journey
   - Edge cases: incomplete data, conflicting sources, user corrections

3. **Functional Requirements** (docs/planning/PRODUCT_REQUIREMENTS.md)
   - Every MVP feature has acceptance criteria
   - User stories for each feature
   - Koban behaviors specified (what it can/cannot do)
   - Notification requirements

4. **Glossary** (docs/product/GLOSSARY.md)
   - All financial terms defined (checking, paycheck, rent, obligation, APR, minimum payment)
   - All product-specific terms defined (Ledger, Oracle, Strategist, Steward, Koban, trust level, confidence)
   - No ambiguity

5. **Success Metrics** (docs/product/SUCCESS_METRICS.md)
   - How we measure product success (user confidence, retention, recommendation accuracy)
   - How we measure financial calculation accuracy
   - How we measure user adoption
   - How we measure Koban quality

### Should include:
- Cross-references between journeys and requirements
- Edge case documentation for each journey

### Must NOT include:
- Technical architecture (that's the architecture docs)
- Security model (that's Sentinel's domain)
- Financial calculation rules (that's Ledger's domain)
- Any code implementation

## Context

### Relevant source documents:
- docs/product/VISION.md — the definitive narrative
- docs/product/PHILOSOPHY.md — 8 immutable principles
- docs/product/FINANCIAL_CONFIDENCE.md — confidence, not certainty
- docs/product/TRUST_MODEL.md — how trust works
- docs/product/EXPLAINABILITY.md — every recommendation has 5 components
- docs/planning/MVP_REFINED.md — the simplified MVP (checking + income + obligations)
- docs/planning/MVP_PROOF_POINT.md — the $500 purchase question
- docs/planning/USER_STORY_BEST_BUY.md — the complete end-to-end narrative
- docs/planning/PHASE_0_GATE.md — exit criteria checklist
- docs/planning/DECISION_LOG.md — 21 ADRs
- docs/planning/ASSUMPTIONS.md — all assumptions
- docs/planning/OPEN_QUESTIONS.md — research topics
- docs/orchestration/AGENT_ROSTER.md — team structure

### Background:
Phase 0 has completed the vision, philosophy, architecture, and decisions. The MVP is defined: a user adds checking + paycheck + rent, asks "Can I afford a $500 purchase?", and gets reasoning with confidence. Now we need the product charter, user journeys, requirements, and glossary to complete the Phase 0 gate.

## Ownership and Constraints

### You may read:
- All files under docs/
- All files under shared/

### You may write/create:
- docs/product/PRODUCT_CHARTER.md
- docs/product/GLOSSARY.md
- docs/product/SUCCESS_METRICS.md
- docs/planning/USER_JOURNEYS.md
- docs/planning/PRODUCT_REQUIREMENTS.md

### You must not:
- Modify any existing planning or product documents
- Create architecture, security, or financial calculation documents
- Write any code

## Acceptance Criteria

- [ ] Product charter defines problem, users, principles, scope, non-goals, success metrics
- [ ] User journeys cover onboarding, affordability question, bill entry, forecast review, and edge cases
- [ ] Every MVP feature has acceptance criteria in PRODUCT_REQUIREMENTS.md
- [ ] Glossary defines all financial and product terms with no ambiguity
- [ ] Success metrics cover product, calculation accuracy, adoption, and Koban quality
- [ ] Koban scope is defined (what it can/cannot do, escalation behavior)
- [ ] All documents cross-reference VISION.md and PHILOSOPHY.md
- [ ] Handoff document completed

## Deliverables

1. **Primary outputs:**
   - docs/product/PRODUCT_CHARTER.md
   - docs/product/GLOSSARY.md
   - docs/product/SUCCESS_METRICS.md
   - docs/planning/USER_JOURNEYS.md
   - docs/planning/PRODUCT_REQUIREMENTS.md

2. **Handoff document:**
   - Format: per shared/templates/HANDOFF_TEMPLATE.md (or specialist-handoff.md)
   - Include: work performed, files created, acceptance criteria status, assumptions, risks

---

## Output Protocol

State your Hermes profile name. Then emit your final specialist handoff EXACTLY ONCE between these markers:

<<<NINJATRONICS-RESULT-BEGIN:PH0-ARC-001>>>
[your complete handoff here]
<<<NINJATRONICS-RESULT-END:PH0-ARC-001>>>

Emit each marker line only once. Put NOTHING after the end-marker line. You are authorized to create the documents listed above in the zaifu repo. Report what you created in the handoff between the markers.
