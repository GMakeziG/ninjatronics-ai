# LAB-ABS-ARC-001 — Merge & Cutover Evidence Checklist

Status: Complete with findings
Assignment: Merge and cutover evidence for Audiobookshelf PR #6
Repository: `GMakeziG/lab`
Review mode: Independent, read-only
Review branch: `feat/audiobookshelf`
Observed branch tip: `5b2d6f51343d1b04a63fbcb4fdfd382980bdfa8d`
Prepared by: Archivist
Prepared: 2026-07-28

## Purpose and use

This checklist is the controlled evidence record for PR #6, from pre-merge approval through first production validation. Every checked item must retain the command output, UTC timestamp, operator, and relevant resource names. A rendered manifest or successful Kustomize build is not evidence that the live workload is healthy; post-merge checks must be run against the cluster after Flux has applied the revision.

Do not print, paste, or retain secret values. Credential checks below retain hashes and status only.

Owners:

- Gerso: human acceptance, merge authorization, initial Audiobookshelf administrator claim.
- Shinobi / platform operator: Flux, Kubernetes, storage, tunnel, and runtime validation.
- Sentinel: security-risk disposition and review of residual security findings.
- Archivist: evidence collection, documentation consistency, and final record.

## Evidence conventions

For each check retain:

- UTC timestamp: `date -u +%Y-%m-%dT%H:%M:%SZ`
- Exact command and exit code.
- Resource name, namespace, revision, UID, or certificate serial/details where applicable.
- Terminal output or an approved screenshot for UI-only actions.
- Log excerpts with credentials, tokens, cookies, and secret payloads redacted.

Suggested evidence directory outside the GitOps repository: the assignment handoff directory or the organization's approved evidence store. Do not commit runtime evidence, decrypted credentials, library media, or private keys to Git.

# 1. Pre-merge gates

## 1.1 PR identity and branch state

- [x] Owner: Archivist. PR #6 metadata independently checked through the public GitHub API because local `gh` is unauthenticated.

Command:

```bash
python3 -c 'import json,urllib.request; u="https://api.github.com/repos/GMakeziG/lab/pulls/6"; r=urllib.request.Request(u,headers={"Accept":"application/vnd.github+json","User-Agent":"archivist"}); d=json.load(urllib.request.urlopen(r)); print({k:d.get(k) for k in ("number","state","draft","mergeable","mergeable_state","commits","changed_files","base","head")})'
```

Expected output / acceptance:

- `number: 6`
- `state: open`
- `draft: true` until Gerso marks it ready.
- `base.ref: main`
- `head.ref: feat/audiobookshelf`
- `head.sha: 5b2d6f51343d1b04a63fbcb4fdfd382980bdfa8d`
- `mergeable: true`, `mergeable_state: clean`
- `commits: 9`
- `changed_files: 16`

Retain: API response, timestamp, PR URL, head SHA, base SHA, commit count, changed-file count, and the fact that public API fallback was used. Do not infer that `merge_commit_sha` is the final merge commit before the merge occurs.

Observed: all requested values matched. GitHub's API currently reports candidate `merge_commit_sha` `eee286444a77db85dcf0ac0280d57a9a25e73575`; verify the actual commit after merge rather than treating this pre-merge value as final.

- [x] Owner: Archivist. Working tree is clean.

```bash
git status --short
```

Expected: no output; exit code 0.

Observed: clean.

- [x] Owner: Archivist. Local branch tip and commit count match the review target.

```bash
git branch --show-current
git rev-parse HEAD
git rev-list --count origin/main..HEAD
git diff --name-only origin/main...HEAD | wc -l
git diff --check
```

Expected: `feat/audiobookshelf`; head `5b2d6f51343d1b04a63fbcb4fdfd382980bdfa8d`; count `9`; changed-file count `16`; `git diff --check` exit code 0.

Retain: output and timestamp.

## 1.2 Offline build gates

- [x] Owner: Shinobi / Archivist. All three required builds pass.

```bash
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
kubectl kustomize kubernetes/apps/base/audiobookshelf
kubectl kustomize kubernetes/apps/production/audiobookshelf
kubectl kustomize kubernetes/apps/production
```

