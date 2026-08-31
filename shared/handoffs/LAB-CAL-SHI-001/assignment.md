# Assignment

## Assignment ID

`LAB-CAL-SHI-001`

## Owner

Shinobi (carried by Codex)

## Requested by

Nova

## Priority

Normal

## Objective

Research and design the Kubernetes deployment architecture for running Calibre (https://github.com/kovidgoyal/calibre) as a server-side application in a FluxCD/k3s GitOps homelab. The eventual public hostname is https://calibre.ninjatronics.io. This is RESEARCH AND PLAN ONLY — do not create any manifests, commits, or cluster changes.

## Context

This is a GitOps-managed Kubernetes homelab using FluxCD and k3s. Git is the single source of truth. Key rules:

- Apps follow a base/overlay Kustomize pattern: `kubernetes/apps/base/<app>/` (reusable resources) and `kubernetes/apps/production/<app>/` (overlay with ingress, external secrets).
- Storage uses local-path (RWO, node-local). Deployments using local-path must use `strategy: type: Recreate` and typically pin to a specific node via `nodeSelector`.
- Secrets come from OpenBao via External Secrets Operator (ESO). No plaintext secrets in Git. A `secret.example.yaml` in base documents expected keys.
- Ingress uses Traefik with cert-manager TLS (letsencrypt-production-cloudflare for public, lab-selfsigned for internal).
- Cloudflare Tunnel exposes public apps via cloudflared config at `kubernetes/infrastructure/base/cloudflared/config.yaml`.
- Namespaces are defined in `kubernetes/namespaces/`.
- Existing app patterns to reference: audiobookshelf (Deployment+PVC+Service, no Helm, runAsNonRoot), wallabag (Deployment+PVC+Postgres sidecar, ExternalSecret), n8n (config+secret+PVC, dual ingress internal/external).

Repository: /home/gerso/src/lab
Existing app directories to inspect for patterns:
- kubernetes/apps/base/audiobookshelf/ (deployment.yaml, pvc.yaml, service.yaml, configmap.yaml)
- kubernetes/apps/base/wallabag/ (deployment.yaml, pvc-data.yaml, pvc-images.yaml, secret.example.yaml, postgres-deployment.yaml)
- kubernetes/apps/base/n8n/ (deployment.yaml, pvc.yaml, configmap.yaml, secret.example.yaml)
- kubernetes/apps/production/audiobookshelf/ (ingress.yaml, kustomization.yaml)
- kubernetes/apps/production/wallabag/ (ingress.yaml, external-secrets/, kustomization.yaml)
- kubernetes/apps/production/n8n/ (ingress.yaml, ingress-external.yaml, external-secrets/, kustomization.yaml)
- kubernetes/infrastructure/base/cloudflared/config.yaml (tunnel ingress rules)
- kubernetes/namespaces/ (namespace definitions)

## Scope

Research and design only. Inspect the existing repository patterns listed above. Research the upstream Calibre project and its server-mode capabilities. Produce a recommended Kubernetes deployment architecture.

## Out of scope

- Creating any Kubernetes manifests, files, or commits
- Any cluster changes or kubectl apply
- Creating Cloudflare DNS records or tunnel routes
- Creating OpenBao secrets
- Security review (handled separately by Sentinel)

## Inputs

- Upstream project: https://github.com/kovidgoyal/calibre
- Repository: /home/gerso/src/lab
- Existing app patterns in the repository (paths listed above)

## Constraints

- Read-only analysis — do not modify any files
- Do not create manifests, commits, or cluster changes
- Do not expose credentials
- Return findings as structured text
- Follow existing repository conventions exactly
- All findings must be grounded in the actual repository files and upstream documentation

## Required deliverables

1. Assessment of whether upstream Calibre is appropriate for Kubernetes server-side deployment
2. Whether calibre-server is sufficient or whether a third-party container image is needed
3. Recommended container image with rationale (maintained, immutable tag/digest strategy)
4. Current stable Calibre version
5. Container port(s) and what each serves
6. UID/GID and security context requirements
7. Required and optional persistent directories with mount paths
8. Whether a separate library PVC should be used (vs combined config+library)
9. Update/upgrade behavior (does upgrading the image require DB migration, etc.)
10. Health-check endpoints or strategies
11. Resource requirements (CPU/memory requests and limits)
12. Node placement recommendation (which worker node, local-path implications)
13. PVC sizes and mount paths
14. Service and port layout
15. Ingress design (internal vs external, Traefik annotations)
16. Whether WebSocket or special proxy behavior is needed (Calibre's web UI may use WebSockets)
17. Backup/recovery considerations for the Calibre library and configuration
18. Proposed exact Kubernetes resources/files that would be created (paths and resource types)
19. Namespace recommendation (dedicated vs shared `apps` namespace)
20. Internal validation procedure (kubectl kustomize, health checks, persistence test)
21. Upgrade strategy
22. Rollback considerations
23. Public-exposure sequence (when to add Cloudflare tunnel route, DNS, etc.)

## Validation required

- Confirm findings against actual repository files (read them)
- Confirm container image existence and digest strategy via web research
- Confirm Calibre server capabilities via upstream documentation
- Validate that the proposed architecture matches existing repository conventions

## Evidence required

- Commands executed (web research, file reads)
- File paths inspected
- Specific URLs consulted
- Container image references with tags/digests
- Calibre version number

## Dependencies

- None (this is the initial research assignment)

## Escalation conditions

- If Calibre cannot run headlessly in a container, report and stop
- If no maintained container image exists, report and stop
- If the architecture requires deviations from existing repository patterns, document and escalate

## Completion criteria

- All 23 deliverables above are addressed
- Findings are grounded in repository inspection and upstream research
- The proposed architecture matches existing repository conventions
- Risks and assumptions are disclosed
- The handoff is in the Specialist Handoff format

## Recommended next owner

Nova (synthesis) → Sentinel (security review of the proposed architecture)
