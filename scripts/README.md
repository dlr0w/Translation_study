# Development scripts

## Start the mobile app

Run this command from the repository root in PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-dev.ps1
```

The script performs the following steps:

1. Starts PostgreSQL and Redis with Docker Compose.
2. Runs `dart pub get` for the workspace.
3. Starts the Serverpod server with migrations in a separate PowerShell window.
4. Waits for port `8080` to become available.
5. Configures `adb reverse` when Android Debug Bridge is available.
6. Runs the Flutter application.

Flutter displays its device selector when multiple devices are available. To select a device explicitly:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-dev.ps1 -DeviceId emulator-5554
```

For faster subsequent starts, skip dependency restoration:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-dev.ps1 -SkipPubGet
```

When PostgreSQL and Redis are already running:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-dev.ps1 -SkipDocker -SkipPubGet
```

## Stop the environment

Stop Flutter with `q` or `Ctrl+C`, close the Serverpod PowerShell window, and stop the containers with:

```powershell
docker compose -f .\translation_study_app_server\docker-compose.yaml down
```