Expected: each command exits 0. The production build may emit the existing non-blocking deprecation warning for `patchesStrategicMerge`; warnings are retained and do not change the exit code.

Observed:

- Base: exit 0.
- Production Audiobookshelf overlay: exit 0.
- Production aggregate: exit 0, with existing `patchesStrategicMerge` deprecation warning.

Retain: command transcript, exit codes, timestamp, and rendered-output checksum if the output is archived. Do not archive decrypted secret output.

## 1.3 SOPS/live credential parity

- [x] Owner: Sentinel / Archivist evidence. Sentinel reported normalized credential SHA-256 parity without exposing the credential:

`d4f25a1185ab17289020cbc9c39ba36273a389a328fab268f00e537e08a00507` — committed SOPS credential.

`d4f25a1185ab17289020cbc9c39ba36273a389a328fab268f00e537e08a00507` — live `platform/cloudflared-tunnel-credentials` credential.

Result: MATCH. This proves adoption of the existing shared tunnel identity, not an intentional rotation.

Safe hash-only verification command for an operator with the age identity:

```bash
export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
sops -d kubernetes/bootstrap-secrets/cloudflared-tunnel-credentials.enc.yaml \
  | yq -r '.data["credentials.json"]' \
  | base64 -d | jq -cS . | sha256sum
kubectl -n platform get secret cloudflared-tunnel-credentials \
  -o jsonpath='{.data.credentials\.json}' \
  | base64 -d | jq -cS . | sha256sum
```

Expected: two identical SHA-256 lines, with the expected value above; no credential JSON printed. If `sops` cannot load the age identity, record the failure and rely only on the independently verified Sentinel artifact; do not weaken the gate.

Observed in this review: live hash matched the expected value. Local SOPS decryption was unavailable because the review shell did not have the age identity. Sentinel's independently completed review verified both sides and recorded MATCH.

Retain: two hashes, command exit codes, timestamp, operator, and Sentinel result path. Never retain decrypted output.

## 1.4 DNS and pre-cutover HTTP state

- [x] Owner: Archivist. Public DNS exists and the expected pre-reconcile response is 404.

```bash
dig +short audiobookshelf.ninjatronics.io A
dig +short audiobookshelf.ninjatronics.io AAAA
curl -sS -I --max-time 20 https://audiobookshelf.ninjatronics.io -w 'HTTP_STATUS=%{http_code}\n'
```

Expected before merge/reconcile: Cloudflare A/AAAA edge addresses; HTTP 404 from Cloudflare/Traefik because the `main`-tracking cluster does not yet contain the Audiobookshelf Ingress/tunnel route. A 404 is expected now and is not post-cutover acceptance.

Observed: A `172.67.193.72`, `104.21.11.247`; AAAA `2606:4700:3031::ac43:c148`, `2606:4700:3033::6815:bf7`; HTTPS 404.

Retain: timestamp, resolver output, HTTP headers/status, Cloudflare Ray ID when present, and a screenshot only if required by the evidence system.

## 1.5 Sentinel verdict and human risk acceptance

- [x] Owner: Sentinel. Independent artifact `.../shared/handoffs/LAB-ABS-SEN-001/result.md` reports **PASS WITH NOTES**, with no Blocker or High findings.

Required recorded findings:

- Medium: `local-path` RWO volumes are node-affine; StorageClass reclaim policy is `Delete`; Flux apps pruning and whole-feature rollback can cause data loss or outage. Runtime UID/GID write access and recovery are not proven pre-merge.
- Low: `readOnlyRootFilesystem` is not enabled and no NetworkPolicy accompanies the workload.
- Resolved documentation finding: DNS now resolves, PR #6 exists, and pre-reconcile HTTPS 404 is expected. The runbook's pre-cutover section was updated accordingly.
- Credential hash parity is MATCH as recorded in section 1.3.

- [ ] Owner: Gerso. Human acceptance of the local-path/recovery risk is required before merge.

