---
title: Wallabag
type: system
status: active
tags:
  - wallabag
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

# Wallabag

## Overview

Self-hosted read-it-later application for saving and archiving web articles.
Deployed in the [[Ninjatronics K3s Homelab]], fully GitOps managed through Flux.

- **Public URL:** https://wallabag.ninjatronics.io
- **Namespace:** `wallabag`
- **Status:** Deployed and publicly reachable (HTTP/2 302 → /login)

## Version

- **Wallabag application:** 2.6.14 (latest stable, October 2025)
- **Wallabag image:** `wallabag/wallabag:2.6.14@sha256:4a527e027e0d59e87c14225ef11e005af3d4890374202ad319ce5e63dfc66709`
- **PostgreSQL:** 17.11-alpine (same major as [[Forgejo]])

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
Wallabag Ingress (wallabag.ninjatronics.io)
  |
Wallabag (namespace: wallabag, port 80)
  |
PostgreSQL (namespace: wallabag, port 5432)
```

Both Wallabag and PostgreSQL are pinned to **niner** because the cluster
uses `local-path` storage (`ReadWriteOnce`), which is node-local. Same
pattern as [[Forgejo]].

### Image architecture

The Wallabag Docker image runs as **root** by design. It uses s6-svscan to
supervise nginx (port 80) and php-fpm. The entrypoint (`/entrypoint.sh`)
creates the database and user via `psql`, runs `wallabag:install` to create
the schema, then starts the web server.

Non-root execution is not supported by this image — s6-svscan requires root,
and nginx needs root or `CAP_NET_BIND_SERVICE` to bind port 80. The
container security context sets `allowPrivilegeEscalation: false` but does
not set `runAsNonRoot` or `capabilities.drop: [ALL]`.

### PostgreSQL 15+ schema privilege fix

PostgreSQL 15+ revoked `CREATE` on the `public` schema from non-superusers.
The Wallabag entrypoint creates the database and user, then runs
`wallabag:install` which connects as `SYMFONY__ENV__DATABASE_USER` and needs
`CREATE` on `public` to create the `migration_versions` table.

**Fix:** `POSTGRES_USER=wallabag` so the PostgreSQL superuser IS the
Wallabag app user. This gives it ownership of the `wallabag` database and
`CREATE` on the `public` schema. `POSTGRES_DB=postgres` (not `wallabag`) so
the Wallabag entrypoint sees the `wallabag` database does not yet exist,
creates it, and runs `wallabag:install` as the superuser. `PGDATABASE=postgres`
is also set so the entrypoint's `psql` calls connect to the `postgres`
maintenance database by default (without this, psql defaults to the
`wallabag` database, which does not exist yet at first boot).

Both `POSTGRES_PASSWORD` and `SYMFONY__ENV__DATABASE_PASSWORD` use the same
OpenBao property (`database-password`) because they authenticate the same
PostgreSQL role.

## Storage

| Resource                | Size | StorageClass | Node   |
|-------------------------|------|--------------|--------|
| `wallabag-images`       | 2 Gi | local-path   | niner  |
| `wallabag-data`         | 2 Gi | local-path   | niner  |
| `wallabag-postgres-data`| 10 Gi| local-path   | niner  |

- `wallabag-images`: `/var/www/wallabag/web/assets/images` — user-uploaded images
- `wallabag-data`: `/var/www/wallabag/data` — Wallabag data directory
- `wallabag-postgres-data`: `/var/lib/postgresql/data` — PostgreSQL data

`local-path` does not support volume expansion; sizes are fixed at creation.

## Services

| Service              | Type       | Port |
|----------------------|------------|------|
| `wallabag`           | ClusterIP | 80   |
| `wallabag-postgres`  | ClusterIP | 5432 |

No NodePort, LoadBalancer, or hostPort exposure.

## Secrets

Secrets are stored in [[OpenBao]] and populated by External Secrets
Operator. No real secret values are in Git.

- **OpenBao path:** `secret/apps/wallabag`
- **ESO remote reference:** `apps/wallabag`

Properties and Kubernetes Secret key mappings:

| OpenBao             | Kubernetes Secret key                  | Used by              |
|---------------------|----------------------------------------|----------------------|
| `database-password` | `POSTGRES_PASSWORD`                    | PostgreSQL (superuser) |
| `database-password` | `SYMFONY__ENV__DATABASE_PASSWORD`      | Wallabag (same user)   |
| `secret`            | `SYMFONY__ENV__SECRET`                  | Wallabag (Symfony secret) |

Note: `POSTGRES_PASSWORD` and `SYMFONY__ENV__DATABASE_PASSWORD` use the same
OpenBao property because the PostgreSQL superuser IS the Wallabag app user
(`POSTGRES_USER=wallabag`). The `postgres-password` OpenBao property is not
used in this architecture.

OpenBao KV v2 policy:

```hcl
path "secret/data/apps/wallabag" {
  capabilities = ["read"]
}

path "secret/metadata/apps/wallabag" {
  capabilities = ["read"]
}
```

A `secret.example.yaml` with placeholders only is retained in the repo
for documentation/reference.

## Configuration

Non-secret environment is in a ConfigMap (`wallabag-config`), consumed via
`envFrom`. Secret environment is in `wallabag-secret`, also via `envFrom`.

Key settings:

- `SYMFONY__ENV__DATABASE_DRIVER=pdo_pgsql`
- `SYMFONY__ENV__FOSUSER_REGISTRATION=false` — public registration disabled
- `SYMFONY__ENV__FOSUSER_CONFIRMATION=false` — email confirmation disabled (no SMTP)
- `SYMFONY__ENV__DOMAIN_NAME=https://wallabag.ninjatronics.io`
- `SYMFONY__ENV__MAILER_DSN=smtp://127.0.0.1` — placeholder (no SMTP server configured)
- `POSTGRES_USER=wallabag`, `POSTGRES_DB=postgres`, `PGDATABASE=postgres`
- `POPULATE_DATABASE=True`

