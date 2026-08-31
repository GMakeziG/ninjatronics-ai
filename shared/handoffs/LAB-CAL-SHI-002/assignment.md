# Assignment

## Assignment ID

`LAB-CAL-SHI-002`

## Owner

Shinobi (carried by Codex runtime)

## Requested by

Nova

## Priority

Normal

## Objective

Implement the complete Calibre GitOps deployment for the Flux/k3s homelab.
Build a Ninjatronics-owned minimal container image and create all Kubernetes
manifests following the repo's base + production overlay pattern. Deploy
internally (no public exposure). Validate that the pod runs, authentication
is enabled, and persistence survives pod recreation.

Gerso has approved Option B: a Ninjatronics-owned minimal Calibre image.

## Context

The homelab repo is at /home/gerso/src/lab. It uses:
- FluxCD for GitOps reconciliation (Flux applies layers in order: namespaces, infrastructure, apps, observability)
- k3s with MetalLB (pool: 10.99.0.0/24)
- Traefik ingress
- cert-manager with letsencrypt-production-cloudflare issuer
- Cloudflare Tunnel for public exposure (NOT for this phase — internal only)
- OpenBao + External Secrets Operator for runtime secrets
- local-path storage class (RWO, node-local, reclaimPolicy: Delete)
- Nodes: zion (control plane), samson (worker), niner (worker)

Calibre research is complete. The approved architecture:
- Dedicated namespace: calibre
- Base + production overlay Kustomize pattern
- PVCs: calibre-config (2Gi), calibre-library (100Gi), local-path, RWO
- Node placement: kubernetes.io/hostname: niner
- Strategy: Recreate (single replica, RWO storage)
- Security context: runAsNonRoot, runAsUser 10001, runAsGroup 10001, fsGroup 10001, seccompProfile RuntimeDefault, allowPrivilegeEscalation false, capabilities drop ALL
- Service: ClusterIP, port 8080
- Auth: calibre-server --enable-auth --userdb, credentials via OpenBao at secret/apps/calibre
- Health: TCP probes (no dedicated HTTP health endpoint confirmed)
- OpenBao + ESO for runtime secrets, ExternalSecret in production overlay
- Ingress: Traefik, cert-manager TLS (internal only — NO public hostname, NO Cloudflare Tunnel route)

The Ninjatronics-owned minimal image requirements:
- Debian trixie-slim base pinned by digest
- Official Calibre binary, version pinned
- Calibre tarball SHA-256 verified at build time
- Non-root UID/GID 10001:10001
- calibre-server only (no desktop/VNC/terminal)
- Port 8080 only
- No desktop/X11/Wayland dependencies

Existing app patterns to follow (study these in the repo):
- kubernetes/apps/base/audiobookshelf/ — plain manifests, non-root, local-path PVCs, securityContext, Recreate strategy, ClusterIP service
- kubernetes/apps/production/wallabag/ — overlay with ExternalSecret (secret/apps/wallabag), ingress, namespace overlay
- kubernetes/namespaces/ — namespace manifests + kustomization.yaml
- kubernetes/apps/production/kustomization.yaml — app aggregation

## Scope

The homelab repo at /home/gerso/src/lab. Files to create:

1. Container image:
   - Dockerfile for the Ninjatronics-owned minimal Calibre image
   - Build script or Makefile if needed for reproducible builds
   - The image must be built and pushed to the ghcr.io/ninjatronics registry OR
     built locally and loaded into k3s (document which approach is used)

2. Kubernetes manifests — base (kubernetes/apps/base/calibre/):
   - kustomization.yaml
   - configmap.yaml (if needed for calibre-server configuration)
   - deployment.yaml
   - service.yaml
   - pvc.yaml (calibre-config 2Gi, calibre-library 100Gi, local-path, RWO)
   - secret.example.yaml (document expected secret keys without values)

3. Kubernetes manifests — production overlay (kubernetes/apps/production/calibre/):
   - kustomization.yaml
   - ingress.yaml (internal only — use a .internal or .local hostname, NOT ninjatronics.io)
   - external-secrets/kustomization.yaml
   - external-secrets/calibre-secret.yaml (ExternalSecret referencing ClusterSecretStore: openbao, path: apps/calibre)

4. Namespace (kubernetes/namespaces/calibre.yaml + add to kustomization.yaml)

5. Aggregation: add calibre to kubernetes/apps/production/kustomization.yaml

6. OpenBao secret: store calibre auth credentials at secret/apps/calibre in OpenBao
   (you may need to use the bao CLI — check if it's available; if not, document
   the exact commands for Gerso to run)

7. Cloudflare Tunnel route: NOT for this phase. Do NOT create or modify cloudflared config.

## Out of scope

