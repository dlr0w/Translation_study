[CmdletBinding()]
param(
    [string]$DeviceId,
    [switch]$SkipPubGet,
    [switch]$SkipDocker
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$serverDir = Join-Path $repoRoot 'translation_study_app_server'
$flutterDir = Join-Path $repoRoot 'translation_study_app_flutter'
$composeFile = Join-Path $serverDir 'docker-compose.yaml'

function Assert-Command {
    param([Parameter(Mandatory)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found in PATH."
    }
}

function Wait-TcpPort {
    param(
        [Parameter(Mandatory)][string]$HostName,
        [Parameter(Mandatory)][int]$Port,
        [int]$TimeoutSeconds = 90
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        try {
            $client = [System.Net.Sockets.TcpClient]::new()
            $asyncResult = $client.BeginConnect($HostName, $Port, $null, $null)
            if ($asyncResult.AsyncWaitHandle.WaitOne(1000) -and $client.Connected) {
                $client.EndConnect($asyncResult)
                $client.Dispose()
                return
            }
            $client.Dispose()
        }
        catch {
            # The server may still be booting.
        }

        Start-Sleep -Seconds 1
    }

    throw "Server did not start on ${HostName}:$Port within $TimeoutSeconds seconds."
}

Assert-Command 'dart'
Assert-Command 'flutter'

if (-not $SkipDocker) {
    Assert-Command 'docker'
    Write-Host '[1/5] Starting PostgreSQL and Redis...'
    & docker compose -f $composeFile up -d postgres redis
    if ($LASTEXITCODE -ne 0) {
        throw 'docker compose failed.'
    }
}
else {
    Write-Host '[1/5] Skipping Docker startup.'
}

if (-not $SkipPubGet) {
    Write-Host '[2/5] Restoring Dart and Flutter dependencies...'
    Push-Location $repoRoot
    try {
        & dart pub get
        if ($LASTEXITCODE -ne 0) {
            throw 'dart pub get failed.'
        }
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host '[2/5] Skipping dependency restore.'
}

Write-Host '[3/5] Starting Serverpod in a separate PowerShell window...'
$escapedServerDir = $serverDir.Replace("'", "''")
$serverCommand = "Set-Location '$escapedServerDir'; dart run bin/main.dart --apply-migrations"
Start-Process -FilePath 'powershell.exe' -ArgumentList @(
    '-NoExit',
    '-ExecutionPolicy', 'Bypass',
    '-Command', $serverCommand
) | Out-Null

Write-Host '[4/5] Waiting for Serverpod on localhost:8080...'
Wait-TcpPort -HostName 'localhost' -Port 8080

# The Flutter app uses http://localhost:8080. Android devices and emulators
# need port forwarding for localhost to reach the development machine.
$adb = Get-Command 'adb' -ErrorAction SilentlyContinue
if ($null -ne $adb) {
    & adb reverse tcp:8080 tcp:8080 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host 'Configured adb reverse for port 8080.'
    }
}

Write-Host '[5/5] Starting Flutter...'
Push-Location $flutterDir
try {
    $flutterArgs = @('run')
    if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
        $flutterArgs += @('-d', $DeviceId)
    }

    & flutter @flutterArgs
    if ($LASTEXITCODE -ne 0) {
        throw 'flutter run failed.'
    }
}
finally {
    Pop-Location
}
