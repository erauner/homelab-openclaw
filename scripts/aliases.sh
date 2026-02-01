#!/bin/bash
# Shell aliases for OpenClaw CLI
#
# Add to your ~/.zshrc or ~/.bashrc:
#   source ~/git/side/homelab-openclaw/scripts/aliases.sh

# Quick agent command - sends message to remote gateway
# Usage: oc-agent "What's in my vault?"
alias oc-agent='openclaw agent --agent main --message'

# Example vault-cli commands (via agent):
#   oc-agent "Show my open tasks"
#   oc-agent "Create a P1 task: Fix auth bug, tags: work"
#   oc-agent "Add a note called 'Meeting Notes' with today's agenda"
#   oc-agent "Commit all changes and push to origin"

echo "OpenClaw aliases loaded."
echo "  oc-agent '<message>' - Send message to OpenClaw agent"
echo ""
echo "Vault operations use the vault-cli skill. Examples:"
echo "  oc-agent 'Show my open tasks'"
echo "  oc-agent 'Create a task: Buy groceries, priority 3'"
