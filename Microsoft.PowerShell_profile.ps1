# --- zoxide init ---
Invoke-Expression (zoxide init powershell | Out-String)

# --- HARD OVERRIDE z / zi (must come AFTER zoxide init) ---
# Remove anything zoxide init created
Remove-Item -Path Function:\z  -ErrorAction SilentlyContinue
Remove-Item -Path Function:\zi -ErrorAction SilentlyContinue
Remove-Item -Path Alias:\z     -ErrorAction SilentlyContinue
Remove-Item -Path Alias:\zi    -ErrorAction SilentlyContinue

function z {
  param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
  )

  if ($Args.Count -eq 0) { Set-Location $HOME; return }
  if ($Args.Count -eq 1 -and $Args[0] -ieq "home") { Set-Location $HOME; return }

  $dest = & zoxide query @Args 2>$null
  if ($LASTEXITCODE -eq 0 -and $dest) {
    Set-Location $dest
  } else {
    Write-Error "z: no match for: $($Args -join ' ')"
  }
}

function zi {
  $dest = & zoxide query -i 2>$null
  if ($LASTEXITCODE -eq 0 -and $dest) { Set-Location $dest }
}


function cede {
  param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
  )

  if ($Args.Count -eq 0) {
    Write-Error "Usage: cede <project>  (e.g. cede prose-ada OR cede prose ada)"
    return
  }

  # If they typed: cede prose ada  -> treat as prose-ada
  $name = if ($Args.Count -gt 1) { ($Args -join "-") } else { $Args[0] }

  $path = Join-Path "C:\projects" $name

  if (Test-Path -LiteralPath $path) {
    Set-Location $path
  } else {
    Write-Error "cede: not found: $path"
  }
}


# --- one-word jump shortcuts (zoxide-powered) ---
function home      { z home }

function plattera  { z plattera }
function frontend  { z plattera frontend }   # or call it: pf / platterafrontend

function proseada  { z prose ada }
function prose     { z prose ada }

function pa {
  param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
  )

  if ($Args.Count -eq 0) {
    Set-Location "C:\projects\stories\prose-ada"
    return
  }

  if ($Args[0] -eq "app") {
    Set-Location "C:\projects\prosada-app"
    return
  }

  Write-Error "pa: unknown subcommand: $($Args -join ' ')"
}

function sinap     { z sinap }

function scriptara { z scriptara }           # matches the OneDrive path
function sc        { z scriptara }

function chessterra { z chessterra }
function chess      { z chessterra }

function algent    { z algent }

$PROFILE_REPO = "C:\projects\profiles\Microsoft.PowerShell_profile.ps1"

function profile {
  param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
  )

  if ($Args.Count -ge 1 -and $Args[0] -in "edit", "e") {
    notepad $PROFILE_REPO
    return
  }

  if ($Args.Count -ge 1 -and $Args[0] -in "off", "none", "bare") {
    pwsh -NoProfile
    return
  }

  Set-Location "C:\projects\profiles"
}

function prof { profile @Args }

function agentkit  { Set-Location "C:\projects\agent-kit" }
function ak        { Set-Location "C:\projects\agent-kit" }

function agent {
  param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
  )

  if ($Args.Count -eq 0 -or $Args[0] -ieq "kit") {
    Set-Location "C:\projects\agent-kit"
    return
  }

  Write-Error "agent: unknown subcommand: $($Args -join ' ')"
}

# --- venv helpers ---
function venv {
  param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]] $Args
  )

  # venv off / venv deactivate / venv stop
  if ($Args.Count -ge 1) {
    $cmd = $Args[0].ToLowerInvariant()

    if ($cmd -in @("off","deactivate","stop")) {
      if (Get-Command deactivate -ErrorAction SilentlyContinue) {
        $old = $env:VIRTUAL_ENV
        deactivate
        Write-Host "Venv deactivated: $old" -ForegroundColor Cyan
      } else {
        Write-Host "No venv is currently active." -ForegroundColor Yellow
      }
      return
    }

    # venv status
    if ($cmd -in @("status","st")) {
      if ($env:VIRTUAL_ENV) {
        Write-Host "Venv active: $env:VIRTUAL_ENV" -ForegroundColor Cyan
      } else {
        Write-Host "No venv is currently active." -ForegroundColor Yellow
      }
      return
    }
  }

  # If already active, be explicit (and don't re-activate)
  if ($env:VIRTUAL_ENV) {
    Write-Host "Venv already active: $env:VIRTUAL_ENV  (use: venv off)" -ForegroundColor Yellow
    return
  }

  # Look ONLY locally: current dir and one parent dir
  $candidates = @(
    (Join-Path (Get-Location).Path ".venv\Scripts\Activate.ps1"),
    (Join-Path (Split-Path -Parent (Get-Location).Path) ".venv\Scripts\Activate.ps1")
  )

  $activate = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

  if (-not $activate) {
    Write-Error "No local .venv found in current folder or parent folder. (Expected .venv\Scripts\Activate.ps1)"
    return
  }

  $venvRoot = Split-Path -Parent (Split-Path -Parent $activate)  # ...\.venv
  Write-Host "Activating local .venv: $venvRoot" -ForegroundColor Cyan
  . $activate

  if ($env:VIRTUAL_ENV) {
    Write-Host "Venv activated: $env:VIRTUAL_ENV" -ForegroundColor Cyan
  } else {
    Write-Host "Venv activation did not set VIRTUAL_ENV (activation may have failed)." -ForegroundColor Yellow
  }
}

