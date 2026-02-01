#!/bin/bash
# Create a note in the vault and optionally push to GitHub
#
# Usage:
#   oc-note "Note Title" "Note content here"
#   oc-note --push "Note Title" "Note content"
#
# Options:
#   --push    Commit and push the note to GitHub after creation
#   --help    Show this help message

set -e

PUSH=false

show_help() {
    echo "Usage: oc-note [--push] <title> <content>"
    echo ""
    echo "Create a note in the vault via OpenClaw gateway."
    echo ""
    echo "Options:"
    echo "  --push    Commit and push to GitHub after creating the note"
    echo "  --help    Show this help"
    echo ""
    echo "Examples:"
    echo "  oc-note 'Meeting Notes' 'Discussed project timeline'"
    echo "  oc-note --push 'Quick Note' 'Remember to follow up'"
}

# Parse arguments
while [[ "$1" == --* ]]; do
    case "$1" in
        --push)
            PUSH=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Both title and content are required"
    show_help
    exit 1
fi

TITLE="$1"
CONTENT="$2"
FILENAME="${TITLE// /-}.md"  # Replace spaces with dashes

echo "Creating note: $FILENAME"

# Create the note
openclaw agent --agent main --message "Create a note called '$FILENAME' with the following content:

$CONTENT

Just create the file, don't add any extra formatting."

if [ "$PUSH" = true ]; then
    echo "Committing and pushing..."
    openclaw agent --agent main --message "Commit the file '$FILENAME' with message 'feat: Add $TITLE via OpenClaw' and push to origin HEAD:main"
    echo "Pushed to GitHub."
fi

echo "Done."