- Cloudflare DNS records
- Cloudflare Tunnel route configuration
- Cloudflare Access policies
- Public ingress exposure (any .ninjatronics.io hostname)
- Sentinel security review (separate assignment LAB-CAL-SEN-002)
- Any changes to infrastructure/ layer
- Any changes to existing apps

## Inputs

- The handoff at /home/gerso/Development/ninjatronics-ai/shared/handoffs/NOVA-CONTINUATION/calibre-deployment-handoff.md
- The existing app patterns in /home/gerso/src/lab/kubernetes/apps/

## Constraints

- Follow the established base + production overlay Kustomize pattern exactly
- Use local-path storage class (RWO, node-local)
- Pin workload to node niner (nodeSelector: kubernetes.io/hostname: niner)
- No plaintext secrets in Git — use OpenBao + ESO
- Security context: non-root (UID 10001), seccompProfile RuntimeDefault, no privilege escalation, drop ALL capabilities
- Port 8080 only — no other ports
- calibre-server only — no desktop/VNC/terminal/X11
- Internal-only ingress — do NOT use any .ninjatronics.io hostname or configure Cloudflare Tunnel
- Validate all manifests with kubectl kustomize before committing
- Do NOT use kubectl apply — Flux handles reconciliation from Git
- The Dockerfile must pin the Debian base image by digest
- The Dockerfile must pin the Calibre version and verify the tarball SHA-256
- Export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH" before running any commands
- Use kubectl and kustomize from Linuxbrew PATH

## Required deliverables

1. Dockerfile for the minimal Calibre image (pinned base, pinned Calibre, SHA-256 verification)
2. All Kubernetes manifests listed in Scope above
3. OpenBao secret created at secret/apps/calibre (or documented commands if bao CLI is unavailable)
4. kubectl kustomize validation of base, production overlay, and production app layer
5. Evidence that the pod is running and healthy (if k3s is accessible)
6. Evidence that authentication is enabled
7. Evidence that persistence survives pod recreation (delete pod, verify data persists)
8. Git commit with all manifests (do NOT push — Nova will review before push)

## Validation required

1. kubectl kustomize kubernetes/apps/base/calibre/ — must succeed
2. kubectl kustomize kubernetes/apps/production/calibre/ — must succeed
3. kubectl kustomize kubernetes/namespaces/ — must succeed (with calibre.yaml added)
4. kubectl kustomize kubernetes/apps/production/ — must succeed (with calibre added)
5. If k3s is accessible: verify pod reaches Running state
6. If k3s is accessible: verify persistence by deleting pod and checking data survives
7. If k3s is accessible: verify calibre-server responds on port 8080

## Evidence required

- Commands executed (kubectl kustomize output, kubectl get pods, etc.)
- File paths created
- Git diff or commit hash
- kubectl kustomize validation output
- Pod status output
- Persistence test output (before/after pod deletion)

## Dependencies

- None (research phase is complete)

## Escalation conditions

- If calibre-server cannot run headless in the minimal image, escalate to Nova
- If OpenBao is not accessible for secret creation, document commands for Gerso
- If k3s/Flux is not accessible for deployment validation, report what was validated vs what remains
- If the Debian trixie-slim base or Calibre tarball cannot be digest/SHA-256 pinned, escalate to Nova
- If any security deviation from the approved architecture is needed, escalate to Nova

## Completion criteria

- Dockerfile exists with pinned base digest and SHA-256-verified Calibre
- All Kubernetes manifests exist and follow the base + production overlay pattern
- kubectl kustomize passes for base, production overlay, namespace layer, and app aggregation
- Security context matches the approved architecture (non-root UID 10001, seccomp, drop ALL)
- Port 8080 only
- No Cloudflare or public exposure configuration
- OpenBao secret created or documented for Gerso
- Pod running and healthy (if k3s accessible) OR deployment validated via kustomize with remaining steps documented
- Persistence validated (if k3s accessible) OR documented as remaining

## Recommended next owner

Sentinel (for security review of the actual deployed manifests — assignment LAB-CAL-SEN-002)

## Response format

Format your response as a Specialist Handoff with these sections:
<<<RESULT:LAB-CAL-SHI-002>>>
# Specialist Handoff

## Assignment ID
LAB-CAL-SHI-002

## Status
(Complete / Complete with findings / Blocked / Requires clarification / Failed)

## Objective
(Restate)

## Scope reviewed
(What was examined or changed)

## Assumptions
(List anything not independently verified)

## Work performed
(Summarize the implementation)

## Findings
(Conclusions and observations)

## Deliverables
(List files, manifests, images produced)

## Validation
(Tests and checks performed)

## Evidence
(Commands, paths, logs, diffs, commit IDs)

## Risks
(Known concerns)

## Outstanding work
(Anything incomplete or deferred)

## Escalations
(Decisions requiring Nova or Gerso)

## Recommended next owner
Sentinel (LAB-CAL-SEN-002)
<<<END:LAB-CAL-SHI-002>>>
