# homelab-openclaw

OpenClaw CLI configuration and scripts for remote gateway access.

## Overview

This repository contains configuration and scripts for connecting local OpenClaw CLI instances to the remote gateway running in the homelab Kubernetes cluster.

**Gateway URL**: `wss://openclaw.erauner.dev`

## Architecture

There are two ways to use OpenClaw with your Obsidian vault:

### 1. Local Mode (CLI on your machine)

```
┌─────────────────────────────────────┐
│           Your Machine              │
│  ┌─────────────────────────────┐    │
│  │     OpenClaw CLI            │    │
│  │     (openclaw agent)        │    │
│  │            │                │    │
│  │            ▼                │    │
│  │  ~/obsidian_vaults/mdbase/  │    │
│  │  (local vault files)        │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

When you run `openclaw agent --local`, it reads vault files directly from your local filesystem.

### 2. Remote Gateway Mode (K8s deployment)

```
Your Devices                         Kubernetes Cluster
┌────────────────────┐              ┌────────────────────────────────────────┐
│ Mac/Desktop        │              │          OpenClaw Gateway Pod          │
│ (mdbase_vault)     │              │  ┌────────────────────────────────┐   │
│        │           │              │  │ git-sync sidecar               │   │
│        │ Obsidian  │              │  │ (pulls every 60s)              │   │
│        │ Sync      │              │  │        │                       │   │
│        ▼           │              │  │        ▼                       │   │
│ Phone/Tablet       │              │  │ /home/node/vaults/mdbase/      │   │
└────────────────────┘              │  │ (synced from GitHub)           │   │
        │                           │  └────────────────────────────────┘   │
        │ git push                  │                  │                    │
        ▼                           │                  ▼                    │
┌────────────────────┐              │  ┌────────────────────────────────┐   │
│ GitHub (private)   │◄─────────────┤  │ OpenClaw Gateway               │   │
│ homelab-obsidian-  │  SSH clone   │  │ - obsidian skill (ready)       │   │
│ vault              │              │  │ - Can read/write vault         │   │
└────────────────────┘              │  └────────────────────────────────┘   │
                                    └────────────────────────────────────────┘
                                                     ▲
                                                     │ WebSocket (wss://)
                                                     │
                                    ┌────────────────────────────────────────┐
                                    │         Your CLI (remote mode)         │
                                    │   openclaw agent --agent obsidian      │
                                    │   --message "List my tasks"            │
                                    └────────────────────────────────────────┘
```

## Sync Strategy: Obsidian Sync vs Git

| Sync Method | Purpose | Latency | Direction |
|-------------|---------|---------|-----------|
| **Obsidian Sync** | Real-time sync between your devices (Mac, phone, tablet) | Instant | Bidirectional |
| **Git** | Version control + get vault into K8s | ~60 seconds | Push to GitHub → K8s pulls |

**Recommended workflow:**
1. Edit in Obsidian on any device (synced instantly via Obsidian Sync)
2. Periodically commit and push to GitHub (manual or via Obsidian Git plugin)
3. K8s gateway pulls changes within 60 seconds
4. Changes made by the gateway are committed by git-sync (requires GitHub push from pod)

**Note:** Obsidian Sync and Git are complementary:
- Obsidian Sync handles real-time device sync
- Git handles version control and K8s access

## Installation

### Option 1: npm (recommended)

```bash
npm install -g openclaw@latest
```

### Option 2: pnpm

```bash
pnpm add -g openclaw@latest
```

### Verify installation

```bash
openclaw --version
```

## Prerequisites

- OpenClaw CLI installed (see above)
- Access to the gateway token via one of:
  - `SOPS_AGE_KEY` environment variable (auto-decrypts `secrets.sops.yaml`)
  - 1Password Homelab vault -> "OpenClaw Gateway Token"

## Quick Start

### 1. Configure Remote Gateway

Run the setup script:

```bash
./scripts/setup-remote-gateway.sh
```

This will:
- Configure the gateway URL (`wss://openclaw.erauner.dev`)
- Set up token authentication
- Test the connection

### 2. Manual Configuration

If you prefer manual setup:

```bash
# Set the remote gateway URL
openclaw config set gateway.remote.url wss://openclaw.erauner.dev

# Set the authentication token
openclaw config set gateway.remote.token <token-from-1password>
```

### 3. Verify Connection

```bash
openclaw gateway probe
```

## Using the Obsidian Skill

The obsidian skill is available on the remote gateway:

```bash
# List vault files
openclaw agent --message "List all markdown files in the vault"

# Search for tasks
openclaw agent --message "Find all tasks tagged #urgent"

# Create a new note
openclaw agent --message "Create a note called 'Meeting Notes' with today's date"
```

**Note:** The gateway uses the vault synced from GitHub, not your local vault.
Changes made by the gateway are committed to git but require push access to sync back.

## K8s Deployment Details

The gateway deployment is managed in [homelab-k8s/apps/openclaw](https://github.com/erauner/homelab-k8s/tree/master/apps/openclaw).

Key components:
- **git-sync init container**: Clones vault at startup
- **git-sync sidecar**: Syncs every 60 seconds
- **SSH deploy key**: Read-only access to private vault repo
- **fsGroup + group-write**: Allows main container to write to synced files

See [obsidian-vault-sync.md](https://github.com/erauner/homelab-k8s/blob/master/apps/openclaw/docs/obsidian-vault-sync.md) for detailed setup documentation.

## Security Model

- **Gateway Token**: Required to authenticate with the remote gateway
- **Cloudflare Tunnel**: All traffic goes through Cloudflare's network
- **Token Auth**: The `OPENCLAW_GATEWAY_TOKEN` validates each connection
- **Read-Only Cluster Access**: Gateway has read-only RBAC in the cluster
- **Private Vault**: GitHub repo is private, accessed via SSH deploy key

## Troubleshooting

### Check gateway status

```bash
openclaw gateway probe
```

### Check vault sync status (requires kubectl)

```bash
# Check pod status
kubectl get pods -n ai -l app.kubernetes.io/name=openclaw

# Check git-sync logs
kubectl logs -n ai -l app.kubernetes.io/name=openclaw -c vault-sync --tail=20

# Verify vault contents
kubectl exec -n ai deploy/openclaw -c main -- ls -la /home/node/vaults/mdbase/current/
```

### Force re-sync vault

```bash
kubectl delete pod -n ai -l app.kubernetes.io/name=openclaw
```

## Related

- [homelab-k8s/apps/openclaw](https://github.com/erauner/homelab-k8s/tree/master/apps/openclaw) - Kubernetes deployment
- [homelab-obsidian-vault](https://github.com/erauner/homelab-obsidian-vault) - Private vault repository
- [OpenClaw Documentation](https://docs.openclaw.ai)
