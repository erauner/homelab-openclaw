# homelab-openclaw

OpenClaw CLI configuration and scripts for remote gateway access.

## Overview

This repository contains configuration and scripts for connecting local OpenClaw CLI instances to the remote gateway running in the homelab Kubernetes cluster.

**Gateway URL**: `wss://openclaw.erauner.dev`

## Installation

### Option 1: npm (recommended)

```bash
npm install -g openclaw@latest
```

### Option 2: pnpm

```bash
pnpm add -g openclaw@latest
```

### Option 3: From source

```bash
cd /Users/erauner/git/side/openclaw
pnpm install
pnpm build
pnpm openclaw onboard --install-daemon
```

### Verify installation

```bash
openclaw --version
```

## Prerequisites

- OpenClaw CLI installed (see above)
- Access to the gateway token via one of:
  - `SOPS_AGE_KEY` environment variable (auto-decrypts `secrets.sops.yaml`)
  - 1Password Homelab vault → "OpenClaw Gateway Token"

## Quick Start

### 1. Install and Configure

Run the setup script which handles installation and configuration:

Run the setup script to configure your local CLI:

```bash
./scripts/setup-remote-gateway.sh
```

This will:
- Configure the gateway URL
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
openclaw gateway status
```

## Using with Obsidian

Once connected to the remote gateway, OpenClaw can access your local Obsidian vault:

```bash
# Start OpenClaw with your vault path
openclaw --vault ~/Documents/Obsidian/MyVault

# Or configure the default vault
openclaw config set vault.path ~/Documents/Obsidian/MyVault
```

The remote gateway provides:
- Kubernetes cluster access (read-only)
- GitHub integration
- Anthropic API access

Your local vault files stay local - OpenClaw CLI reads them directly.

## Security Model

- **Gateway Token**: Required to authenticate with the remote gateway
- **Cloudflare Tunnel**: All traffic goes through Cloudflare's network
- **Token Auth**: The `OPENCLAW_GATEWAY_TOKEN` validates each connection
- **Read-Only Cluster Access**: Gateway has read-only RBAC in the cluster

## Architecture

```
Local Machine                    Homelab Cluster
+------------------+            +------------------+
| OpenClaw CLI     |            | OpenClaw Gateway |
| - Obsidian vault |  WebSocket | - K8s API access |
| - Local files    | ---------> | - GitHub access  |
| - Terminal       |   (wss://) | - Anthropic API  |
+------------------+            +------------------+
                                       |
                                       v
                                +------------------+
                                | Cloudflare       |
                                | Tunnel           |
                                +------------------+
```

## Related

- [homelab-k8s/apps/openclaw](https://github.com/erauner/homelab-k8s/tree/master/apps/openclaw) - Kubernetes deployment
- [OpenClaw Documentation](https://openclaw.dev/docs)
