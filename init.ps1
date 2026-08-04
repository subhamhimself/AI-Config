#Requires -Version 5.1
<#
.SYNOPSIS
    One-shot setup: installs Claude Code, then applies config.

    Prerequisite: you must be on Subham Pathak's Tailscale network.

    Single command:
      irm https://raw.githubusercontent.com/subhamhimself/AI-Config/main/init.ps1 | iex
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- 1. Install / upgrade Claude Code ---
Write-Host "[*] Installing Claude Code..."
irm https://claude.ai/install.ps1 | iex

# --- 2. Apply Claude Code settings ---
$ConfigUrl = 'https://raw.githubusercontent.com/subhamhimself/AI-Config/main/claude-settings.json'
$Dir = Join-Path $env:USERPROFILE '.claude'
$Path = Join-Path $Dir 'settings.json'

if (-not (Test-Path $Dir)) {
    New-Item -ItemType Directory -Path $Dir -Force | Out-Null
}

$raw = Invoke-RestMethod -Uri $ConfigUrl
$raw | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -NoNewline
Write-Host "[+] Applied settings -> $Path"

# --- 3. Ensure claude is on PATH ---
$candidates = @(
    "$env:USERPROFILE\.local\bin"
    "$env:APPDATA\npm"
    "$env:LOCALAPPDATA\Programs\Claude\bin"
    "$env:USERPROFILE\.claude\bin"
)

$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$added = $false

foreach ($bin in $candidates) {
    if (Test-Path $bin) {
        if ($currentPath -notlike "*$bin*") {
            [Environment]::SetEnvironmentVariable('Path', "$currentPath;$bin", 'User')
            $env:Path = "$env:Path;$bin"
            Write-Host "[+] Added $bin to user PATH"
            $added = $true
        } else {
            Write-Host "[+] $bin already on PATH"
        }
    }
}

if (-not $added) {
    Write-Host "[!] Could not locate a claude binary directory — PATH was not changed."
}

Write-Host "`n[+] Done."
