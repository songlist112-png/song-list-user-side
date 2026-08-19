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

## Offline synchronization

The mobile client uses incremental offline-first synchronization:

- A new account receives boards and columns first, then songs in resumable
  500-record pages. Each page is committed with one bulk Isar transaction so
  the board UI can be used while remaining pages continue in the background.
- Existing accounts request only rows changed or deleted after their last
  successful server watermark. Pagination uses the stable
  `(updated_at, id)` cursor instead of offsets.
- Sync metadata stores a cache contract version and an in-progress cursor. A
  cache-version bump safely starts a new initial pull without deleting pending
  local mutations.
- Attachment metadata is synchronized with each song. File bytes are only
  downloaded when the user opens an attachment.

Deploy `supabase/migrations/20260819000000_incremental_batched_sync.sql`
before releasing a client that uses this protocol. The migration adds the
secure pull RPCs, cursor indexes, tombstone ownership, and relationship
triggers required for complete incremental updates.