Acceptance statement to sign: “I accept the documented node-affinity, `ReclaimPolicy=Delete`, prune, and recovery risks for this Audiobookshelf deployment, and I require backup/restore evidence before real production library data is considered protected.”

Retain: signed approval or PR review reference, timestamp, and the Sentinel result artifact path.

# 2. Merge controls

- [ ] Owner: Gerso. Mark PR #6 Ready for review only after the pre-merge gates above are complete and the residual storage risk is explicitly accepted.
- [ ] Owner: Gerso / reviewer. Obtain human approval. Automated `mergeable=true` is not a substitute for human acceptance.
- [ ] Owner: Gerso. Recommended merge strategy: a normal merge commit, preserving the nine reviewed commits and the feature's audit trail. Do not squash away the documentation and evidence history unless the project owner explicitly chooses that alternative and records it.

If authenticated and authorized, the intended control is equivalent to:

```bash
gh pr merge 6 --merge --delete-branch=false
```

Do not execute this command as part of this read-only assignment. If the repository policy requires a different strategy, record the policy and the approved alternative before merging.

- [ ] Owner: Archivist. After merge, verify the actual merge commit and that `main` contains the reviewed head.

```bash
git fetch origin main
git rev-parse origin/main
git show --no-patch --format=fuller origin/main
```

Expected: `origin/main` is the actual merge commit; its first-parent history includes PR #6 and the merged tree contains the reviewed Audiobookshelf files. If GitHub performs a different merge strategy, record the actual SHA and strategy in the acceptance record.

- [ ] Owner: Gerso. Do not perform a whole-feature rollback after PVCs contain data. A later rollback must preserve the four PVC objects/data and the shared `platform/cloudflared-tunnel-credentials` Secret. Feature-branch cleanup is permitted only after merge success, post-merge evidence capture, and confirmation that the branch is no longer needed for audit or rollback; retain the PR and commit history in GitHub.

# 3. Immediate post-merge controls

Run in order after merge. Record UTC timestamps and the merged `main` revision before beginning.

## 3.1 Flux source and Kustomization

- [ ] Owner: Shinobi / platform operator.

```bash
flux reconcile source git flux-system
flux get sources git flux-system
flux reconcile kustomization bootstrap-secrets --with-source
flux reconcile kustomization apps --with-source
flux get kustomizations
```

Expected:

- Git source reports the merged `main` revision.
- `bootstrap-secrets` and `apps` report `Ready=True` / successful application of that revision.
- `apps` remains `prune=true` and `wait=true` as designed.

Retain: source revision, Kustomization names, Ready conditions, messages, timestamps, and command exit codes. Do not treat a successful source fetch alone as workload acceptance.

## 3.2 Resource creation and storage

- [ ] Owner: Shinobi / platform operator.

```bash
kubectl -n apps get configmap audiobookshelf-config
kubectl -n apps get deployment audiobookshelf -o wide
kubectl -n apps get service audiobookshelf -o wide
kubectl -n apps get pvc audiobookshelf-config audiobookshelf-metadata audiobookshelf-audiobooks audiobookshelf-podcasts -o wide
kubectl -n apps get pods -l app.kubernetes.io/name=audiobookshelf -o wide
```

Remove the accidental leading `a` if copying the second command; the exact valid command is:

```bash
kubectl -n apps get deployment audiobookshelf -o wide
```

Expected: ConfigMap, Deployment, Service, four PVCs, and one Pod exist in namespace `apps`; all four PVCs show `Bound`; Deployment shows one desired/available replica; Pod is `Running` and `READY 1/1`.

Retain: resource names, UIDs, node name, PVC `VOLUME`, capacity, access mode, StorageClass, and timestamps.

- [ ] Owner: Shinobi. Confirm the storage risk remains understood:

```bash
kubectl get storageclass local-path -o jsonpath='{.provisioner}{" reclaim="}{.reclaimPolicy}{" volumeBindingMode="}{.volumeBindingMode}{"\n"}'
```

Expected: `rancher.io/local-path reclaim=Delete volumeBindingMode=WaitForFirstConsumer`.

## 3.3 Pod identity and security context

- [ ] Owner: Shinobi / Sentinel.

