---
title: Forgejo
type: system
status: active
tags:
  - forgejo
  - git
  - homelab
  - kubernetes
  - k3s
  - gitops
  - flux
  - cloudflare
  - openbao
  - external-secrets
created: 2026-08-30
updated: 2026-08-30
---

# Forgejo

## Overview

Self-hosted Forgejo instance for maintaining and mirroring personal Git
repositories. Deployed in the [[Ninjatronics K3s Homelab]], fully GitOps
managed through Flux.

- **Public URL:** https://git.ninjatronics.io
- **Namespace:** `forgejo`
- **Status:** Deployed and publicly reachable (HTTP/2 200)

## Version

- **Forgejo application:** 15.0.7 (LTS release)
- **Forgejo image:** `15.0.7-rootless`
- **Helm chart:** 17.1.5

Important: Forgejo Helm chart 17.x no longer bundles PostgreSQL. PostgreSQL
must be deployed separately.

## Architecture

```
Internet
  |
Cloudflare
  |
Cloudflare Tunnel (homelab-k3s)
  |
cloudflared (namespace: platform)
  |
Traefik
  |
Forgejo Ingress
  |
Forgejo (namespace: forgejo)
  |
PostgreSQL (namespace: forgejo)
```

Both Forgejo and PostgreSQL are pinned to **niner** because the cluster
uses `local-path` storage (`ReadWriteOnce`), which is node-local.

## Storage

| Resource        | Size  | StorageClass | Node   |
|-----------------|-------|--------------|--------|
| Forgejo PVC     | 20 Gi | local-path   | niner  |
| PostgreSQL PVC | 10 Gi | local-path   | niner  |

## Services

| Service           | Type       |
|-------------------|------------|
| `forgejo-http`    | ClusterIP  |
| `forgejo-ssh`     | ClusterIP  |
| `forgejo-postgres`| ClusterIP  |

## Secrets

Secrets are stored in [[OpenBao]] and populated by External Secrets
Operator. No real secret values are in Git.

- **OpenBao path:** `secret/apps/forgejo`
- **ESO remote reference:** `apps/forgejo`

Properties and Kubernetes Secret key mappings:

| OpenBao            | Kubernetes Secret key |
|--------------------|------------------------|
| `admin-username`   | `username`             |
| `admin-password`   | `password`             |
| `database-password`| `POSTGRES_PASSWORD`   |
| `secret-key`       | `SECRET_KEY`           |
| `internal-token`   | `INTERNAL_TOKEN`       |
| `jwt-secret`       | `JWT_SECRET`           |
| `lfs-jwt-secret`   | `LFS_JWT_SECRET`       |

OpenBao KV v2 policy:

```hcl
path "secret/data/apps/forgejo" {
  capabilities = ["read"]
}

path "secret/metadata/apps/forgejo" {
  capabilities = ["read"]
}
```

A `secret.example.yaml` with placeholders only is retained in the repo
for documentation/reference.

## GitOps file structure

```
kubernetes/apps/base/forgejo/
├── helmrelease.yaml
├── helmrepository.yaml
├── kustomization.yaml
├── notes.md
├── postgres-deployment.yaml
├── postgres-pvc.yaml
├── postgres-service.yaml
└── secret.example.yaml

kubernetes/apps/production/forgejo/
├── external-secrets/
│   ├── forgejo-secret.yaml
│   └── kustomization.yaml
├── ingress.yaml
└── kustomization.yaml
```

Additional files touched:

- `kubernetes/apps/production/kustomization.yaml`
- `kubernetes/infrastructure/base/cloudflared/configmap.yaml`
- `kubernetes/namespaces/forgejo.yaml`
- `kubernetes/namespaces/kustomization.yaml`

The obsolete `helm-values.yaml` was removed.

## Design requirements

- Fully GitOps managed through Flux
- Public access through Cloudflare Tunnel
- Traefik handles Kubernetes ingress
- TLS enabled
- No public NodePort or LoadBalancer
- Secrets in OpenBao via External Secrets Operator
- Persistent storage through local-path
- Forgejo and PostgreSQL colocated on niner
- Registration disabled
- No `latest` image tags; Forgejo LTS preferred

## Validation

- `kubectl kustomize` at 6 entry points: all succeeded
- `curl -I https://git.ninjatronics.io` -> HTTP/2 200 with Cloudflare headers
- Git working tree clean after deployment

## Remaining work

- Application-level setup: configure repositories/mirroring strategy
- Validate persistence and backup behavior

## Related notes

- [[Ninjatronics K3s Homelab]]
- [[Samson]]
- [[Kustomize ConfigMapGenerator Rollout Triggers]]
