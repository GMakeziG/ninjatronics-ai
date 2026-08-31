# Assignment

## Assignment ID

`LAB-CAL-SEN-001`

## Owner

Sentinel (carried by Codex)

## Requested by

Nova

## Priority

Normal

## Objective

Perform an independent security review of deploying Calibre (https://github.com/kovidgoyal/calibre) as a server-side application exposed through Cloudflare Tunnel at https://calibre.ninjatronics.io in a FluxCD/k3s GitOps homelab. This is RESEARCH ONLY — do not create any manifests, commits, or cluster changes.

## Context

This is a GitOps-managed Kubernetes homelab using FluxCD and k3s. Key security-relevant facts:

- Public apps are exposed through Cloudflare Tunnel (cloudflared) which proxies to Traefik ingress over HTTPS.
- Traefik handles ingress routing. cert-manager provides TLS (letsencrypt-production-cloudflare for public hostnames).
- Secrets come from OpenBao via External Secrets Operator. No plaintext secrets in Git.
- Existing security patterns to reference:
  - audiobookshelf: runAsNonRoot: true, runAsUser: 1000, fsGroup: 1000, seccompProfile RuntimeDefault, capabilities drop ALL, allowPrivilegeEscalation false
  - wallabag: runs as root (s6/nginx requires it), allowPrivilegeEscalation false only
  - n8n: no explicit securityContext (gap)

Repository: /home/gerso/src/lab
Inspect these files for existing security patterns:
- kubernetes/apps/base/audiobookshelf/deployment.yaml (good securityContext example)
- kubernetes/apps/base/wallabag/deployment.yaml (root-requiring image securityContext)
- kubernetes/apps/base/n8n/deployment.yaml (minimal securityContext)
- kubernetes/infrastructure/base/cloudflared/config.yaml (tunnel config)
- kubernetes/infrastructure/base/cert-manager/issuers/ (TLS issuers)

## Scope

Security review and analysis only. Inspect existing repository security patterns. Research Calibre's authentication model, attack surface, and public-exposure considerations. Produce a security assessment.

## Out of scope

- Creating any files, manifests, or commits
- Any cluster changes
- Deployment architecture design (handled by Shinobi)
- Creating Cloudflare or DNS configurations

## Inputs

- Upstream project: https://github.com/kovidgoyal/calibre
- Repository: /home/gerso/src/lab
- Existing security patterns in the repository (paths listed above)

## Constraints

- Read-only analysis — do not modify any files
- Do not create manifests, commits, or cluster changes
- Do not expose credentials
- Return findings as structured text
- All findings must be grounded in actual repository files and upstream documentation

## Required deliverables

1. Calibre's authentication model — does calibre-server have built-in authentication? What options exist?
2. Whether public exposure through Cloudflare Tunnel is safe/reasonable for Calibre
3. Attack surface assessment — what does calibre-server expose? (web UI, OPDS feed, content serving, file browsing)
4. Whether WebSocket or special proxy behavior is required (affects Cloudflare Tunnel config)
5. Recommended security context for the Calibre container (runAsNonRoot, UID/GID, capabilities, seccomp)
6. Whether Calibre needs any secrets (authentication credentials, API keys)
7. If secrets are needed, what OpenBao path and keys would be appropriate
8. Whether Cloudflare Access policies should be added before public exposure
9. Whether the calibre-server should be behind authentication at the Traefik level (middleware) in addition to Calibre's own auth
10. Network policy considerations (if any exist in the cluster)
11. Risk assessment for exposing a book library management tool publicly
12. Recommended security hardening beyond the existing patterns

## Validation required

- Confirm findings against actual repository files (read them)
- Confirm Calibre's auth capabilities via upstream documentation
- Validate that security recommendations are consistent with existing repository patterns

## Evidence required

- Commands executed (web research, file reads)
- File paths inspected
- Specific URLs consulted
- Calibre authentication documentation references

## Dependencies

- None (this is an independent security review)

## Escalation conditions

- If public exposure of Calibre is fundamentally unsafe, report and stop
- If the security posture requires deviations from existing patterns, document and escalate
- If Calibre has known CVEs or security advisories relevant to server-side deployment, report

## Completion criteria

- All 12 deliverables above are addressed
- Findings are grounded in repository inspection and upstream research
- Risks and assumptions are disclosed
- The handoff is in the Specialist Handoff format

## Recommended next owner

Nova (synthesis and coordination with Shinobi's architecture findings)
