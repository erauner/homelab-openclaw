---
name: vault-cli
description: Manage Obsidian vault tasks and notes using the vault-cli tool. Create tasks, query open items, generate reports, and validate schemas.
metadata: {"openclaw":{"emoji":"📋","requires":{"bins":["node"]}}}
---

# vault-cli

A CLI for managing an Obsidian vault with structured tasks and notes. Located at `/home/node/vaults/mdbase/current/scripts/vault-cli`.

## Vault Location

The vault is at: `/home/node/vaults/mdbase/current`

The CLI script is at: `/home/node/vaults/mdbase/current/scripts/vault-cli`

## Available Commands

### Add a Task

```bash
./scripts/vault-cli add task --title "Task title" --priority 1 --status open --tags work,urgent
```

Options:
- `--title` (required): Task title (becomes filename)
- `--priority`: 1-5 (1 = highest)
- `--status`: open, in-progress, done, blocked
- `--tags`: Comma-separated tags

### Add a Note

```bash
./scripts/vault-cli add note --title "Note title" --body "# Content here"
```

Options:
- `--title` (required): Note title
- `--body`: Note content (markdown)

### Query Open Tasks

```bash
./scripts/vault-cli query
```

Lists all open tasks sorted by priority. Output format:
```
[P1] [open] Fix critical bug
        Tags: urgent, work
[P2] [in-progress] Review PR
        Tags: work
```

### Vault Report

```bash
./scripts/vault-cli report
```

Shows statistics: total files, tasks by status, notes count, etc.

### Validate Schemas

```bash
./scripts/vault-cli validate
```

Checks all tasks/notes against their type schemas in `_types/`.

### List Files

```bash
./scripts/vault-cli list
```

Lists all markdown files in the vault.

## Vault Structure

```
/home/node/vaults/mdbase/current/
├── _types/           # Schema definitions
│   ├── task.md       # Task frontmatter schema
│   └── note.md       # Note frontmatter schema
├── tasks/            # Task files
│   ├── Buy groceries.md
│   └── Review PR.md
├── inbox/            # Quick captures
├── projects/         # Project notes
├── logs/             # Daily logs
├── reference/        # Reference material
└── scripts/          # vault-cli lives here
    └── vault-cli
```

## Task Frontmatter Schema

```yaml
---
title: Task title
status: open | in-progress | done | blocked
priority: 1-5  # 1 = highest
tags:
  - tag1
  - tag2
created: '2026-01-31'
---
```

## Note Frontmatter Schema

```yaml
---
title: Note title
tags:
  - tag1
created: '2026-01-31'
---
```

## Working Directory

Always run vault-cli from the vault root:

```bash
cd /home/node/vaults/mdbase/current && ./scripts/vault-cli <command>
```

## Git Sync

Changes are synced via git-sync sidecar. To push changes:

```bash
cd /home/node/vaults/mdbase/current
git add -A
git commit -m "Add task: <title>"
git push origin HEAD:main
```

## Examples

Create a high-priority task:
```bash
cd /home/node/vaults/mdbase/current
./scripts/vault-cli add task --title "Fix auth bug" --priority 1 --status open --tags urgent,backend
```

Check what's open:
```bash
cd /home/node/vaults/mdbase/current
./scripts/vault-cli query
```

Add a meeting note:
```bash
cd /home/node/vaults/mdbase/current
./scripts/vault-cli add note --title "Team Standup 2026-01-31" --body "# Attendees\n- Alice\n- Bob\n\n# Notes\n..."
```