Redis is not included (optional for async import workers). SMTP is not
configured (password reset and email 2FA will not work).

## Probes

- **Readiness:** HTTP GET `/api/info` (port 80), `initialDelaySeconds: 30`
- **Liveness:** HTTP GET `/api/info` (port 80), `initialDelaySeconds: 60`

`/api/info` returns `{"appname":"wallabag","version":"2.6.14","allowed_registration":false}`
with HTTP 200 when the app is ready.

## GitOps file structure

```
kubernetes/apps/base/wallabag/
├── configmap.yaml
├── deployment.yaml
├── kustomization.yaml
├── postgres-deployment.yaml
├── postgres-pvc.yaml
├── postgres-service.yaml
├── pvc-data.yaml
├── pvc-images.yaml
├── secret.example.yaml
└── service.yaml

kubernetes/apps/production/wallabag/
├── external-secrets/
│   ├── kustomization.yaml
│   └── wallabag-secret.yaml
├── ingress.yaml
└── kustomization.yaml
```

Additional files touched:

- `kubernetes/apps/production/kustomization.yaml`
- `kubernetes/infrastructure/base/cloudflared/config.yaml`
- `kubernetes/namespaces/wallabag.yaml`
- `kubernetes/namespaces/kustomization.yaml`

## Design requirements

- Fully GitOps managed through Flux
- Public access through Cloudflare Tunnel
- Traefik handles Kubernetes ingress
- TLS via cert-manager + Let's Encrypt (`letsencrypt-production-cloudflare`)
- No public NodePort or LoadBalancer
- Secrets in OpenBao via External Secrets Operator
- Persistent storage through local-path
- Wallabag and PostgreSQL colocated on niner
- Public registration disabled
- No `latest` image tags; digest-pinned

## Validation

- `kubectl kustomize` at all affected layers: succeeded
- `flux diff kustomization apps`: accepted by API server
- `kubectl get pods -n wallabag`: both pods 1/1 Running
- `kubectl get pvc -n wallabag`: all 3 PVCs Bound
- `kubectl get externalsecret -n wallabag`: SecretSynced, all keys present
- `kubectl get certificate -n wallabag`: Ready (True)
- `kubectl exec ... psql -U wallabag -d wallabag -c "SELECT count(*) FROM pg_tables WHERE schemaname='public'"`: 16 tables
- `/api/info` returns `{"appname":"wallabag","version":"2.6.14","allowed_registration":false}`
- Persistence: pod restart confirmed data survives; `wallabag:install` does not re-run
- `curl -I https://wallabag.ninjatronics.io`: HTTP/2 302 → /login
- `curl -s https://wallabag.ninjatronics.io/api/info`: 200 with correct JSON
- Cloudflared pod auto-rolled via configMapGenerator hash on tunnel config change

## First-boot behavior

The Wallabag entrypoint:
1. Waits for the PostgreSQL port to be reachable (`nc -z`)
2. Checks if the `wallabag` database exists (via `psql` connected to the `postgres` database using `PGDATABASE=postgres`)
3. If the database does not exist: creates it, checks if the `wallabag` user exists (it does — it IS the superuser), skips `CREATE ROLE`, and runs `wallabag:install`
4. If the database already exists: prints "WARN: Postgres database is already configured" and skips `wallabag:install`
5. Runs `composer install` and starts s6-svscan (nginx + php-fpm)

On subsequent pod restarts: the database already exists, so `wallabag:install`
is skipped. The app starts directly from the existing data on the PVCs.

## Upgrade procedure

To upgrade Wallabag to a new version:

1. Update the image tag and digest in `deployment.yaml`
2. Commit and push to main
3. Wait for Flux to reconcile
4. Run migrations manually:
   ```bash
   kubectl exec -n wallabag <wallabag-pod> -- /var/www/wallabag/bin/console doctrine:migrations:migrate --env=prod --no-interaction
   ```

## Rollback

1. Revert the Git commits; Flux will prune the resources
2. PVCs are `local-path` with reclaim `Delete` — reverting deletes app data
3. Back up PostgreSQL before reverting:
   ```bash
   kubectl exec -n wallabag <postgres-pod> -- pg_dump -U wallabag -d wallabag -F c -f /tmp/wallabag-backup.dump
   kubectl cp -n wallabag <postgres-pod>:/tmp/wallabag-backup.dump ./wallabag-backup.dump
   ```
4. OpenBao `secret/apps/wallabag` is not managed by Git; manually delete with `bao kv delete secret/apps/wallabag` if full cleanup is needed
5. Cloudflare DNS CNAME for `wallabag.ninjatronics.io` is external to Git; manually delete in Cloudflare if full rollback is needed

## Remaining work

- SMTP is not configured; password reset and email 2FA are unavailable
- Redis is not deployed; async article imports run synchronously
- No backup automation for PostgreSQL data

## Related notes

- [[Ninjatronics K3s Homelab]]
- [[Forgejo]]
- [[Kustomize ConfigMapGenerator Rollout Triggers]]
