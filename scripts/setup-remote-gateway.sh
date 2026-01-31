#!/usr/bin/env bash
#
# Setup OpenClaw CLI for remote gateway access
#
# Usage:
#   ./scripts/setup-remote-gateway.sh
#   ./scripts/setup-remote-gateway.sh --token <token>
#   ./scripts/setup-remote-gateway.sh --install
#
set -euo pipefail

GATEWAY_URL="wss://openclaw.erauner.dev"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

install_openclaw() {
    log_step "Installing OpenClaw CLI..."

    if command -v pnpm &> /dev/null; then
        log_info "Using pnpm..."
        pnpm add -g openclaw@latest
    elif command -v npm &> /dev/null; then
        log_info "Using npm..."
        npm install -g openclaw@latest
    else
        log_error "Neither npm nor pnpm found. Please install Node.js first."
        exit 1
    fi

    log_info "OpenClaw CLI installed successfully!"
    openclaw --version
}

# Parse arguments
TOKEN=""
DO_INSTALL=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --token)
            TOKEN="$2"
            shift 2
            ;;
        --install)
            DO_INSTALL=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [--install] [--token <gateway-token>]"
            echo ""
            echo "Installs and configures OpenClaw CLI for remote gateway access."
            echo ""
            echo "Options:"
            echo "  --install  Install OpenClaw CLI if not already installed"
            echo "  --token    Gateway authentication token (prompted if not provided)"
            echo "  --help     Show this help message"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if openclaw CLI is installed
if ! command -v openclaw &> /dev/null; then
    if [[ "$DO_INSTALL" == "true" ]]; then
        install_openclaw
    else
        log_warn "OpenClaw CLI not found."
        echo ""
        read -p "Would you like to install it now? [Y/n] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            install_openclaw
        else
            log_error "OpenClaw CLI is required. Install with: npm install -g openclaw@latest"
            exit 1
        fi
    fi
else
    log_info "OpenClaw CLI found: $(openclaw --version 2>/dev/null || echo 'unknown version')"
fi

# Prompt for token if not provided
if [[ -z "$TOKEN" ]]; then
    echo ""
    log_info "Gateway token required for authentication."
    echo "Get the token from 1Password > Homelab vault > OpenClaw Gateway Token"
    echo ""
    read -sp "Enter gateway token: " TOKEN
    echo ""
fi

if [[ -z "$TOKEN" ]]; then
    log_error "Token cannot be empty"
    exit 1
fi

log_info "Configuring remote gateway..."

# Configure the gateway
openclaw config set gateway.remote.url "$GATEWAY_URL"
openclaw config set gateway.remote.token "$TOKEN"
openclaw config set gateway.remote.enabled true

log_info "Gateway URL: $GATEWAY_URL"
log_info "Remote gateway enabled: true"

# Test connection
echo ""
log_info "Testing connection to gateway..."
if openclaw gateway status 2>/dev/null; then
    echo ""
    log_info "Successfully connected to remote gateway!"
else
    log_warn "Could not verify connection. The gateway may be starting up."
    log_warn "Try running 'openclaw gateway status' in a few moments."
fi

echo ""
log_info "Configuration complete!"
echo ""
echo "Next steps:"
echo "  1. Configure your Obsidian vault:"
echo "     openclaw config set vault.path ~/Documents/Obsidian/YourVault"
echo ""
echo "  2. Start OpenClaw:"
echo "     openclaw"
echo ""
