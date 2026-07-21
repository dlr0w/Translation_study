# 開発用スクリプト

## モバイルアプリを起動する

リポジトリのルートディレクトリで、PowerShellから次のコマンドを実行します。

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-dev.ps1
```

スクリプトは以下の処理を順番に実行します。

1. Docker ComposeでPostgreSQLとRedisを起動します。
2. ワークスペース全体に対して`dart pub get`を実行します。
3. 別のPowerShellウィンドウで、マイグレーションを適用してServerpodサーバーを起動します。
4. ポート`8080`でサーバーが起動するまで待機します。
5. Android Debug Bridgeを利用できる場合は、`adb reverse`を設定します。
6. Flutterアプリを起動します。

複数の端末が接続されている場合、Flutterの端末選択が表示されます。起動する端末を明示的に指定する場合は、次のように実行します。

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-dev.ps1 -DeviceId emulator-5554
```

2回目以降の起動で依存関係の取得を省略する場合は、`-SkipPubGet`を指定します。

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-dev.ps1 -SkipPubGet
```

PostgreSQLとRedisがすでに起動している場合は、Dockerの起動処理も省略できます。

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-dev.ps1 -SkipDocker -SkipPubGet
```

## 開発環境を停止する

Flutterは`q`または`Ctrl+C`で停止します。

Serverpodを起動したPowerShellウィンドウを閉じた後、次のコマンドでPostgreSQLとRedisのコンテナを停止します。

```powershell
docker compose -f .\translation_study_app_server\docker-compose.yaml down
```
