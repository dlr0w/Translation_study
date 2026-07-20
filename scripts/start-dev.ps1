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
$composeFile = Join-