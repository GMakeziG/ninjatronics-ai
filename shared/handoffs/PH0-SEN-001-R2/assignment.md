# Assignment: PH0-SEN-001

## Assignment: PH0-SEN-001

**Title:** Security Architecture, Threat Model, and Data Classification

**Assigned to:** Sentinel

**Phase:** 0

**Assigned by:** Nova

**Effort estimate:** 3-4 hours

---

## Objective

Write the security architecture, threat model, and data classification for Zaifu's MVP. These documents complete the Phase 0 gate criteria for the Sentinel domain.

## Scope

### Must include:

1. **Security Architecture** (docs/security/SECURITY_ARCHITECTURE.md)
   - What data we are protecting (PII, financial data, metadata, authentication data)
   - Who we are protecting against (external attackers, insider threats, aggregation/inferral attacks)
   - Threat assumptions for MVP (what attacks are in scope)
   - Encryption requirements:
     - In transit (TLS 1.2+, HSTS)
     - At rest (database encryption, backup encryption, file-level for sensitive fields)
   - Authentication requirements (OWASP-compliant, session management)
   - Authorization model (single-user MVP, role-based design for Phase 2+)
   - Audit logging (what events, what detail, retention, user export)

2. **Threat Model** (docs/security/THREAT_MODEL.md)
   - Attack surfaces (API endpoints, authentication, data import, Koban LLM interactions)
   - Attack vectors (SQL injection, XSS, CSRF, prompt injection, data exfiltration)
   - Threat actors (anonymous attacker, authenticated attacker, insider)
   - Mitigations for each vector
   - Trust boundaries (user input → validation → storage → display → LLM)
   - Residual risks after mitigation

3. **Data Classification** (docs/security/DATA_CLASSIFICATION.md)
   - Classification levels (e.g., Public, Internal, Confidential, Restricted)
   - Classification of each data type:
     - User PII (name, email) → level + handling
     - Financial data (balances, transactions, income) → level + handling
     - Financial metadata (APR, account type, institution name) → level + handling
     - Authentication data (passwords, tokens, sessions) → level + handling
     - Koban conversation history → level + handling
     - Audit logs → level + handling
   - Handling requirements per level (encryption, access control, logging, retention)

### Should include:
- Reference to ADR-004 (no direct bank credentials)
- Reference to ADR-013 (no SOC 2 for MVP, path designed in)
- Reference to ADR-007 (money as integer cents — no float in storage)
- Residual risk assessment for each area

### Must NOT include:
- Product requirements or user journeys (Archivist domain)
- Financial calculation rules (Ledger domain)
- Infrastructure/CI/CD (Shinobi domain)
- Any code implementation

## Context

### Relevant source documents:
- docs/product/VISION.md — product overview
- docs/product/TRUST_MODEL.md — trust levels and data handling
- docs/planning/DECISION_LOG.md — ADR-004, ADR-007, ADR-013
- docs/planning/ASSUMPTIONS.md — security assumptions (not regulated, no bank credentials, encryption, audit logging)
- docs/planning/RISKS.md — risk register (data breach is top critical risk)
- docs/planning/PHASE_0_GATE.md — exit criteria
- docs/orchestration/AGENT_ROSTER.md — Sentinel responsibilities

### Key decisions to respect:
- ADR-004: No direct bank credential storage. Bank integration via OAuth or aggregator only.
- ADR-007: Money as integer minor units (cents). Never float.
- ADR-013: No SOC 2 required for MVP. Controls designed in for future path.
- MVP is single-user (ADR-005). Household-ready schema, but single-user enforcement.

### Background:
Zaifu handles sensitive financial data (balances, income, obligations). The MVP is not a regulated financial service, but the architecture must be designed with encryption, audit logging, and access controls that support a SOC 2 path post-launch. The top risk in the register is a data breach of account balances and transactions.

## Ownership and Constraints

### You may read:
- All files under docs/
- All files under shared/

### You may write/create:
- docs/security/SECURITY_ARCHITECTURE.md
- docs/security/THREAT_MODEL.md
- docs/security/DATA_CLASSIFICATION.md

### You must not:
- Modify any existing planning, product, or architecture documents
- Create requirements or financial domain documents
- Write any code

## Acceptance Criteria

- [ ] Security architecture defines what data is protected and against whom
- [ ] Encryption requirements cover transit, at-rest, and backups
- [ ] Authentication and authorization model is specified for MVP
- [ ] Audit logging requirements detail what events, what detail, retention
- [ ] Threat model covers all API surfaces, auth, import, and Koban LLM interactions
- [ ] Attack vectors include SQL injection, XSS, CSRF, prompt injection, data exfiltration
- [ ] Each vector has a mitigation
- [ ] Trust boundaries are mapped (user input → validation → storage → display → LLM)
- [ ] Residual risks are documented
- [ ] Data classification covers all data types with handling requirements per level
- [ ] All documents reference relevant ADRs
- [ ] Handoff document completed

## Deliverables

1. **Primary outputs:**
   - docs/security/SECURITY_ARCHITECTURE.md
   - docs/security/THREAT_MODEL.md
   - docs/security/DATA_CLASSIFICATION.md

2. **Handoff document:**
   - Format: per shared/templates/HANDOFF_TEMPLATE.md (or specialist-handoff.md)
   - Include: work performed, files created, acceptance criteria status, assumptions, risks, residual risks

---

## Output Protocol

State your Hermes profile name. Then emit your final specialist handoff EXACTLY ONCE between these markers:

<<<NINJATRONICS-RESULT-BEGIN:PH0-SEN-001>>>
[your complete handoff here]
<<<NINJATRONICS-RESULT-END:PH0-SEN-001>>>

Emit each marker line only once. Put NOTHING after the end-marker line. You are authorized to create the documents listed above in the zaifu repo. Report what you created in the handoff between the markers.
