# Claude Instructions

This repository contains shareable shell profile configurations designed for cross-machine synchronization.

## Project Structure

- `Microsoft.PowerShell_profile.ps1` - PowerShell 7 profile with navigation shortcuts, venv helpers, and Oh My Posh setup
- `ryan.omp.json` - Oh My Posh theme configuration

## How It Works

The actual system profile files (e.g., `$PROFILE` in PowerShell) contain only a single line that sources from this repo:

```powershell
. "C:\projects\profiles\Microsoft.PowerShell_profile.ps1"
```

This allows the user to:
1. Edit the repo version directly
2. Commit and push changes
3. Pull on other machines to sync

## When Editing

- Always edit the files in this repo, never the system profile files
- The `prof edit` command opens the repo version in notepad
- After editing, user reloads with `. $PROFILE`
- Changes should be committed and pushed for cross-machine sync

## Key Functions in the Profile

- `prof` / `profile` - navigate to this repo
- `prof edit` - open profile in notepad
- `z`, `zi` - zoxide navigation (custom overrides)
- `cede <project>` - jump to C:\projects\<project>
- `venv` / `venv off` / `venv status` - Python venv management
- `root` / `front` / `back` - repo-aware navigation
- Various project shortcuts: `pa`, `prose`, `algent`, `agentkit`, etc.
