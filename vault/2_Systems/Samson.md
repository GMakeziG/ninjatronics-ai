---
title: Samson
type: system
status: active
tags:
  - samson
  - homelab
  - kubernetes
  - k3s
  - tailscale
  - dns
created: 2026-08-30
updated: 2026-08-30
---

# Samson

## Overview

Worker node in the [[Ninjatronics K3s Homelab]]. Runs the `cloudflared`
pod (namespace: platform) and is a Tailscale tailnet member.

## Known-good state (as of 2026-08-30)

| Component                      | State                          |
|--------------------------------|--------------------------------|
| LAN DNS                        | `10.99.0.1` — working          |
| Internet connectivity          | Working                         |
| Internet DNS resolution        | Working                         |
| `registry-1.docker.io` resolution | Working                     |
| K3s/containerd image pulls     | Working                         |
| Tailscale networking           | Working                         |
| Tailscale DNS management       | **Disabled intentionally**     |
| Bash history synchronization   | Working                         |
| Zoxide PROMPT_COMMAND hook     | Working                         |
| Oh My Posh PROMPT_COMMAND hook | Working                         |

Current intentional setting:

```bash
sudo tailscale set --accept-dns=false
```

Current resolver in `/etc/resolv.conf`:

```
nameserver 10.99.0.1
```

## Tailscale DNS incident (2026-08-30)

See [[Tailscale DNS SERVFAIL on Kubernetes Nodes]] for the full
troubleshooting runbook.

**Summary:** Tailscale DNS management was enabled but had no upstream
resolver configured. All DNS queries went to Tailscale's Quad100
(`100.100.100.100`), which returned SERVFAIL. This caused
`registry-1.docker.io` to be unresolvable, which caused
`ImagePullBackOff` on the cloudflared pod. The root cause was DNS
forwarding, not Docker Hub rate limiting, a bad image, or K3s networking.

**Fix:** `sudo tailscale set --accept-dns=false` — restored LAN DNS
(`10.99.0.1`). Internet DNS, Docker registry resolution, and containerd
image pulls all recovered immediately.

**Open architectural question:** Should homelab nodes use Tailscale
DNS/MagicDNS at all? If yes, a valid upstream resolver must be configured
and validated before re-enabling `--accept-dns=true`.

## Bash PROMPT_COMMAND fix (2026-08-30)

Every shell command on Samson generated `syntax error near unexpected
token ';;'` from a malformed `PROMPT_COMMAND`.

**Root cause:** `~/.bashrc` set:

```bash
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
```

This left a trailing `;` when `PROMPT_COMMAND` was empty. Zoxide's
`eval "$(zoxide init bash)"` then appended its hook, producing:

```
history -a; history -c; history -r;;__zoxide_hook
```

The double `;;` caused Bash syntax errors on every prompt execution.

**Fix:** Changed to:

```bash
PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
```

This conditionally appends `; $PROMPT_COMMAND` only when an existing
`PROMPT_COMMAND` is non-empty.

**Verification:** `declare -p PROMPT_COMMAND` showed all three hooks
(history sync, Zoxide, Oh My Posh) coexisting correctly with no `;;`.

## Related notes

- [[Ninjatronics K3s Homelab]]
- [[Tailscale DNS SERVFAIL on Kubernetes Nodes]]
- [[Forgejo]]
