# Song List

Flutter song-board application backed by Supabase.

## Local configuration

Copy `dart_defines.example.json` to `dart_defines.local.json`, then replace
the placeholders with public client configuration:

```powershell
Copy-Item dart_defines.example.json dart_defines.local.json
flutter run --dart-define-from-file=dart_defines.local.json
```

If you still have the legacy `.env`, generate the safe local file without
copying its server secrets:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File .\tool\create_local_config.ps1
```

Running plain `flutter run` without these values shows a configuration screen
instead of starting the application.

Only browser/mobile-safe values belong in this file. Never add database
passwords, OAuth client secrets, service-role keys, or other server secrets.
Set `SUBSCRIPTION_PORTAL_URL` to the public HTTPS page where users can purchase
or manage their subscription.

VS Code's `Song List (local)` launch configuration supplies this file
automatically. Use the same option for other run and build commands.
