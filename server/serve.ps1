$LlamaServer = Get-ChildItem `
    "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" `
    -Recurse `
    -Filter "llama-server.exe" |
    Select-Object -First 1 -ExpandProperty FullName

if (-not $LlamaServer) {
    throw "Could not locate llama-server.exe."
}

$Args = @(
    "--host", "0.0.0.0",
    "--port", "8080",
    "--models-max", "1",
    "--models-preset", "$PSScriptRoot\models.ini",
    "--log-file", "$PSScriptRoot\logs.txt",
    "--no-mmap"
    "--no-mmproj"
)

& $LlamaServer @Args