# Ninjatronics AI Security Review Standard

## Purpose

This standard defines the mandatory dimensions of a security review and the
evidence required before a design, change, or deployment is approved.

Sentinel owns this standard. Nova routes security-sensitive work through it.
Shinobi implements the required controls. Archivist preserves the evidence.

A review is complete only when every applicable dimension below has been
assessed, findings are supported by evidence, required controls are explicit,
and residual risk is stated.

## Review dimensions

### 1. Secret storage

Assess how credentials, keys, tokens, and certificates are stored, injected,
rotated, and retired.

Required controls:

- No secrets in Git, container images, logs, environment dumps, or chat.
- Secrets stored in a dedicated secret manager (e.g. External Secrets,
  Sealed Secrets, Vault, cloud KMS-backed stores) — not plain Kubernetes
  Secrets committed to a repo.
- Secrets encrypted at rest (etcd encryption or external store).
- Access to secrets scoped to the consuming workload only.
- Rotation procedure defined; short-lived credentials preferred.
- Secret scanning enabled on all repositories.

Evidence:

- Secret store configuration export.
- Repository secret-scan results.
- RBAC bindings that grant secret access, with justification.
- Rotation record or documented rotation procedure.

### 2. RBAC

Assess who and what can perform which actions, in which scope.

Required controls:

- Least privilege: no cluster-admin for workloads or day-to-day humans.
- No wildcard verbs/resources in Roles bound to service accounts.
- Distinct service accounts per workload; automountServiceAccountToken
  disabled where not needed.
- Human access via groups/identity provider, not shared accounts.
- Privileged roles time-bound or just-in-time where the platform supports it.
- Periodic access review with a recorded outcome.

Evidence:

- Export of Roles/ClusterRoles and bindings in scope.
- List of subjects with privileged access and justification.
- Most recent access review record.

### 3. Network exposure

Assess what is reachable, from where, on which ports and protocols.

Required controls:

- Default-deny posture at the perimeter; only required services exposed.
- No administrative interfaces (API server, SSH, management UIs, database
  ports) exposed to the internet without compensating controls.
- Ingress via a controlled entry point (ingress controller, load balancer,
  firewall policy) with an owner.
- Firewall/security-group rules scoped to specific sources; no 0.0.0.0/0 on
  administrative or data ports.
- Egress restricted for sensitive workloads where feasible.

Evidence:

- External scan or port inventory of exposed endpoints.
- Firewall / security group / ingress configuration export.
- Justification for every internet-facing listener.

### 4. TLS

Assess encryption in transit for user-facing, service-to-service, and
administrative traffic.

Required controls:

- TLS on all external endpoints; TLS 1.2 minimum, TLS 1.3 preferred.
- No self-signed certificates on user-facing services; certificates issued
  by a managed CA (e.g. cert-manager with ACME or internal CA).
- Certificate expiry monitored; renewal automated where possible.
- Internal service-to-service encryption for sensitive data paths
  (mTLS or mesh where justified).
- Weak protocols and ciphers disabled (no SSLv3/TLS 1.0/1.1, no known-weak
  cipher suites).

Evidence:

- TLS scan output (protocol versions, cipher suites) for external endpoints.
- Certificate inventory with issuer and expiry.
- cert-manager or CA configuration export.

### 5. Namespace and tenant isolation

Assess separation between workloads, environments, and tenants.

Required controls:

- Separate namespaces per application/environment; no shared "default"
  namespace for real workloads.
- NetworkPolicy default-deny within sensitive namespaces; explicit allows
  only for required flows.
- ResourceQuota and LimitRange to prevent noisy-neighbor exhaustion.
- Pod Security Admission (baseline minimum; restricted for sensitive
  workloads): no privileged pods, no hostPath/hostNetwork without a
  documented exception.
- Production and non-production separated by namespace at minimum;
  by cluster where risk warrants.

Evidence:

- Namespace inventory with owners.
- NetworkPolicy export for in-scope namespaces.
- Pod Security Admission configuration.
- Any exception records for privileged workloads.

### 6. Logging and audit

Assess whether misuse or failure would be detected and provable.

Required controls:

- Kubernetes API audit logging enabled and shipped off-cluster.
- Application and infrastructure logs centralized with retention defined.
- Authentication and privileged-action events captured (sign-ins, role
  changes, secret access where supported).
- Logs protected from modification by the systems they monitor.
- Alerting on high-signal events (new privileged binding, audit pipeline
  failure, authentication anomalies).
- Time synchronization across log sources.

Evidence:

- Logging pipeline configuration.
- Sample audit events demonstrating capture of a privileged action.
- Retention configuration.
- Alert rule export.

### 7. Supply chain

Assess trust in the code, dependencies, images, and pipeline that produce
the running system.

Required controls:

- Images pulled from approved registries only; pinned by digest or
  controlled tag policy — no unpinned `latest` in production.
- Dependency and container scanning in CI; build fails on critical
  vulnerabilities without a recorded exception.
- Branch protection and mandatory review on production repositories.
- CI/CD credentials scoped per pipeline; no long-lived admin tokens.
- Provenance: deployed artifacts traceable to a commit and pipeline run.
  SBOM generated where tooling supports it.
- GitOps: cluster state derives from Git; manual drift is detected.

Evidence:

- CI configuration showing scan and gate steps.
- Branch protection settings export.
- Recent scan reports.
- Image policy or admission control configuration.

### 8. Backup and recovery

Assess whether the system can be restored after compromise, corruption,
or loss — recovery is a security control.

Required controls:

- Backups defined for all stateful components, with scope and schedule.
- At least one backup copy isolated from the primary environment's
  administrative credentials (offline, separate account, or immutable).
- Backups encrypted; access to backups restricted and logged.
- Restore procedure documented and TESTED — an untested backup is not
  a control. Test at a defined interval.
- RPO and RTO stated and accepted by the system owner.
- Recovery path does not depend solely on the system being recovered
  (no circular dependency).

Evidence:

- Backup configuration and recent job results.
- Most recent restore test record with outcome.
- Documented RPO/RTO.

## Severity classification

Classify each finding:

- Critical — exploitation is likely and impact is severe; stop-ship.
- High — significant risk requiring remediation before or immediately
  after release, with an owner and date.
- Moderate — real risk; remediate on a committed timeline.
- Low — limited risk; remediate opportunistically.
- Informational — no direct risk; improvement opportunity.

Severity reflects likelihood and impact, not wording.

## Required controls vs. recommended improvements

Every review must separate:

- Required controls — mandatory before approval, or covered by a
  documented exception with compensating controls, scope, duration,
  approver, and expiry.
- Recommended improvements — hardening beyond the minimum; tracked
  but not blocking.

## Residual risk

Every review ends with an explicit residual risk statement:

- What risk remains after required controls are implemented.
- Why it is accepted (cost, feasibility, likelihood).
- Who accepts it.
- When it is next reviewed.

"None identified" is acceptable only when the review actually supports it.
Silence about residual risk is not acceptance.

## Review output format

A completed review contains:

1. Executive summary
2. Scope reviewed and assumptions
3. Findings with severity and evidence
4. Required controls
5. Recommended improvements
6. Validation steps (how the fix will be proven)
7. Residual risk statement
8. Exceptions, owners, and approval requirements

Archivist indexes the evidence. Nova routes approval. Shinobi implements
remediation and returns validation evidence to Sentinel for closure.

A remediation is closed only when evidence shows the control is active and
tested — not merely that a change was made.
