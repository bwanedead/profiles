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
    z prose ada
    return
  }

  if ($Args[0] -eq "app") {
    if ($Args.Count -eq 1) {
      Set-Location "C:\projects\prose-ada\application"
      return
    }
    $sub = $Args[1]
    if ($sub -in "b", "back", "backend") {
      Set-Location "C:\projects\prose-ada\application\backend"
      return
    }
    if ($sub -in "f", "front", "frontend") {
      Set-Location "C:\projects\prose-ada\application\frontend"
      return
    }
  }

  z prose ada @Args
}

function sinap     { z sinap }

function scriptara { z scriptara }           # matches the OneDrive path
function sc        { z scriptara }

function chessterra { z chessterra }
function chess      { z chessterra }

function algent    { z algent }

# --- venv helpers ---
function venv {
  if (Test-Path ".\.venv\Scripts\Activate.ps1") {
    Write-Host "Activating local .venv..." -ForegroundColor Cyan
    .\.venv\Scripts\Activate.ps1
  } elseif (Test-Path "C:\projects\prose-ada\application\.venv\Scripts\Activate.ps1") {
    Write-Host "Activating application .venv..." -ForegroundColor Cyan
    C:\projects\prose-ada\application\.venv\Scripts\Activate.ps1
  } else {
    Write-Error "No .venv found in current directory or C:\projects\prose-ada\application\"
  }
}

# --- Project navigation helpers ---
function front {
  if (Test-Path "frontend" -PathType Container) {
    Set-Location "frontend"
  } elseif (Test-Path "src/frontend" -PathType Container) {
    Set-Location "src/frontend"
  } else {
    Write-Host "No 'frontend' directory found here." -ForegroundColor Yellow
  }
}

function back {
  if (Test-Path "backend" -PathType Container) {
    Set-Location "backend"
  } elseif (Test-Path "src/backend" -PathType Container) {
    Set-Location "src/backend"
  } else {
    Write-Host "No 'backend' directory found here." -ForegroundColor Yellow
  }
}

function f { front }
function b { back }

function go {
  param(
    [Parameter(Position=0)]
    [string]$target
  )
  if ($target -in "f", "front") { front }
  elseif ($target -in "b", "back") { back }
  else { Write-Host "Usage: go f | go b" -ForegroundColor Cyan }
}

