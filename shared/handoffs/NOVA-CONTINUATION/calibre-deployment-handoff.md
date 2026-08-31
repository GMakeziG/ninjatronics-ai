# Nova Continuation Handoff — Calibre Deployment

## 1. Orchestration State

Nova is orchestrator only. Codex is the only approved specialist execution runtime. Specialist roles (Shinobi, Sentinel, Archivist) are carried by Codex. Normal path: Nova -> Herdr -> Codex interactive. Direct codex exec is not the normal specialist path.

## 2. Verified Codex State

- Canonical binary: /home/gerso/.nvm/versions/node/v24.18.0/bin/codex
- Version: 0.151.0
- ChatGPT authentication works
- CODEX_HOME sharing into Nova is fixed
- Startup update checking disabled (check_for_update_on_startup = false in config.toml)
- Herdr interactive transport validated: idle -> working -> done, no agent_prompt_stalled
- Stale /usr/local v0.140.0 Codex install removed; nvm v0.151.0 is canonical

## 3. Context Optimization

dispatch-codex.sh launches specialist Codex with `codex --disable plugins` via Herdr argv.

Verified results:
- Skills: 99 -> 19 (80 plugin skills removed)
- Trivial prompt: 20,669 -> 16,503 tokens (20% reduction)
- Bounded specialist assignment: ~16,505 tokens
- No functional regressions (auth, hooks, CLAUDE.md, trust, sandbox all preserved)
- Normal interactive Codex sessions unaffected (flag is per-invocation only)

Specialist results must be consumed through bounded result.md handoffs. Do not ingest full Codex/Herdr transcripts or session JSONLs unless diagnosing a specific failure.

## 4. Nova Context Rules

For future orchestration:
- Poll background processes at most 2-3 times, never repeatedly
- Read specialist result.md, not process logs or session JSONLs
- Use targeted grep/head/find, never unrestricted strings on binaries
- Return only required metrics from diagnostic scripts
- Read only necessary sections of large policy files
- Keep specialist handoffs bounded
- Use durable files rather than keeping completed work in active context
- Target Nova working context: ~20K-30K tokens

## 5. Calibre Current State

Calibre research is complete. Target: https://calibre.ninjatronics.io

Public exposure has NOT been approved.

### Image Comparison (Shinobi, via Codex ~16.5K tokens)

Three options compared:

**A. rloomans/calibre-server**
- Minimal runtime, headless-only, port 8080, non-root (UID 1234)
- Unofficial single maintainer, 0 GitHub stars, small community
- Base image and Calibre tarball not digest-pinned in Dockerfile
- Supply-chain and bus-factor concerns
- Acceptable fallback only

**B. Ninjatronics-owned minimal image (RECOMMENDED by Shinobi)**
- Debian trixie-slim pinned by digest + official Calibre binary
- Calibre version pinned, tarball SHA-256 verified
- Non-root (proposed UID 10001:10001), calibre-server only, port 8080 only
- No desktop/VNC/terminal services
- Smallest attack surface, strongest supply-chain control
- TRADEOFF: Ninjatronics owns image build, CI, CVE patching, Calibre release tracking
- Maintenance burden is modest but ongoing

**C. LinuxServer Calibre (lscr.io/linuxserver/calibre)**
- Well maintained (368 stars, 50M+ pulls, daily updates)
- Full remote desktop stack (Selkies, Wayland, PulseAudio, NGINX, passwordless sudo)
- Can expose only port 8081 via Kubernetes Service but desktop processes still run in pod
- Initialization starts privileged
- Not recommended for headless-only deployment

**NO IMAGE OPTION HAS YET BEEN APPROVED BY GERSO.**

### Architecture (from research phase)

- Dedicated namespace: calibre
- Base + production overlay Kustomize pattern
- PVCs: calibre-config (2Gi), calibre-library (100Gi), local-path, RWO
- Node placement: kubernetes.io/hostname: niner
- Strategy: Recreate (single replica, RWO storage)
- Security context: runAsNonRoot, runAsUser 1000, runAsGroup 1000, fsGroup 1000, seccompProfile RuntimeDefault, allowPrivilegeEscalation false, capabilities drop ALL
- Service: ClusterIP, port 8080
- Auth: calibre-server --enable-auth --userdb, credentials via OpenBao at secret/apps/calibre
- Health: TCP probes (no dedicated HTTP health endpoint confirmed)
- OpenBao + ESO for runtime secrets, ExternalSecret in production overlay
- Ingress: Traefik, cert-manager TLS (internal only initially, public later)

### Files to Create

Base (kubernetes/apps/base/calibre/):
  kustomization.yaml, configmap.yaml, deployment.yaml, service.yaml, pvc.yaml, secret.example.yaml

Production (kubernetes/apps/production/calibre/):
  kustomization.yaml, ingress.yaml, external-secrets/kustomization.yaml, external-secrets/calibre-secret.yaml

Namespace: kubernetes/namespaces/calibre.yaml (+ add to kustomization.yaml)
Aggregation: add calibre to kubernetes/apps/production/kustomization.yaml

Cloudflare Tunnel route: NOT until Phase 3 approval.

## 6. Next Action

1. Ask Gerso which Calibre image option he approves (A, B, or C).
2. After approval, proceed to Phase 1: implement GitOps manifests, deploy internally, validate.
3. Phase 2: Sentinel reviews actual deployed manifests.
4. Phase 3: STOP and request explicit approval before Cloudflare DNS, cloudflared public hostname, Cloudflare Access, public ingress.

Do not expose Calibre publicly before Phase 3 approval.
