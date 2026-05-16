# Changelog

## [0.1.0-beta.2-wip]

## [0.1.0-beta.1] - 2026-05-16

### Added

- Extension methods on `FlutterSecureStorage`: `tracedWrite`,
  `tracedRead`, `tracedDelete`, `tracedDeleteAll`,
  `tracedContainsKey`. Each opens a CLIENT span named
  `secure_storage <op> <key>` with
  `storage.system=flutter_secure_storage`, `storage.operation`,
  `storage.key`.
- **Values are never recorded** on the span — by definition,
  secure storage holds credentials and sensitive data.
- `tracedSecureStorageCall<R>({operation, key, invoke})` —
  generic helper for testing or custom backends.
- Zone-scoped suppression
  (`runWithoutSecureStorageInstrumentation` and the async
  variant).
- 4 tests via the generic helper (span shape with key, span
  shape without key, exception path, suppression scope).
