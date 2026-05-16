# otel_flutter_secure_storage

OpenTelemetry instrumentation for
[`package:flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage).

```dart
final fss = FlutterSecureStorage();

await fss.tracedWrite(key: 'auth.token', value: token);
final t = await fss.tracedRead(key: 'auth.token');
await fss.tracedDelete(key: 'auth.token');
await fss.tracedDeleteAll();
```

Each call emits a CLIENT span:

- name: `secure_storage <op> <key>`
- `storage.system = flutter_secure_storage`
- `storage.operation = write` / `read` / `delete` / `deleteAll` / `containsKey`
- `storage.key = <key>` (omitted on `deleteAll`)

## Privacy

**The stored value never appears on the span.** Secure storage
is for credentials, tokens, and other sensitive data — leaking
it into traces would defeat the purpose.

For `tracedRead`, the result presence is also intentionally not
surfaced — that could leak whether a particular key exists.

If you want even less detail (no keys either), use the
suppression scope:

```dart
await runWithoutSecureStorageInstrumentationAsync(() async {
  await fss.tracedRead(key: 'auth.token');
});
```

## License

Apache 2.0
