# reinit.ps1 — Teardown and rebuild the sandbox from scratch.
# Run from: d:\AI Config\Sandbox

$SandboxRoot = $PSScriptRoot
$ComposeFile = Join-Path $SandboxRoot "docker-compose.yml"

Write-Host ">>> Stopping and removing existing container..." -ForegroundColor Cyan
docker compose -f $ComposeFile down --remove-orphans 2>$null | Out-Null

Write-Host ">>> Removing old image..." -ForegroundColor Cyan
docker rmi -f ubuntu-dev 2>$null | Out-Null

Write-Host ">>> Building fresh image..." -ForegroundColor Cyan
$buildResult = docker compose -f $ComposeFile build --no-cache 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed:" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
    exit 1
}

Write-Host ">>> Starting container..." -ForegroundColor Cyan
$upResult = docker compose -f $ComposeFile up -d 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to start container:" -ForegroundColor Red
    Write-Host $upResult -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host ">>> Sandbox re-initialized." -ForegroundColor Green
Write-Host "    SSH : root@localhost -p 2222 (no password)" -ForegroundColor Yellow
Write-Host ""
Write-Host ">>> Live logs (Ctrl+C to detach)..." -ForegroundColor Cyan
docker logs -f ubuntu-dev
