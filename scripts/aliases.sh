#!/bin/bash
# Shell aliases for OpenClaw convenience commands
#
# Add to your ~/.zshrc or ~/.bashrc:
#   source ~/git/side/homelab-openclaw/scripts/aliases.sh
#
# Or add individual aliases:
#   alias oc-agent='openclaw agent --agent main --message'
#   alias oc-vault-push='openclaw agent --agent main --message "Commit all changes and push to origin HEAD:main"'

# Quick agent command (uses remote gateway's main agent)
alias oc-agent='openclaw agent --agent main --message'

# Push vault changes (commit all + push)
alias oc-vault-push='openclaw agent --agent main --message "Commit all uncommitted changes with a descriptive commit message and push to origin HEAD:main"'

# Vault status (check git status)
alias oc-vault-status='openclaw agent --agent main --message "Run git status to show uncommitted changes"'

# List vault files
alias oc-vault-ls='openclaw agent --agent main --message "List the markdown files in the vault"'

# Search vault
oc-vault-search() {
    if [ -z "$1" ]; then
        echo "Usage: oc-vault-search <query>"
        return 1
    fi
    openclaw agent --agent main --message "Search the vault for files or content matching: $*"
}

# Create a quick note
oc-quick-note() {
    if [ -z "$1" ]; then
        echo "Usage: oc-quick-note <content>"
        echo "Creates a quick note with timestamp as title"
        return 1
    fi
    local timestamp=$(date +%Y%m%d-%H%M%S)
    openclaw agent --agent main --message "Create a note called 'Quick-Note-$timestamp.md' with content: $*"
}

echo "OpenClaw aliases loaded. Available commands:"
echo "  oc-agent '<message>'      - Send message to OpenClaw agent"
echo "  oc-vault-push            - Commit and push vault changes"
echo "  oc-vault-status          - Show vault git status"
echo "  oc-vault-ls              - List vault files"
echo "  oc-vault-search <query>  - Search vault content"
echo "  oc-quick-note <content>  - Create a quick timestamped note"
