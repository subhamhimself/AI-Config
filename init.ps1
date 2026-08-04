#Requires -Version 5.1
<#
.SYNOPSIS
    Applies Claude Code config (settings + PATH).

    Prerequisite: you must be on Subham Pathak's Tailscale network.
    Run after installing Claude Code.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# --- Apply Claude Code settings ---
$ConfigUrl = 'https://raw.githubusercontent.com/subhamhimself/AI-Config/main/claude-settings.json'
$Dir = Join-Path $env:USERPROFILE '.claude'
$Path = Join-Path $Dir 'settings.json'

if (-not (Test-Path $Dir)) {
    New-Item -ItemType Directory -Path $Dir -Force | Out-Null
}

$raw = Invoke-RestMethod -Uri $ConfigUrl
$raw | ConvertTo-Json -Depth 10 | Set-Content -Path $Path -NoNewline
Write-Host "[+] Applied settings -> $Path"

# --- Ensure claude is on PATH ---
$candidates = @(
    "$env:USERPROFILE\.local\bin"
    "$env:APPDATA\npm"
    "$env:LOCALAPPDATA\Programs\Claude\bin"
    "$env:USERPROFILE\.claude\bin"
)

$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$found = $false

foreach ($bin in $candidates) {
    if (Test-Path $bin) {
        $found = $true
        if ($currentPath -notlike "*$bin*") {
            [Environment]::SetEnvironmentVariable('Path', "$currentPath;$bin", 'User')
            $env:Path = "$env:Path;$bin"
            Write-Host "[+] Added $bin to user PATH"
        } else {
            Write-Host "[+] $bin already on PATH"
        }
    }
}

if (-not $found) {
    Write-Host "[!] Could not locate a claude binary directory — PATH was not changed."
}

Write-Host "`n[+] Done."
