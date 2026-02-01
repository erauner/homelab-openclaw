#!/bin/bash
# Convenience wrapper for openclaw agent with sensible defaults
#
# Usage:
#   oc-agent "Your message here"
#   oc-agent "Create a note called X with content Y"
#
# This defaults to using the remote gateway's main agent with obsidian skill.

set -e

if [ -z "$1" ]; then
    echo "Usage: oc-agent <message>"
    echo "Example: oc-agent 'List markdown files in the vault'"
    exit 1
fi

MESSAGE="$*"

exec openclaw agent --agent main --message "$MESSAGE"