```bash
kubectl -n apps exec deploy/audiobookshelf -- id
kubectl -n apps get pod -l app.kubernetes.io/name=audiobookshelf -o jsonpath='{range .items[0].spec.containers[*]}{.name}{" allowPrivilegeEscalation="}{.securityContext.allowPrivilegeEscalation}{" capabilities="}{.securityContext.capabilities.drop}{"\n"}{end}'
kubectl -n apps get pod -l app.kubernetes.io/name=audiobookshelf -o jsonpath='{.items[0].spec.securityContext}{"\n"}'
```

Expected: process UID/GID 1000 (node user); `allowPrivilegeEscalation=false`; capabilities drop `ALL`; pod context includes `runAsNonRoot=true`, `runAsUser=1000`, `runAsGroup=1000`, `fsGroup=1000`, and `seccompProfile.type=RuntimeDefault`.

Retain: Pod name/UID, node, image tag and digest, command output, and timestamp. Redact unrelated environment values.

## 3.4 Probes, write access, and persistence

- [ ] Owner: Shinobi. Confirm readiness/liveness configuration and runtime health.

```bash
kubectl -n apps describe pod -l app.kubernetes.io/name=audiobookshelf
kubectl -n apps get pod -l app.kubernetes.io/name=audiobookshelf -o jsonpath='{.items[0].status.containerStatuses[0].ready}{"\n"}'
kubectl -n apps exec deploy/audiobookshelf -- sh -c 'touch /config/.wtest && rm /config/.wtest && echo WRITABLE'
```

Expected: readiness and liveness use HTTP GET `/ping` on named port `http`; container is ready; final line is `WRITABLE`; no probe failure events.

- [ ] Owner: Shinobi. Execute the persistence test with no manual pod recreation:

```bash
before=$(kubectl -n apps get pod -l app.kubernetes.io/name=audiobookshelf -o jsonpath='{.items[0].metadata.uid}')
kubectl -n apps delete pod -l app.kubernetes.io/name=audiobookshelf --wait=true
kubectl -n apps rollout status deployment/audiobookshelf --timeout=180s
after=$(kubectl -n apps get pod -l app.kubernetes.io/name=audiobookshelf -o jsonpath='{.items[0].metadata.uid}')
printf 'before_uid=%s after_uid=%s\n' "$before" "$after"
```

Expected: new Pod UID, rollout successful, all four PVCs remain Bound, and the test account/library/test file/metadata persist. Use only non-sensitive test audio until the backup/restore gate passes.

Retain: before/after Pod UIDs, rollout output, PVC status, UI evidence or approved screenshot, and timestamp.

## 3.5 Service endpoints and Ingress/certificate

- [ ] Owner: Shinobi.

```bash
kubectl -n apps get endpointslice -l kubernetes.io/service-name=audiobookshelf -o wide
kubectl -n apps get ingress audiobookshelf -o yaml
kubectl -n apps get certificate audiobookshelf-ninjatronics-io-tls -o wide
kubectl -n apps describe certificate audiobookshelf-ninjatronics-io-tls
```

Expected: EndpointSlice contains a ready Pod address and port 3005; Ingress has `ingressClassName: traefik`, host `audiobookshelf.ninjatronics.io`, backend Service `audiobookshelf:3005`, TLS Secret `audiobookshelf-ninjatronics-io-tls`, and issuer `letsencrypt-production-cloudflare`; Certificate condition `Ready=True`.

Retain: endpoint address without secrets, Ingress YAML/status, certificate name/namespace/issuer/Not Before/Not After/serial or fingerprint as permitted by policy, condition reason, and timestamp.

## 3.6 Shared Cloudflare Tunnel health and external HTTPS

- [ ] Owner: Shinobi / platform operator.

```bash
kubectl -n platform get deployment cloudflared -o wide
kubectl -n platform get pods -l app=cloudflared -o wide
kubectl -n platform logs deploy/cloudflared --since=15m | grep -Ei 'error|warn|connected|registered|tunnel' || true
for h in draw linkding qr grafana audiobookshelf; do curl -sS -I --max-time 20 "https://$h.ninjatronics.io" -o /dev/null -w "$h %{http_code}\n"; done
curl -sS -I --max-time 20 https://audiobookshelf.ninjatronics.io
```

