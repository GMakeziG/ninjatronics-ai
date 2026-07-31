# Assignment LAB-ABS-ARC-001 — Merge & Cutover Evidence Checklist (Audiobookshelf PR #6)

You are Archivist, the documentation / knowledge-management / evidence specialist
for the Ninjatronics AI organization. This is an INDEPENDENT, READ-ONLY
documentation assignment. Inspect the artifacts DIRECTLY and form your own view.

## Environment
- GitOps repo under review (READ-ONLY): /home/gerso/src/lab
  - FluxCD + k3s homelab. Flux reconciles branch `main`.
  - PR #6: `feat/audiobookshelf` → `main`. Latest branch tip commit is
    `5b2d6f5` (docs pre-cutover update). Prior tip was `7cf3fc7`.
- Sentinel's completed independent security review artifacts (READ-ONLY):
  /home/gerso/Development/ninjatronics-ai/shared/handoffs/LAB-ABS-SEN-001/
    - result.md (Sentinel verdict: PASS WITH NOTES)
    - transport.json, assignment.md
- Tooling after: export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$PATH"
  (git, kubectl, kustomize, sops, age, dig available). NOTE: `gh` in your runtime
  may be UNAUTHENTICATED — if so, verify PR metadata via the public GitHub API
  (https://api.github.com/repos/GMakeziG/lab/pulls/6) and say so.

## Hard constraints (violating any = failed assignment)
- READ-ONLY on /home/gerso/src/lab: do NOT modify application manifests, do NOT
  commit, push, merge, mark ready, or reconcile Flux.
- Do NOT expose any secret value, decrypted credential, token, or private key.
- Your ONE deliverable WRITE is the checklist document you produce — write it to:
  /home/gerso/Development/ninjatronics-ai/shared/handoffs/LAB-ABS-ARC-001/merge-cutover-checklist.md
  (create that directory if needed). Do not write anywhere else.

## What to inspect directly (do not trust prior summaries blindly)
- PR #6 state: head SHA (expect 5b2d6f5), base main, draft status, mergeable, 9 commits now
  (the original 8 + the new docs commit), changed file count.
- Branch cleanliness: `git status --short` in the repo.
- The updated runbook: docs/runbooks/audiobookshelf-validation.md (confirm the
  pre-cutover state section is now accurate: DNS present, PR #6 exists, 404 expected).
- ADR: docs/decisions/0001-audiobookshelf-plain-manifests-shared-tunnel-sops-adoption.md
- Architecture: docs/architecture.md (Audiobookshelf section).
- Manifests (read-only reference): kubernetes/apps/base/audiobookshelf/*,
  kubernetes/apps/production/audiobookshelf/*, the SOPS Secret and cloudflared config.
- Sentinel's result.md — incorporate its findings (Medium: local-path recovery;
  Low: readOnlyRootFilesystem/NetworkPolicy; the resolved stale-runbook finding)
  and its SHA-256 credential MATCH (d4f25a11…a00507) as supporting evidence.
- Confirm the three kustomize builds still pass (base, production/audiobookshelf,
  production) and record exit codes.

## Produce a FORMAL merge-and-cutover evidence checklist covering ALL six areas

1. Pre-merge gates — PR head SHA; branch cleanliness; build results; SOPS/live
   credential hash match; DNS resolution; Sentinel verdict; human acceptance of
   local-path storage risk.
2. Merge controls — merge strategy; expected merge commit; prohibition on
   whole-feature rollback after data exists; feature-branch cleanup timing.
3. Immediate post-merge controls — Flux source reconciliation; Flux Kustomization
   reconciliation; resource creation; PVC Bound state; pod UID/GID + security
   context; readiness/liveness probes; service endpoints; ingress creation;
   certificate Ready state; shared cloudflared tunnel health; external HTTPS response.
4. First-run security — claim initial ABS admin immediately; confirm no setup
   wizard remains publicly available; confirm auth required afterward; avoid
   loading real library data before admin ownership is established.
5. Data protection — document local-path + ReclaimPolicy=Delete risks; define
   backup targets for /config and /metadata; require a backup+restore test before
   production data is considered protected; define safe rollback that preserves
   PVCs and the shared tunnel Secret.
6. Evidence capture — for each check give the EXACT command, expected output,
   and what to retain: timestamps, resource names, certificate details, HTTP
   status, screenshots/logs; end with a final PASS/FAIL acceptance record table.

Make the checklist actionable: real `kubectl`/`flux`/`curl`/`dig` commands with
expected outputs, ticky-box structure, owners, and a sign-off block for Gerso.

## Return (in your handoff)
- Checklist location (the path you wrote).
- Any remaining documentation contradictions you found across runbook/ADR/architecture.
- Whether PR #6 is ready to mark Ready for review.
- Whether it is safe to merge after human acceptance of the storage risk.

Follow the specialist-handoff format. Be candid about uncertainty; state any
assumption you could not verify. If the shared handoff template is not present,
follow the standard handoff content model directly.
