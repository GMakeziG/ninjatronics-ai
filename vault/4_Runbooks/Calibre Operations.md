---
title: Calibre Operations
type: runbook
status: active
tags:
  - calibre
  - homelab
  - kubernetes
  - k3s
  - gitops
  - runbook
created: 2026-08-31
updated: 2026-08-31
---

# Calibre Operations

## Purpose

Operational procedures for the [[Calibre]] content server deployed in the
[[Ninjatronics K3s Homelab]]. Covers secrets provisioning, build and deploy,
health checks, backup/restore, upgrades, rollback, and troubleshooting.

## Preconditions

- kubectl access to the K3s cluster
- FluxCD reconciling the `lab` repository on `main`
- OpenBao access (`BAO_TOKEN`) for secret provisioning
- GHCR access (classic PAT with `write:packages`) for image publishing
- `export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"`

## Secrets provisioning

Store credentials in OpenBao; ESO syncs them into the cluster at runtime.
Never commit secret values to Git.

```bash
# Set the Calibre username and password in OpenBao
kubectl exec -n openbao openbao-0 -- env BAO_TOKEN="$BAO_TOKEN" \
  bao kv put secret/apps/calibre \
  username='<calibre-username>' \
  password='<strong-random-password>'
```

Verify metadata without reading secret values:

```bash
kubectl exec -n openbao openbao-0 -- env BAO_TOKEN="$BAO_TOKEN" \
  bao kv metadata get secret/apps/calibre
```

The ExternalSecret `calibre-secret` in the `calibre` namespace references
`ClusterSecretStore: openbao` and maps:

- `apps/calibre` property `username` -> Kubernetes Secret key `CALIBRE_USERNAME`
- `apps/calibre` property `password` -> Kubernetes Secret key `CALIBRE_PASSWORD`

## Build and publish the image

The custom Calibre image is built from `containers/calibre/` in the lab repo.

```bash
cd /home/gerso/src/lab
make -C containers/calibre build
```

The Makefile defaults to `ghcr.io/ninjatronics/calibre-server:9.14.0` — override
the correct owner:

```bash
make -C containers/calibre build IMAGE=ghcr.io/gmakezig/calibre-server
```

Push to GHCR (requires a classic PAT with `write:packages`):

```bash
echo "$GHCR_PAT" | docker login ghcr.io -u GMakeziG --password-stdin
docker push ghcr.io/gmakezig/calibre-server:9.14.0
```

Set the GHCR package to **public visibility** in the GitHub UI so that
Kubernetes can pull it anonymously without image pull secrets.

## Deploy via GitOps

Commit changes to `main` in the lab repo; Flux reconciles automatically.

```bash
flux reconcile source git flux-system
flux reconcile kustomization namespaces --with-source
flux reconcile kustomization apps --with-source
```

Observe the rollout:

```bash
kubectl get externalsecret,secret -n calibre
kubectl get deployment,pod,pvc,service,ingress -n calibre -o wide
kubectl rollout status deployment/calibre -n calibre --timeout=5m
```

The ExternalSecret must report Ready before the Deployment can start. The two
PVCs bind only when the pod is scheduled (local-path uses
`WaitForFirstConsumer`).

## Health and access

Public access:

```bash
curl -I https://calibre.ninjatronics.io
# Expect: HTTP 200 (web UI)
```

OPDS feed (requires auth):

```bash
curl -I https://calibre.ninjatronics.io/opds
# Expect: HTTP 401 (unauthenticated)
curl -u '<username>:<password>' https://calibre.ninjatronics.io/opds
# Expect: HTTP 200
```

In-cluster service check:

```bash
kubectl run calibre-check -n calibre --rm -i --restart=Never \
  --image=curlimages/curl -- \
  curl --fail --silent --show-error http://calibre:8080/
```

## Flux status

```bash
flux get kustomizations
flux logs --kind=Kustomization --name=apps -n flux-system
```

## Inspect failures

```bash
kubectl describe pod -n calibre -l app.kubernetes.io/name=calibre
kubectl logs -n calibre deployment/calibre
kubectl describe externalsecret calibre-secret -n calibre
```

## Backup

Back up both PVCs together while Calibre is stopped so the library database,
user database, and configuration are consistent.

1. Scale the deployment to zero via a temporary Git commit (set `replicas: 0`),
   commit, and let Flux reconcile. Do not use `kubectl scale` — Flux will revert
   it.

2. Archive `/config` and `/library` from a maintenance pod pinned to `niner`:

   ```bash
   kubectl run calibre-backup -n calibre --rm -i --restart=Never \
     --image=busybox --overrides='{"spec":{"nodeSelector":{"kubernetes.io/hostname":"niner"}}}' \
     -- sh -c 'tar czf /tmp/calibre-config.tar.gz /config && tar czf /tmp/calibre-library.tar.gz /library && cat /tmp/calibre-config.tar.gz /tmp/calibre-library.tar.gz' \
     > calibre-backup-$(date +%Y%m%d).tar.gz
   ```

   Or use `kubectl cp` against individual PVC-mounted paths from a maintenance
   pod.

3. Copy the archive to storage outside the cluster.

4. Restore the replica count via Git, commit, and let Flux reconcile.

## Restore

1. Scale the deployment to zero via Git (`replicas: 0`); let Flux reconcile.
2. Restore both archives to their existing PVCs with ownership `10001:10001`.
3. Restore the replica count via Git; let Flux reconcile.
4. Verify health and access.