Expected: cloudflared has one ready/available replica and no credential, tunnel, or route errors; existing hostnames continue to return their previously accepted status; Audiobookshelf returns HTTP 200 or an application-appropriate 302 after the route and certificate are live. A 404 after reconciliation is a failure requiring investigation, not an expected pre-cutover condition.

Retain: deployment/pod status, redacted log excerpt, each hostname/status, full response headers for Audiobookshelf, timestamp, and Cloudflare Ray ID. Never retain credentials or cookies.

# 4. First-run security gate

The first reachable Audiobookshelf deployment has an unauthenticated setup/enrollment window.

- [ ] Owner: Gerso. Before loading any real library data, open the service through the controlled internal port-forward or the newly validated HTTPS route and claim the initial ABS administrator immediately.

```bash
kubectl -n apps port-forward svc/audiobookshelf 3005:3005
curl -sS -i http://127.0.0.1:3005/ping
```

Expected: `/ping` returns HTTP 200 and the application is reachable. Complete the initial setup only through the approved operator workstation; do not put credentials in evidence.

- [ ] Owner: Gerso / Sentinel. Confirm the public hostname no longer presents an unclaimed setup wizard.

```bash
curl -sS -L --max-time 20 https://audiobookshelf.ninjatronics.io/ -o /tmp/audiobookshelf-home.html -w 'HTTP_STATUS=%{http_code}\n'
grep -Eiq 'setup|create.*admin|initial.*account|wizard' /tmp/audiobookshelf-home.html; printf 'setup_marker_exit=%s\n' "$?"
```

Expected: authentication is required after the administrator is claimed; no public setup-wizard or create-first-admin flow remains. Interpret HTML markers with application knowledge; retain a redacted screenshot or status evidence, not session cookies or credentials. Delete the temporary response after evidence capture.

- [ ] Owner: Gerso. Confirm authentication is required afterward using an approved browser check or a non-secret unauthenticated request. Do not load real media, personal data, or the production library before this gate is signed.

Retain: timestamp, operator, HTTP status/redirect behavior, redacted screenshot if needed, and the signed first-admin acceptance. Never retain passwords, bearer tokens, or cookies.

# 5. Data protection and rollback

## 5.1 Storage risk record

- [x] Owner: Archivist. The design uses four `ReadWriteOnce` `local-path` PVCs:

- `audiobookshelf-config`: 2Gi, `/config`
- `audiobookshelf-metadata`: 10Gi, `/metadata`
- `audiobookshelf-audiobooks`: 100Gi, `/audiobooks`
- `audiobookshelf-podcasts`: 50Gi, `/podcasts`

The live StorageClass is node-affine, uses `WaitForFirstConsumer`, and has `ReclaimPolicy=Delete`. Flux `apps` uses pruning. Deleting/pruning PVCs or performing a whole-feature revert can delete underlying data. A node loss can make data unavailable. Render success does not prove recoverability.

## 5.2 Backup targets and restore gate

- [ ] Owner: Shinobi / platform operator. Define and record backup targets for all four classes, with priority on `/config` and `/metadata` because they contain application state, users, libraries, and metadata. Back up `/audiobooks` and `/podcasts` according to the organization's media-retention policy.
- [ ] Owner: Shinobi. Perform a backup plus restore test before importing production data. The test must restore to isolated storage or a controlled test namespace, verify readable files, verify ABS configuration/library metadata, and prove that the service can start and serve the restored test content.
- [ ] Owner: Archivist. Retain backup job ID/path, source PVC names, target location, start/end timestamps, byte/file counts where safe, restore target, verification result, and operator sign-off. Do not retain media or credentials in the handoff unless the approved evidence system explicitly permits it.

Minimum acceptance: a fresh backup and a successful restore test for `/config` and `/metadata`; documented disposition for audiobook and podcast media. Until this passes, production data is not considered protected.

