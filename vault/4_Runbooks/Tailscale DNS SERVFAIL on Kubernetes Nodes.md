---
title: Tailscale DNS SERVFAIL on Kubernetes Nodes
type: runbook
status: active
tags:
  - tailscale
  - dns
  - troubleshooting
  - kubernetes
  - k3s
  - homelab
created: 2026-08-30
updated: 2026-08-30
---

# Tailscale DNS SERVFAIL on Kubernetes Nodes

## Purpose

Diagnose and resolve DNS resolution failures on K3s worker nodes caused
by Tailscale DNS management without a configured upstream resolver.

## Preconditions

- Node is a Tailscale tailnet member
- Node is a K3s worker in the [[Ninjatronics K3s Homelab]]
- Symptoms may include `ImagePullBackOff`, `SERVFAIL` DNS responses, or
  general DNS resolution failures

## Symptoms

- `ImagePullBackOff` on pods scheduled on the affected node
- `failed to resolve reference "docker.io/..."` with `dial tcp: lookup
  registry-1.docker.io: Try again`
- DNS queries returning `SERVFAIL`
- Internet connectivity (ping by IP) still works

## Diagnosis

### Step 1: Check if Tailscale is managing DNS

```bash
cat /etc/resolv.conf
```

If it shows `nameserver 100.100.100.100` (Tailscale Quad100), Tailscale
DNS management is active.

### Step 2: Test the Quad100 resolver

```bash
nslookup registry-1.docker.io 100.100.100.100
nslookup google.com 100.100.100.100
dig @100.100.100.100 registry-1.docker.io
```

If these return `SERVFAIL`, the Tailscale DNS path is the problem.

### Step 3: Verify Internet connectivity is healthy

```bash
ping -c 3 1.1.1.1
```

If this succeeds, the issue is DNS, not connectivity.

### Step 4: Verify Tailscale is operational

```bash
tailscale status
tailscale netcheck
```

Tailscale networking itself may be fine — the failure is specifically in
DNS forwarding.

### Step 5: Check Tailscale DNS configuration

```bash
tailscale dns status
```

Look for:
- `Tailscale DNS: disabled` or `enabled`
- `Resolvers: (no resolvers configured, system default will be used)`
- Split DNS routes

### Step 6: Check Tailscale logs for the root Cause

```bash
sudo journalctl -u tailscaled --since "2 hours ago" \
  | grep -iE 'dns|resolver|resolv|servfail'
```

The decisive evidence is:

```
dns: resolver: forward: no upstream resolvers set, returning SERVFAIL
```

This confirms Tailscale needs an upstream resolver but none is configured.

### Step 7: Test the LAN resolver directly

```bash
dig @10.99.0.1 google.com
dig @10.99.0.1 registry-1.docker.io
```

If these return `status: NOERROR`, the LAN resolver is healthy and can
replace the Tailscale DNS path.

## Root cause

```
Node
  -> Tailscale DNS enabled
  -> /etc/resolv.conf points to 100.100.100.100
  -> normal Internet DNS query arrives at Tailscale
  -> Tailscale needs an upstream resolver
  -> no upstream resolver available
  -> SERVFAIL
  -> Docker registry hostname cannot resolve
  -> containerd cannot pull image
  -> ImagePullBackOff
```

This is NOT:
- Docker Hub rate limiting
- A bad image or tag
- K3s networking
- A Cloudflare outage
- General Internet failure

It IS specifically Tailscale DNS forwarding without an available upstream
resolver.

## Resolution

### Immediate workaround

Disable Tailscale DNS management:

```bash
sudo tailscale set --accept-dns=false
```

Verify the resolver is restored:

```bash
cat /etc/resolv.conf
# Should show: nameserver 10.99.0.1
```

Verify DNS works:

```bash
getent hosts google.com
getent hosts registry-1.docker.io
```

### Verify recovery

```bash
dig @10.99.0.1 google.com
dig @10.99.0.1 registry-1.docker.io
# Both should return: status: NOERROR
```

### Verify K3s recovery

Any pods in `ImagePullBackOff` should now be pullable. Check with:

```bash
kubectl get pods -A --field-selector=spec.nodeName=<node-name>
```

## What NOT to do

- Do NOT delete the healthy cloudflared pod during diagnosis. It keeps the
  Cloudflare Tunnel alive while you investigate.
- Do NOT assume `ImagePullBackOff` means a bad image or registry outage.
  Test DNS from the actual Kubernetes node first.
- Do NOT re-enable `--accept-dns=true` until a valid upstream resolver is
  configured and validated.

## Remaining architectural work

Decide whether homelab nodes should use Tailscale-managed DNS at all. If
yes:

1. Configure a valid upstream resolver in the Tailscale admin console.
2. Validate MagicDNS and split DNS behavior.
3. Test from the node before re-enabling `--accept-dns=true`.
4. Verify Kubernetes DNS (CoreDNS) still resolves cluster-internal names.

## Related notes

- [[Samson]]
- [[Ninjatronics K3s Homelab]]
- [[Forgejo]]
