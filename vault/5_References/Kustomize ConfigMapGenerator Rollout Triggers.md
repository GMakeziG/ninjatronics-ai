---
title: Kustomize ConfigMapGenerator Rollout Triggers
type: reference
status: active
tags:
  - gitops
  - flux
  - kustomize
  - kubernetes
  - configmap
  - deployment
created: 2026-08-30
updated: 2026-08-30
---

# Kustomize ConfigMapGenerator Rollout Triggers

## Problem

Updating a ConfigMap through Flux does not inherently restart the
consuming application. If the application does not hot-reload its
configuration, the Deployment pod template must change to trigger a
rollout — but a ConfigMap update alone does not change the pod template.

Manual `kubectl rollout restart` is not durable GitOps: Flux reconciles
the resulting annotation away because it is not represented in Git.

## Solution

Use Kustomize `configMapGenerator` with content hashing.

### How it works

1. Put the raw configuration in a file (e.g. `config.yaml`).
2. In `kustomization.yaml`, use `configMapGenerator` instead of a static
   ConfigMap:
   ```yaml
   configMapGenerator:
     - name: cloudflared-config
       files:
         - config.yaml
   ```
3. The Deployment references the logical name (e.g. `cloudflared-config`).
4. Kustomize generates a content hash and appends it to the ConfigMap name
   (e.g. `cloudflared-config-tt7c4hcgb8`).
5. Kustomize rewrites the Deployment's volume reference to match.

### Rollout trigger chain

```
config.yaml changes
  -> Kustomize calculates different content hash
  -> new ConfigMap name generated
  -> Deployment volume reference changes (rewritten by Kustomize)
  -> Deployment pod template changes
  -> Flux applies Deployment change
  -> Kubernetes automatically rolls the pod
  -> new pod starts with new configuration loaded
```

No `kubectl rollout restart` or manual pod deletion is required. The
configuration change itself is the declarative rollout trigger.

## Verification

### Confirm hash is deterministic

1. `kubectl kustomize <path>` and note the generated ConfigMap name.
2. Temporarily modify `config.yaml`.
3. `kubectl kustomize <path>` again — the hash should change.
4. Revert the modification.
5. `kubectl kustomize <path>` — the hash should return to the original.

### Confirm Deployment references the hashed name

```bash
kubectl kustomize <path> | grep cloudflared-config
```

The Deployment volume reference should match the generated ConfigMap name
exactly.

### Confirm production rollout

```bash
kubectl rollout status deployment/cloudflared -n platform --timeout=120s
# deployment "cloudflared" successfully rolled out
```

## When to use

- Applications that read configuration at startup and do not hot-reload
  (cloudflared, many DaemonSets, etc.)
- Any GitOps-managed workload where ConfigMap updates should trigger
  automatic rollouts
- Any case where `kubectl rollout restart` would otherwise be needed but
  is not durable under Flux

## What NOT to do

- Do NOT use `kubectl rollout restart` as permanent GitOps state. Flux
  may reconcile the mutation away.
- Do NOT hardcode the generated hash in manifests. Kustomize rewrites
  the reference automatically.
- Do NOT use a static ConfigMap when the consuming application does not
  hot-reload. Use `configMapGenerator` instead.

## Related patterns

- **Image pinning:** Pin infrastructure images to
  `specific-version@sha256:digest` instead of `:latest`. This prevents
  an unrelated image update from being introduced during a restart and
  improves GitOps reproducibility.
- **Node-local storage scheduling:** When using `local-path` storage
  (`ReadWriteOnce`), pin workloads that share data to the same node via
  `nodeSelector` or `nodeAffinity`.

## Related notes

- [[Forgejo]]
- [[Ninjatronics K3s Homelab]]
- [[Tailscale DNS SERVFAIL on Kubernetes Nodes]]