## 5.3 Safe rollback

- [ ] Owner: Gerso / Shinobi. For an image regression, change/revert only the image tag/digest and let Flux reconcile. Stable PVC names are preserved.
- [ ] Owner: Gerso / Shinobi. For an application rollback after data exists, do not blindly revert the whole feature. Preserve the four PVC manifests/objects and their data, and preserve `platform/cloudflared-tunnel-credentials`; otherwise Flux pruning can delete ABS data and removal of the shared Secret can break every tunnel hostname.
- [ ] Owner: Shinobi. Before any approved selective rollback, capture a verified backup, confirm the shared tunnel Secret remains present and hash-matched, and record the exact Git revision and resources intentionally changed.

Retain: backup evidence, planned diff, Flux reconciliation result, PVC identity/status before and after, tunnel deployment health, and external hostname checks.

# 6. Evidence capture and final acceptance record

For every check, attach evidence using this minimum record:

| Field | Required value |
|---|---|
| Check ID | Section/check identifier |
| Result | PASS / FAIL / BLOCKED / NOT RUN |
| UTC time | ISO-8601 timestamp |
| Owner | Named operator or approver |
| Command/action | Exact command or UI action |
| Expected | Expected output/state |
| Observed | Actual output/state, redacted |
| Resources | Namespace, name, UID, revision, certificate details as applicable |
| Evidence | Log path, screenshot path, API response, or signed approval |
| Follow-up | Issue, owner, and due decision if not PASS |

## Final PASS/FAIL acceptance record

A final **PASS** requires all of the following: PR approval and human local-path risk acceptance; successful three-target builds; verified credential hash MATCH; merged revision recorded; Flux source and Kustomizations Ready at that revision; resources created; four PVCs Bound; Pod Ready with UID/GID and security context verified; probes healthy; endpoint/Ingress/certificate checks pass; shared tunnel and existing hostnames remain healthy; external HTTPS is 200/302; initial admin is claimed and public setup is closed; and backup/restore evidence is complete before real production data is loaded.

| Gate | Owner | Result | Evidence reference | Sign-off/time |
|---|---|---|---|---|
| PR #6 identity, head SHA, 9 commits, 16 files | Archivist | PASS / FAIL |  |  |
| Clean branch and diff check | Archivist | PASS / FAIL |  |  |
| Three Kustomize builds | Archivist / Shinobi | PASS / FAIL |  |  |
| Sentinel PASS WITH NOTES reviewed | Sentinel / Archivist | PASS / FAIL |  |  |
| SOPS/live credential hash MATCH | Sentinel / Shinobi | PASS / FAIL |  |  |
| DNS present and pre-cutover 404 understood | Archivist | PASS / FAIL |  |  |
| Human local-path/recovery risk acceptance | Gerso | PASS / FAIL |  |  |
| Approved merge strategy and actual merge SHA | Gerso | PASS / FAIL |  |  |
| Flux source reconciled to merged `main` | Shinobi | PASS / FAIL |  |  |
| Flux `bootstrap-secrets` and `apps` Ready | Shinobi | PASS / FAIL |  |  |
| ABS resources created; four PVCs Bound | Shinobi | PASS / FAIL |  |  |
| Pod UID/GID and security context | Shinobi / Sentinel | PASS / FAIL |  |  |
| Probes, `/config` write, persistence test | Shinobi | PASS / FAIL |  |  |
| Service endpoints and Ingress | Shinobi | PASS / FAIL |  |  |
| Certificate Ready=True | Shinobi | PASS / FAIL |  |  |
| Shared cloudflared health and existing hostnames | Shinobi | PASS / FAIL |  |  |
| External HTTPS 200/302 | Shinobi | PASS / FAIL |  |  |
| Initial ABS admin claimed; setup no longer public | Gerso | PASS / FAIL |  |  |
| Backup target defined and restore test passed | Shinobi / Gerso | PASS / FAIL |  |  |
| Safe rollback plan preserves PVCs and tunnel Secret | Gerso / Shinobi | PASS / FAIL |  |  |
| Final production-data authorization | Gerso | PASS / FAIL |  |  |

