#!/bin/bash
# Shell aliases for OpenClaw CLI
#
# Add to your ~/.zshrc or ~/.bashrc:
#   source ~/git/side/homelab-openclaw/scripts/aliases.sh
#
# NOTE: If you see "compdef: command not found", ensure compinit is called
# before sourcing openclaw completions in your ~/.zshrc:
#   autoload -Uz compinit && compinit
#   source <(openclaw completion --shell zsh)

# Function for sending messages to the remote gateway
# Usage: oc-agent "What's in my vault?"
oc-agent() {
    if [[ -z "$1" ]]; then
        echo "Usage: oc-agent '<message>'"
        echo ""
        echo "Examples:"
        echo "  oc-agent 'Show my open tasks'"
        echo "  oc-agent 'Create a note called Meeting Notes with todays agenda'"
        echo "  oc-agent 'List files in my vault'"
        return 1
    fi
    openclaw agent --agent main --message "$*"
}

# Status check - verify gateway connection
oc-status() {
    echo "=== OpenClaw Gateway Status ==="
    openclaw gateway status 2>/dev/null || echo "Gateway not reachable"
    echo ""
    echo "Gateway URL: $(openclaw config get gateway.remote.url 2>/dev/null || echo 'not configured')"
}

# Quick dashboard access
oc-dashboard() {
    openclaw dashboard
}

echo "OpenClaw aliases loaded."
echo "  oc-agent '<message>' - Send message to OpenClaw agent"
echo "  oc-status            - Check gateway connection"
echo "  oc-dashboard         - Open Control UI"
echo ""
echo "Examples:"
echo "  oc-agent 'Show my open tasks'"
echo "  oc-agent 'Create a task: Buy groceries, priority 3'"
