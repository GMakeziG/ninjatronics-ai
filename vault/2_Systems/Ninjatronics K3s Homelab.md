---
title: Ninjatronics K3s Homelab
type: system
status: active
tags:
  - homelab
  - kubernetes
  - k3s
  - gitops
  - flux
  - cloudflare
  - openbao
  - external-secrets
created: 2026-08-30
updated: 2026-08-31
---

# Ninjatronics K3s Homelab

## Overview

Self-hosted Kubernetes homelab running K3s, managed declaratively through
GitOps (FluxCD + Kustomize + Helm). Public exposure is through Cloudflare
Tunnels only — no NodePorts, LoadBalancers, or hostPorts are exposed
directly.

## Cluster topology

| Node     | Role           | Notes                                          |
|----------|----------------|------------------------------------------------|
| Zion     | Primary GitOps host | Flux source controller, management node |
| Niner    | Worker         | Local-path persistent storage; Forgejo + PostgreSQL pinned here |
| Samson   | Worker         | cloudflared pod runs here; Tailscale node      |

## Storage

- **StorageClass:** `local-path`
- **AccessMode:** `ReadWriteOnce`
- Storage is node-local — a pod scheduled on node N can only access PVCs
  on node N.
- **Implication:** Workloads that share data (e.g. Forgejo + its
  PostgreSQL) must be pinned to the same node via `nodeSelector` or
  `nodeAffinity` to prevent scheduling onto a node where their local
  volumes don't exist.

## Networking

- All Kubernetes Services remain **ClusterIP**.
- No NodePort, LoadBalancer, hostPort, hostNetwork, or externalIPs.
- **Public traffic path:**

```
Internet -> Cloudflare -> Cloudflare Tunnel (homelab-k3s) -> cloudflared
(namespace: platform) -> Traefik (Ingress) -> Service -> Pod
```

- Cloudflare DNS/Tunnel routing uses the existing `homelab-k3s` tunnel.
- LAN DNS resolver: `10.99.0.1`
- Split DNS route for `ninjatronics.home.arpa` -> `10.99.0.240` (via
  Tailscale, but see [[Samson]] for the DNS management issue).

## GitOps

- **FluxCD** reconciles the cluster from Git.
- **Kustomize** for manifest composition and overlays (base/production).
- **Helm** charts managed through `HelmRelease` + `HelmRepository`.
- Infrastructure applications (cloudflared, etc.) live under
  `kubernetes/infrastructure/`. Application manifests live under
  `kubernetes/apps/`.

## Secrets

- **OpenBao** (Vault-compatible) stores all secrets outside Git.
- **External Secrets Operator** populates Kubernetes Secrets from OpenBao.
- **Policy pattern:** OpenBao KV v2 with read access on
  `secret/data/apps/<name>` and `secret/metadata/apps/<name>`.
- `secret.example.yaml` files with placeholders only are retained for
  documentation/reference. No real secret values are committed to Git.

## Deployed applications

- [[Forgejo]] — self-hosted Git, `git.ninjatronics.io`
- [[Wallabag]] — read-it-later, `wallabag.ninjatronics.io`
- [[Calibre]] — ebook content server, `calibre.ninjatronics.io`
- cloudflared — Cloudflare Tunnel daemon (namespace: platform)
- Other services: draw, draw-test, linkding, qr, grafana, audiobookshelf,
  n8n (all via cloudflared routes)

## Known issues

- [[Samson]] had a Tailscale DNS incident (SERVFAIL) that caused
  ImagePullBackOff. Tailscale DNS management is intentionally disabled
  on Samson until a proper upstream resolver is configured. See
  [[Tailscale DNS SERVFAIL on Kubernetes Nodes]].

## Related notes

- [[Forgejo]]
- [[Samson]]
- [[Tailscale DNS SERVFAIL on Kubernetes Nodes]]
- [[Kustomize ConfigMapGenerator Rollout Triggers]]