## Gerso sign-off

I have reviewed the evidence, accepted the residual local-path/`Delete` recovery risk, and authorize the next phase only when the final acceptance conditions above are satisfied.

Name: Gerso Robayo-Guillen

Decision: APPROVE MERGE / HOLD / REJECT

Decision date/time UTC: ______________________________

Signature or approved PR reference: ______________________________

Production data authorized: YES / NO

# Documentation contradictions and reconciliation notes

1. The updated runbook's pre-cutover section is accurate: DNS is present, PR #6 exists as an open draft, the cluster tracks `main`, and pre-reconcile HTTPS 404 is expected. This resolves Sentinel's stale-runbook finding.
2. The runbook and ADR still identify the security review as `PH6-SEN-001` with verdict `PASS`, while the supplied independent artifact is `LAB-ABS-SEN-001` with verdict `PASS WITH NOTES`. The substantive conclusion is compatible, but the identifier and verdict wording are contradictory and should be normalized before final archival.
3. The runbook and ADR still state that SOPS/live credential parity could not be proven locally. Sentinel's result now records normalized SHA-256 MATCH, and the live hash was independently observed during this assignment. The documentation should be updated to say parity was verified by Sentinel, while noting that this review shell lacked the age identity for a second local decrypt.
4. The runbook says the security review has three MEDIUM residual/operational risks. Sentinel's result classifies local-path recovery as Medium and the `readOnlyRootFilesystem`/NetworkPolicy gaps as Low, with first-run administration as an operational gate. The severity language should be normalized to the Sentinel result.
5. Architecture documentation accurately describes the Audiobookshelf resources, ports, local-path `Delete` risk, security context, TLS, and shared tunnel, but it also says `PH6-SEN-001 — PASS`; update the review identifier/verdict to match `LAB-ABS-SEN-001 — PASS WITH NOTES`.

## Assignment conclusion

PR #6 is ready to mark Ready for review: **YES**, because the head is `5b2d6f5`, the branch is clean, the required builds pass, the runbook pre-cutover state is corrected, and Sentinel found no Blocker or High issue. Human approval and explicit local-path/recovery risk acceptance remain mandatory.

Safe to merge after human acceptance of the storage risk: **CONDITIONALLY YES**. Merge is safe only with the controls in this checklist, especially credential parity, controlled Flux reconciliation, immediate first-admin claim, preservation of PVCs/shared tunnel Secret, and post-merge runtime evidence. It is not safe to declare the service production-ready or load real library data until the backup/restore test and all post-merge gates pass.

Known uncertainty: this read-only review did not merge, reconcile Flux, or deploy Audiobookshelf. The live cluster currently tracks `main@sha1:4f48c2a2`, and Audiobookshelf Deployment/Service/Ingress/PVCs were not present; the ClusterIssuer was Ready and the existing cloudflared Deployment was healthy. Runtime write access, certificate issuance for the new hostname, application readiness, first-admin behavior, endpoint population, and external post-cutover HTTPS therefore remain unverified until the authorized cutover.

Evidence sources:

- `/home/gerso/src/lab/docs/runbooks/audiobookshelf-validation.md`
- `/home/gerso/src/lab/docs/decisions/0001-audiobookshelf-plain-manifests-shared-tunnel-sops-adoption.md`
- `/home/gerso/src/lab/docs/architecture.md`
- `/home/gerso/src/lab/kubernetes/apps/base/audiobookshelf/`
- `/home/gerso/src/lab/kubernetes/apps/production/audiobookshelf/`
- `/home/gerso/src/lab/kubernetes/bootstrap-secrets/cloudflared-tunnel-credentials.enc.yaml`
- `/home/gerso/src/lab/kubernetes/infrastructure/base/cloudflared/configmap.yaml`
- `/home/gerso/Development/ninjatronics-ai/shared/handoffs/LAB-ABS-SEN-001/result.md`
- GitHub public API: `https://api.github.com/repos/GMakeziG/lab/pulls/6`

No application manifest, Git history, PR state, Flux state, DNS record, or cluster resource was modified by this assignment.
