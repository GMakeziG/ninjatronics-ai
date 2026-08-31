<<<RESULT:LAB-CAL-SHI-002>>>
# Specialist Handoff

## Assignment ID

LAB-CAL-SHI-002

## Status

Blocked

Implementation and local validation are complete. Live deployment is blocked by image distribution and OpenBao credentials.

## Objective

Implement an internal-only Calibre GitOps deployment using a Ninjatronics-owned minimal image, Flux-compatible manifests, authentication, and persistent local-path storage.

## Scope reviewed

- Nova continuation handoff
- Audiobookshelf base pattern
- Wallabag production/ESO pattern
- Namespace and production aggregation layers
- Existing cert-manager issuers
- k3s nodes, OpenBao, and ESO status

No cloudflared or infrastructure files were changed.

## Assumptions

- `calibre.internal` will be resolved through the homelab’s internal DNS or client hosts configuration.
- The self-signed `lab-selfsigned` issuer is appropriate because public ACME issuers cannot issue certificates for `.internal`.
- The image will eventually be loaded on `niner` or published to GHCR.
- Linuxbrew did not contain `kubectl`; after exporting the required PATH, resolution fell through to `/usr/local/bin/kubectl`.

## Work performed

- Built a Debian trixie-slim Calibre 9.14.0 image.
- Pinned the Debian base by digest.
- Verified the official Calibre archive using SHA-256 during build.
- Removed desktop launchers and XCB/Wayland platform plugins.
- Added non-root UID/GID `10001:10001`.
- Added idempotent library and authenticated-user database initialization.
- Created base and production Kustomize structures.
- Added two local-path RWO PVCs.
- Added ESO integration for `secret/apps/calibre`.
- Added internal Traefik ingress with self-signed TLS.
- Added namespace and production aggregation.
- Documented OpenBao and node-local image import commands.
- Created the requested local Git commit without pushing.

## Findings

- The image runs headlessly with only `calibre-server` as PID 1.
- Digest authentication works: anonymous and invalid credentials return HTTP 401; valid credentials return HTTP 200.
- Persistent library metadata survived container deletion and recreation with an identical SHA-256.
- The official Calibre server imports `PyQt6.QtGui` for cover processing. Consequently, minimal `libX11`, GLVND, fontconfig, and keyboard ABI libraries are unavoidable. No X server, Wayland server, desktop, VNC, terminal service, or display plugin is installed.
- GHCR rejected the push with `denied`.
- SSH access to `niner` stopped at host-key verification, so the image could not be loaded into its k3s containerd.
- OpenBao is healthy and unsealed, but no authenticated local `bao` session/token was available.

## Deliverables

Image sources:

- [Dockerfile](/home/gerso/src/lab/containers/calibre/Dockerfile)
- [entrypoint.sh](/home/gerso/src/lab/containers/calibre/entrypoint.sh)
- [Makefile](/home/gerso/src/lab/containers/calibre/Makefile)
- [image README](/home/gerso/src/lab/containers/calibre/README.md)

Kubernetes:

- [base manifests](/home/gerso/src/lab/kubernetes/apps/base/calibre/kustomization.yaml)
- [production overlay](/home/gerso/src/lab/kubernetes/apps/production/calibre/kustomization.yaml)
- [ExternalSecret](/home/gerso/src/lab/kubernetes/apps/production/calibre/external-secrets/calibre-secret.yaml)
- [internal ingress](/home/gerso/src/lab/kubernetes/apps/production/calibre/ingress.yaml)
- [operator instructions](/home/gerso/src/lab/kubernetes/apps/production/calibre/README.md)
- [namespace](/home/gerso/src/lab/kubernetes/namespaces/calibre.yaml)

## Validation

Kustomize:

```text
kubernetes/apps/base/calibre: OK (5 resources)
kubernetes/apps/production/calibre: OK (7 resources)
kubernetes/namespaces: OK (13 resources)
kubernetes/apps/production: OK (79 resources)
```

Image/runtime:

```text
calibre-server (calibre 9.14)
user=10001
group=10001
desktop_display_stack=absent
```

Authentication:

```text
container_status=running
anonymous_opds=401
valid_digest_opds=200
invalid_digest_opds=401
pid1=/opt/calibre/bin/calibre-server --listen-on 0.0.0.0 --port 8080 --enable-auth --userdb /config/users.sqlite /library
identity=uid=10001(calibre) gid=10001(calibre) groups=10001(calibre)
```

Persistence across container recreation:

```text
recreated_container_status=running
recreated_valid_digest_opds=200
metadata_before_recreation=473e1b82ea7e62bdcb776b463600e0df968b0300e77c66f75652ddd88e0f0d74
metadata_after_recreation=473e1b82ea7e62bdcb776b463600e0df968b0300e77c66f75652ddd88e0f0d74
persistence_hash_match=true
```

Cluster accessibility:

```text
niner Ready
samson Ready
zion Ready
ClusterSecretStore/openbao Ready=True
openbao-0 Running, initialized=true, sealed=false
```

No `kubectl apply` or Git push was performed.

## Evidence

Artifact pins:

```text
Debian: sha256:d7e12182ce18b85b93007c1dedf31f2d29e01ccf3182cc4017c709b6259bc132
Calibre 9.14.0: 7f53a0863ed6d32407bc72053b966e39d5b64813f2592bd9c741504c01c0e7f3
```

Image push:

```text
docker push ghcr.io/ninjatronics/calibre-server:9.14.0
error from registry: denied
```

Node import attempt:

```text
ssh niner ...
Host key verification failed.
```

Commit:

```text
4db154a feat(calibre): add internal GitOps deployment
```

The worktree was clean after the commit.

## Risks

- The image currently exists only in local Docker storage and is not available to `niner`.
- The Deployment uses the version tag with `IfNotPresent`; after GHCR publication it should be pinned to the published manifest digest.
- Minimal X11 client ABI libraries remain because the official headless server cannot import QtGui without them.
- Calibre’s user-management CLI requires the password as a transient command argument during startup.
- `calibre.internal` requires internal name resolution and clients must trust the self-signed certificate.
- The existing production aggregate emits an unrelated deprecated `patchesStrategicMerge` warning.

## Outstanding work

1. Distribute the image:

```sh
docker save ghcr.io/ninjatronics/calibre-server:9.14.0 |
  ssh niner sudo k3s ctr images import -
```

Alternatively authenticate Docker to GHCR, push the image, and pin the resulting registry digest.

2. Create the OpenBao secret using the commands documented in [production README](/home/gerso/src/lab/kubernetes/apps/production/calibre/README.md).

3. Have Nova review and push commit `4db154a`.

4. After Flux reconciliation, collect live evidence:

```sh
kubectl get pods,pvc,ingress -n calibre -o wide
kubectl logs -n calibre deployment/calibre
kubectl delete pod -n calibre -l app.kubernetes.io/name=calibre
kubectl rollout status -n calibre deployment/calibre
```

5. Verify live authentication and PVC persistence after Flux deploys the workload.

## Escalations

- Nova/Gerso must provide GHCR write access or approve/fix SSH trust for loading the image onto `niner`.
- Gerso must create the OpenBao credentials.
- Nova/Sentinel should explicitly accept the unavoidable minimal `libX11` ABI dependency in the official Calibre binary.

## Recommended next owner

Sentinel (LAB-CAL-SEN-002)

<<<END:LAB-CAL-SHI-002>>>