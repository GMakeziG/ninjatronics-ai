---
title: Calibre
type: system
status: active
tags:
  - calibre
  - homelab
  - kubernetes
  - k3s
  - gitops
  - flux
  - cloudflare
  - openbao
  - external-secrets
created: 2026-08-31
updated: 2026-08-31
---

# Calibre

## Overview

Self-hosted Calibre content server for ebook library management and OPDS feed
access. Deployed in the [[Ninjatronics K3s Homelab]], fully GitOps managed
through Flux. Uses a custom non-root container image published to GHCR.

- **Public URL:** https://calibre.ninjatronics.io
- **Namespace:** `calibre`
- **Node:** `niner` (pinned via `nodeSelector`)
- **Status:** Deployed and publicly reachable (HTTP 200 web UI, HTTP 401 on
  `/opds` unauthenticated)

## Version

- **Calibre application:** 9.14.0
- **Image:** `ghcr.io/gmakezig/calibre-server:9.14.0@sha256:429bb900368ea140d7d0ecbd6d3cee5210dc701f92783f04feec18995e39013d`
- **Base image:** `debian:trixie-slim`

The image is custom-built from `containers/calibre/` in the lab repo. It
downloads the official Calibre binary archive, strips GUI components (Qt
Wayland/X11 platform plugins, ebook viewers, editors, SMTP), and runs
`calibre-server` headless as non-root UID/GID 10001.

## Architecture

```
Internet
  |
Cloudflare (DNS CNAME -> tunnel endpoint, Proxied)
  |
Cloudflare Tunnel (homelab-k3s)
  |
cloudflared (namespace: platform)
  |
Traefik (Ingress, calibre.ninjatronics.io)
  |
Calibre Service (ClusterIP :8080)
  |
Calibre Pod (namespace: calibre, port 8080, UID 10001)
```

Calibre is pinned to **niner** because the cluster uses `local-path` storage
(`ReadWriteOnce`), which is node-local. Same pattern as [[Forgejo]] and
[[Wallabag]].

### Container design

The custom Docker image (`containers/calibre/Dockerfile`) is a two-stage build:

1. **Extract stage:** Downloads the official Calibre binary tarball for
   `CALIBRE_VERSION`, verifies the SHA-256 checksum, extracts to `/opt/calibre`,
   and strips GUI-only binaries and Qt platform plugins (Wayland, XCB, EGL
   device integrations) that are unnecessary for headless server use.
2. **Runtime stage:** Installs minimal runtime libraries (`libfontconfig1`,
   `libglvnd0`, `libopengl0`, `libx11-6`, `libxkbcommon0`, plus selective
   `libegl1`/`libglx0` extraction to satisfy Qt's GLVND EGL ABI without pulling
   in Mesa/X11/Wayland). Creates UID/GID 10001, sets `QT_QPA_PLATFORM=offscreen`.

The entrypoint (`containers/calibre/entrypoint.sh`):

1. Requires `CALIBRE_USERNAME` and `CALIBRE_PASSWORD` environment variables.
2. Initializes the library (`calibredb list`) if `/library/metadata.db` does not
   exist — idempotent, only runs on empty PVC.
3. Adds or updates the user in `/config/users.sqlite` via
   `calibre-server --manage-users`.
4. Unsets the credential environment variables.
5. Execs `calibre-server --listen-on 0.0.0.0 --port 8080 --enable-auth
   --userdb /config/users.sqlite /library`.

### Security context

- `runAsNonRoot: true`, `runAsUser: 10001`, `runAsGroup: 10001`,
  `fsGroup: 10001`
- `seccompProfile: RuntimeDefault`
- `allowPrivilegeEscalation: false`
- `capabilities.drop: [ALL]`
- Deployment strategy: `Recreate` (single replica, local-path storage)
- Non-root UID/GID 10001 (not 0)

## Storage

| Resource          | Size  | StorageClass | Node  | Mount path |
|-------------------|-------|--------------|-------|------------|
| `calibre-config`  | 2 Gi  | local-path   | niner | `/config`  |
| `calibre-library` | 100 Gi| local-path   | niner | `/library` |

- `calibre-config`: Calibre server config and user database (`users.sqlite`)
- `calibre-library`: Ebook library and `metadata.db`

`local-path` does not support volume expansion; sizes are fixed at creation.

## Services

| Service    | Type       | Port |
|------------|------------|------|
| `calibre`  | ClusterIP  | 8080 |

No NodePort, LoadBalancer, or hostPort exposure.

## Secrets

Secrets are stored in [[OpenBao]] and populated by External Secrets Operator.
No real secret values are in Git.

- **OpenBao path:** `secret/apps/calibre`
- **ESO remote reference:** `apps/calibre`

Properties and Kubernetes Secret key mappings:

| OpenBao property | Kubernetes Secret key | Used by         |
|-------------------|-----------------------|-----------------|
| `username`        | `CALIBRE_USERNAME`    | entrypoint.sh   |
| `password`         | `CALIBRE_PASSWORD`    | entrypoint.sh   |

