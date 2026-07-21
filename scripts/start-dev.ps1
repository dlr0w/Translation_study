[CmdletBinding()]
param(
    # flutter run で使用する端末ID。未指定の場合はFlutterの端末選択に任せる。
    [string]$DeviceId,

    # 指定した場合、依存関係の取得を省略する。
    [switch]$SkipPubGet,

    # 指定した場合、PostgreSQLとRedisの起動を省略する。
    [switch]$SkipDocker
)

# エラー発生時に処理を継続せず、即座に停止する。
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

# このスクリプトの配置場所を基準に、各プロジェクトのパスを解決する。
$repoRoot = Split-Path -Parent $PSScriptRoot
$serverDir = Join-Path $repoRoot 'translation_study_app_server'
$flutterDir = Join-Path $repoRoot 'translation_study_app_flutter'
$composeFile = Join-Path $serverDir 'docker-compose.yaml'

# 必要なコマンドがPATH上に存在することを確認する。
function Assert-Command {
    param([Parameter(Mandatory)][string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "必要なコマンド '$Name' がPATHに見つかりません。"
    }
}

# 指定したTCPポートが接続可能になるまで待機する。
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
            # サーバー起動中は接続に失敗するため、そのまま再試行する。
        }

        Start-Sleep -Seconds 1
    }

    throw "${HostName}:$Port が $TimeoutSeconds 秒以内に起動しませんでした。"
}

# DartとFlutterが実行可能か確認する。
Assert-Command 'dart'
Assert-Command 'flutter'

# PostgreSQLとRedisをDocker Composeで起動する。
if (-not $SkipDocker) {
    Assert-Command 'docker'
    Write-Host '[1/5] PostgreSQLとRedisを起動しています...'
    & docker compose -f $composeFile up -d postgres redis
    if ($LASTEXITCODE -ne 0) {
        throw 'docker composeの実行に失敗しました。'
    }
}
else {
    Write-Host '[1/5] Dockerの起動を省略します。'
}

# ワークスペース全体のDart・Flutter依存関係を取得する。
if (-not $SkipPubGet) {
    Write-Host '[2/5] DartとFlutterの依存関係を取得しています...'
    Push-Location $repoRoot
    try {
        & dart pub get
        if ($LASTEXITCODE -ne 0) {
            throw 'dart pub getの実行に失敗しました。'
        }
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host '[2/5] 依存関係の取得を省略します。'
}

# Serverpodを別のPowerShellウィンドウで起動し、マイグレーションを適用する。
Write-Host '[3/5] Serverpodを別のPowerShellウィンドウで起動しています...'
$escapedServerDir = $serverDir.Replace("'", "''")
$serverCommand = "Set-Location '$escapedServerDir'; dart run bin/main.dart --apply-migrations"
Start-Process -FilePath 'powershell.exe' -ArgumentList @(
    '-NoExit',
    '-ExecutionPolicy', 'Bypass',
    '-Command', $serverCommand
) | Out-Null

# Flutter起動前に、Serverpodの8080番ポートが利用可能になるまで待機する。
Write-Host '[4/5] Serverpod（localhost:8080）の起動を待機しています...'
Wait-TcpPort -HostName 'localhost' -Port 8080

# Flutterアプリはlocalhost:8080へ接続する。
# Android端末・エミュレーターから開発PCのlocalhostへ接続できるよう、ポート転送を設定する。
$adb = Get-Command 'adb' -ErrorAction SilentlyContinue
if ($null -ne $adb) {
    & adb reverse tcp:8080 tcp:8080 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host 'adb reverseで8080番ポートを転送しました。'
    }
}

# 指定された端末、またはFlutterが選択した端末でアプリを起動する。
Write-Host '[5/5] Flutterアプリを起動しています...'
Push-Location $flutterDir
try {
    $flutterArgs = @('run')
    if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
        $flutterArgs += @('-d', $DeviceId)
    }

    & flutter @flutterArgs
    if ($LASTEXITCODE -ne 0) {
        throw 'flutter runの実行に失敗しました。'
    }
}
finally {
    Pop-Location
}
