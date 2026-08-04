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

# --- Install RTK (Rust Token Killer) ---
Write-Host "`n[*] Installing RTK..."

$rtkBinDir = Join-Path $env:USERPROFILE '.local\bin'

# Check if rtk is already available
$existingRtk = Get-Command rtk -ErrorAction SilentlyContinue
if ($existingRtk) {
    Write-Host "[+] RTK already found at $($existingRtk.Source)"
} else {
    # Fetch latest release tag from GitHub API
    try {
        $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/rtk-ai/rtk/releases/latest'
        $tagName = $release.tag_name

        # Find the Windows zip asset
        $winAsset = $release.assets | Where-Object { $_.name -match 'pc-windows.*\.zip$' } | Select-Object -First 1
        if (-not $winAsset) {
            Write-Host "[!] Could not find a Windows zip asset in release $tagName — skipping RTK install."
        } else {
            Write-Host "[*] Downloading $($winAsset.name)..."

            if (-not (Test-Path $rtkBinDir)) {
                New-Item -ItemType Directory -Path $rtkBinDir -Force | Out-Null
            }

            $zipPath = Join-Path $env:TEMP 'rtk-latest.zip'
            Invoke-WebRequest -Uri $winAsset.browser_download_url -OutFile $zipPath -UseBasicParsing | Out-Null

            $extractDir = Join-Path $env:TEMP "rtk-$tagName"
            Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

            # Find the .exe in the extracted folder and copy to bin dir
            $exeFiles = Get-ChildItem -Path $extractDir -Filter '*.exe' -Recurse
            foreach ($exe in $exeFiles) {
                Copy-Item -Path $exe.FullName -Destination $rtkBinDir -Force
                Write-Host "[+] Copied $($exe.Name) -> $rtkBinDir"
            }

            # Clean up temp files
            Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
            Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue

            # Refresh PATH so we can verify
            $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
        }
    } catch {
        Write-Host "[!] Failed to install RTK: $_"
    }

    # Verify installation
    $verifyRtk = Get-Command rtk -ErrorAction SilentlyContinue
    if ($verifyRtk) {
        Write-Host "[+] RTK installed successfully"
    } else {
        Write-Host "[!] RTK install may have failed — check that $rtkBinDir is on your PATH."
    }
}

Write-Host ""
Write-Host "[+] Done."