Never delete or recreate the PVCs as a rollback mechanism: `local-path` reclaim
policy is `Delete`, which would destroy the data.

## Upgrade procedure

To upgrade Calibre to a new version:

1. Check the current stable release on the official Calibre site.
2. Update `CALIBRE_VERSION` and the SHA-256 of the official Calibre tarball in
   `containers/calibre/Dockerfile`.
3. Build and smoke-test the image locally:
   ```bash
   make -C containers/calibre build IMAGE=ghcr.io/gmakezig/calibre-server VERSION=<new-version>
   ```
4. Publish the new image to GHCR:
   ```bash
   docker push ghcr.io/gmakezig/calibre-server:<new-version>
   ```
5. Update the image tag and digest in
   `kubernetes/apps/base/calibre/deployment.yaml`.
6. Validate the base, production overlay, namespace aggregation, and cluster
   entrypoint with `kubectl kustomize`:
   ```bash
   kubectl kustomize kubernetes/apps/base/calibre | head
   kubectl kustomize kubernetes/apps/production/calibre | head
   kubectl kustomize kubernetes/namespaces
   kubectl kustomize kubernetes/clusters/production
   ```
7. Commit to `main`; let Flux reconcile.
8. Confirm the rollout and logs:
   ```bash
   kubectl rollout status deployment/calibre -n calibre --timeout=5m
   kubectl logs -n calibre deployment/calibre
   ```
9. Verify public access:
   ```bash
   curl -I https://calibre.ninjatronics.io
   ```

## Rollback procedure

1. Revert the Git commits that changed the image or manifests; Flux will
   reconcile the previous state.
2. Because the Deployment uses `Recreate`, expect a short outage during the
   rollback.
3. If the prior image was node-local (not in GHCR), confirm that exact tag is
   still present on `niner` before reverting.
4. A schema-incompatible Calibre downgrade may require restoring the
   coordinated `/config` and `/library` backup — do not delete or recreate
   either PVC.
5. Cloudflare DNS CNAME for `calibre.ninjatronics.io` is external to Git;
   manually delete in Cloudflare if full rollback is needed.
6. OpenBao `secret/apps/calibre` is not managed by Git; manually delete with
   `bao kv delete secret/apps/calibre` if full cleanup is needed.

## Troubleshooting

### Pod stuck in Pending

- Check PVC binding: `kubectl get pvc -n calibre`
- `local-path` uses `WaitForFirstConsumer` — PVCs bind only when the pod is
  scheduled. Confirm the pod is pinned to `niner` and `niner` is Ready.
- Check node disk space on `niner`.

### ExternalSecret not Ready

- `kubectl describe externalsecret calibre-secret -n calibre`
- Verify OpenBao is running: `kubectl get pods -n openbao`
- Verify the `openbao` ClusterSecretStore: `kubectl get clustersecretstore openbao`
- Verify OpenBao KV path exists: `bao kv metadata get secret/apps/calibre`
- Force re-sync: `kubectl annotate externalsecret calibre-secret -n calibre force-sync="$(date +%s)" --overwrite`

### ImagePullBackOff

- Confirm the GHCR package is set to **public** visibility.
- Confirm the image owner is `gmakezig` (not `ninjatronics`):
  `ghcr.io/gmakezig/calibre-server`.
- Confirm the digest in the deployment matches the published image.

### Restart after secret change

```bash
kubectl rollout restart deployment/calibre -n calibre
kubectl rollout status deployment/calibre -n calibre
```

### Cloudflared tunnel not routing

- Check the cloudflared config includes the `calibre.ninjatronics.io` route.
- The cloudflared pod auto-rolls via Kustomize `configMapGenerator` hash when
  the tunnel config changes — no manual restart needed.
- Verify Cloudflare DNS CNAME points to the correct tunnel ID.

## Known issues

- `local-path` does not support volume expansion; PVC sizes are fixed at
  creation.
- No NetworkPolicy is applied to the Calibre namespace (Sentinel backlog).
- `automountServiceAccountToken` is not set to `false` (Sentinel backlog).
- `readOnlyRootFilesystem` has not been evaluated (Sentinel backlog).
- No backup automation for PVC data.

## Gotchas

- The GHCR owner is `GMakeziG`, not `ninjatronics`. The Makefile and
  `docs/calibre-runbook.md` in the repo still reference the old owner — override
  `IMAGE` when building.
- The `docs/calibre-runbook.md` in the repo is outdated (references
  `calibre.internal` and `ghcr.io/ninjatronics/`); this vault note is the
  current source of truth for the production deployment.
- Publishing to GHCR requires a **classic** PAT with `write:packages`. Fine-grained
  PATs may not work for GHCR.
- The entrypoint unsets `CALIBRE_USERNAME` and `CALIBRE_PASSWORD` after
  configuring the user, so the credentials are not visible in the process
  environment after startup.

## References

- Lab repo: `/home/gerso/src/lab`
- Container build: `containers/calibre/Dockerfile`
- Repo runbook (outdated): `docs/calibre-runbook.md`
- Flux homelab app onboarding skill: `flux-homelab-app-onboarding`

## Related notes

- [[Calibre]]
- [[Ninjatronics K3s Homelab]]
- [[Kustomize ConfigMapGenerator Rollout Triggers]]