function vo { venv off }


# --- Project navigation helpers (repo-aware) ---

function Resolve-RepoRoot {
  param([string]$startPath)

  $p = $startPath
  while ($true) {
    if (Test-Path (Join-Path $p ".git") -PathType Container) { return $p }
    $parent = Split-Path -Parent $p
    if ($parent -eq $p -or [string]::IsNullOrEmpty($parent)) { return $null }
    $p = $parent
  }
}

function root {
  $start = (Get-Location).Path
  $root  = Resolve-RepoRoot $start

  if (-not $root) {
    Write-Host "root: not inside a git repo (no .git found above: $start)" -ForegroundColor Yellow
    return
  }

  Set-Location $root
}

function rt { root }

function front {
  $start = (Get-Location).Path
  $root  = Resolve-RepoRoot $start

  if (-not $root) {
    Write-Host "front: not inside a git repo (no .git found above: $start)" -ForegroundColor Yellow
    return
  }

  # Common layouts (add/remove as you like)
  $candidates = @(
    (Join-Path $root "frontend"),
    (Join-Path $root "app\frontend"),
    (Join-Path $root "application\frontend"),
    (Join-Path $root "src\frontend")
  )

  $target = $candidates | Where-Object { Test-Path $_ -PathType Container } | Select-Object -First 1
  if ($target) { Set-Location $target; return }

  Write-Host "front: no frontend folder found under repo root: $root" -ForegroundColor Yellow
}

function back {
  $start = (Get-Location).Path
  $root  = Resolve-RepoRoot $start

  if (-not $root) {
    Write-Host "back: not inside a git repo (no .git found above: $start)" -ForegroundColor Yellow
    return
  }

  $candidates = @(
    (Join-Path $root "backend"),
    (Join-Path $root "app\backend"),
    (Join-Path $root "application\backend"),
    (Join-Path $root "src\backend")
  )

  $target = $candidates | Where-Object { Test-Path $_ -PathType Container } | Select-Object -First 1
  if ($target) { Set-Location $target; return }

  Write-Host "back: no backend folder found under repo root: $root" -ForegroundColor Yellow
}

function f { front }
function b { back }


# --- deed storage shortcuts ---

$DEED_ROOT = "C:\Users\dawki\OneDrive\Documents\deed_storage"

function deed {
  param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]] $Args
  )

  $path = $DEED_ROOT

  if ($Args.Count -ge 1) {
    $rel = ($Args -join "\")          # join all args into a relative path
    $path = Join-Path $DEED_ROOT $rel
  }

  if (Test-Path -LiteralPath $path) {
    Set-Location $path
    try { & zoxide add $path 2>$null | Out-Null } catch {}
  } else {
    Write-Error "deed: not found: $path"
  }
}

function ds   { deed }            # short
function d14r75 { deed T14R75 }   # one-word jump to your first township folder



# Let Oh My Posh show venv (avoid default "(.venv)" prefix)
$env:VIRTUAL_ENV_DISABLE_PROMPT = "1"

# Oh My Posh cache path (avoid LocalCache write failures)
$env:POSH_PATH = 'C:\projects\profiles\.cache\oh-my-posh'
New-Item -ItemType Directory -Force -Path $env:POSH_PATH | Out-Null

# Oh My Posh (custom theme from repo)
$ompTheme = "C:\projects\profiles\ryan.omp.json"
oh-my-posh init pwsh --config $ompTheme --eval | Invoke-Expression


# --- profile-update managed section (do not edit) ---
# This section is maintained by the profile-update skill.
# Manual edits may be overwritten.

# profile-update: jump plat => C:\projects\Plattera
function plat { Set-Location "C:\projects\Plattera" }

# profile-update: jump ralph => C:\projects\ralph
function ralph {
  param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
  if ($Args.Count -ge 1 -and $Args[0] -ieq "engine") {
    Set-Location "C:\projects\ralph-engine"
    return
  }
  Set-Location "C:\projects\ralph"
}

# profile-update: jump re => C:\projects\ralph-engine
function re { Set-Location "C:\projects\ralph-engine" }

# profile-update: jump prose-ada => C:\projects\stories\prose-ada
function prose-ada { Set-Location "C:\projects\stories\prose-ada" }

# profile-update: jump prosada-app => C:\projects\prosada-app
function prosada-app { Set-Location "C:\projects\prosada-app" }

# --- end profile-update managed section ---
