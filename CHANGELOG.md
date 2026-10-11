# Changelog

## [0.3.1-wip]

## [0.3.0] - 2026-10-11

### Changed

- Requires `dartastic_opentelemetry_api >=1.0.0-rc.4 <1.0.0-rc.5`.
- **Breaking:** depends on `dartastic_opentelemetry_api` only, no
  longer on the SDK. The application chooses and initializes the
  OpenTelemetry SDK. Parameters and fields typed with SDK classes
  now use the API types (`APITracer`, `APISpan`, `APILogger`, ...);
  SDK instances are still accepted wherever an API type is expected.

## [0.2.0] - 2026-08-10

### Changed

- `flutter_secure_storage` constraint widened to `>=9.0.0 <12.0.0`
  (verified against 9.2.4 and 11.0.0).
- `storage.*` attribute keys are now the exported
  `SecureStorageSemantics` enum (`OTelSemantic`) instead of raw
  string literals. Emitted keys are unchanged.

### Added

- `example/example.md`.
- Dartdoc for the suppression API.

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
