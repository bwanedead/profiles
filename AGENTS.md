# Profiles Repository

A shareable source for cross-machine shell profile configurations.

## Purpose

This repository serves as the **single source of truth** for shell profiles and related configuration files. Instead of maintaining separate profile configurations on each machine, all machines point to this centralized repo.

## Supported Configurations

| File | Description |
|------|-------------|
| `Microsoft.PowerShell_profile.ps1` | PowerShell 7 profile |
| `ryan.omp.json` | Oh My Posh terminal theme |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                        │
│                  github.com/bwanedead/profiles              │
│                                                             │
│  ┌─────────────────────────┐  ┌──────────────────────┐     │
│  │ PowerShell_profile.ps1  │  │   ryan.omp.json      │     │
│  │ (main profile logic)    │  │   (terminal theme)   │     │
│  └───────────┬─────────────┘  └──────────┬───────────┘     │
└──────────────┼───────────────────────────┼─────────────────┘
               │                           │
               ▼                           ▼
┌──────────────────────────┐    ┌──────────────────────────┐
│       Machine A          │    │       Machine B          │
│                          │    │                          │
│  $PROFILE contains:      │    │  $PROFILE contains:      │
│  . "C:\projects\profiles │    │  . "C:\projects\profiles │
│     \Microsoft.Power..." │    │     \Microsoft.Power..." │
│                          │    │                          │
│  (sources from repo)     │    │  (sources from repo)     │
└──────────────────────────┘    └──────────────────────────┘
```

## Setup Instructions

### Initial Setup (New Machine)

1. Clone this repository:
   ```powershell
   git clone https://github.com/bwanedead/profiles.git C:\projects\profiles
   ```

2. Replace your PowerShell profile with a source command:
   ```powershell
   # Edit your $PROFILE
   notepad $PROFILE

   # Replace contents with:
   . "C:\projects\profiles\Microsoft.PowerShell_profile.ps1"
   ```

3. Reload your profile:
   ```powershell
   . $PROFILE
   ```

### Daily Workflow

**Editing the profile:**
```powershell
prof edit          # Opens repo version in notepad
# Make changes, save
. $PROFILE         # Reload to apply changes
```

**Syncing changes:**
```powershell
prof               # Navigate to repo
git add -A && git commit -m "Update profile"
git push
```

**Pulling updates on another machine:**
```powershell
prof               # Navigate to repo
git pull
. $PROFILE         # Reload to apply changes
```

## Benefits

- **Single source of truth** - One place to maintain all profile logic
- **Version controlled** - Full history of changes, easy rollback
- **Cross-machine sync** - Push/pull to keep machines in sync
- **Shareable** - Others can fork and adapt for their own use
- **Backup** - Profile is safely stored in git, not just locally

## Adding New Profile Types

To add support for other shells (bash, zsh, etc.):

1. Add the config file to this repo
2. Update this README with setup instructions
3. On each machine, configure the shell to source from the repo