A `secret.example.yaml` with placeholders only is retained in the repo for
documentation/reference.

## Configuration

Non-secret environment is in a ConfigMap (`calibre-config`), consumed via
`envFrom`:

- `CALIBRE_CONFIG_DIRECTORY=/config`
- `TZ=America/Los_Angeles`

Secret environment is in `calibre-secret`, consumed via `secretKeyRef` for
`CALIBRE_USERNAME` and `CALIBRE_PASSWORD`.

## Probes

- **Startup:** TCP socket port 8080, `periodSeconds: 5`, `failureThreshold: 24`
  (2-minute timeout for library initialization)
- **Readiness:** TCP socket port 8080, `periodSeconds: 10`
- **Liveness:** TCP socket port 8080, `periodSeconds: 20`

## TLS

- **ClusterIssuer:** `letsencrypt-production-cloudflare`
- **Certificate:** `calibre-ninjatronics-io-tls` (Ready=True)
- **DNS-01 challenge** via Cloudflare API

## Cloudflare

- **Hostname:** `calibre.ninjatronics.io`
- **DNS:** CNAME -> `381367a6-bdca-44e3-b78e-285166692048.cfargotunnel.com`
  (Proxied)
- **Tunnel:** `homelab-k3s` (same tunnel as all homelab public services)
- **cloudflared route:** `calibre.ninjatronics.io` ->
  `https://traefik.kube-system.svc.cluster.local:443`

## GitOps file structure

```
containers/calibre/
├── Dockerfile
├── Makefile
├── README.md
└── entrypoint.sh

kubernetes/apps/base/calibre/
├── configmap.yaml
├── deployment.yaml
├── kustomization.yaml
├── pvc.yaml
├── secret.example.yaml
└── service.yaml

kubernetes/apps/production/calibre/
├── README.md
├── ingress.yaml
├── kustomization.yaml
└── external-secrets/
    ├── calibre-secret.yaml
    └── kustomization.yaml

kubernetes/namespaces/calibre.yaml
docs/calibre-runbook.md
```

Additional files touched:

- `kubernetes/apps/production/kustomization.yaml`
- `kubernetes/namespaces/kustomization.yaml`
- `kubernetes/infrastructure/base/cloudflared/config.yaml` (tunnel route)

## GHCR image publishing

The custom Calibre image is published to GitHub Container Registry at
`ghcr.io/gmakezig/calibre-server`. Key details:

- **GHCR owner:** `GMakeziG` (not `ninjatronics`) — this was corrected during
  the project; the initial Makefile and runbook referenced the wrong owner.
- Publishing required a **classic Personal Access Token** with `write:packages`
  scope.
- The GHCR package is set to **public visibility**, which permits anonymous
  Kubernetes image pulls without image pull secrets.
- The deployment image is **digest-pinned**:
  `ghcr.io/gmakezig/calibre-server:9.14.0@sha256:429bb9...39013d`

## Design requirements

- Fully GitOps managed through Flux
- Public access through Cloudflare Tunnel
- Traefik handles Kubernetes ingress
- TLS via cert-manager + Let's Encrypt (`letsencrypt-production-cloudflare`)
- No public NodePort or LoadBalancer
- Secrets in OpenBao via External Secrets Operator
- Persistent storage through local-path
- Calibre pinned to niner
- Non-root execution (UID/GID 10001)
- No `latest` image tags; digest-pinned
- Custom image stripped of GUI components for headless server use

## Validation

- `kubectl kustomize` at all affected layers: succeeded
- `flux get kustomizations`: all Ready, reconciled at `main@sha1:be0edee`
- `kubectl get pods -n calibre`: pod Running/Ready on niner
- `kubectl get pvc -n calibre`: both PVCs Bound
- `kubectl get externalsecret -n calibre`: Ready, all keys present
- `kubectl get certificate -n calibre`: Ready (True)
- Public web UI: HTTP 200
- `/opds` unauthenticated: HTTP 401 (auth enforced)
- Invalid credentials rejected
- Sentinel Phase 2: PASS WITH NOTES

## Sentinel backlog

1. Add NetworkPolicy for Calibre namespace
2. Set `automountServiceAccountToken: false`
3. Evaluate `readOnlyRootFilesystem`

## First-boot behavior

The entrypoint initializes the library (`calibredb list`) only if
`/library/metadata.db` does not exist. The user database (`/config/users.sqlite`)
is created/updated on every boot via `calibre-server --manage-users` — the
entrypoint checks if the user exists and adds or updates the password
accordingly. On subsequent restarts, the library already exists and the
entrypoint only ensures the user credential is current.

## Related notes

- [[Ninjatronics K3s Homelab]]
- [[Calibre Operations]]
- [[Forgejo]]
- [[Wallabag]]
- [[Kustomize ConfigMapGenerator Rollout Triggers]]
