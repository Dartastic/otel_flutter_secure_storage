# otel_flutter_secure_storage example

```dart
// example/lib/main.dart

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:otel_flutter_secure_storage/otel_flutter_secure_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Bring up OTel before touching storage so every traced call
  //    lands in a live tracer provider.
  await OTel.initialize(
    serviceName: 'secure-storage-demo',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LoginPage());
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _storage = FlutterSecureStorage();

  Future<void> _onLoggedIn(String token) async {
    // ✨ Span: `secure_storage write auth.token`
    //
    //    Attributes: storage.system, storage.operation, storage.key.
    //    The token VALUE is never recorded — secure storage holds
    //    credentials, and leaking them into traces would defeat the
    //    point.
    await _storage.tracedWrite(key: 'auth.token', value: token);
  }

  Future<String?> _restoreSession() {
    // ✨ Span: `secure_storage read auth.token`
    //
    //    Result presence is intentionally NOT surfaced either — that
    //    could leak whether a particular key exists.
    return _storage.tracedRead(key: 'auth.token');
  }

  Future<void> _onLogout() async {
    // ✨ Span: `secure_storage delete auth.token`
    await _storage.tracedDelete(key: 'auth.token');

    // ✨ Span: `secure_storage deleteAll` (no storage.key attribute)
    await _storage.tracedDeleteAll();
  }

  Future<void> _quietMigration() {
    // Need a storage sweep with no spans at all (not even keys)?
    // Wrap it in the suppression scope:
    return runWithoutSecureStorageInstrumentationAsync(() async {
      await _storage.tracedWrite(key: 'migrated', value: 'true');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _onLoggedIn('s3cr3t'),
          child: const Text('Log in'),
        ),
      ),
    );
  }
}
```

## Trace shape

```
POST /login (your code)
  secure_storage write auth.token
      storage.system = flutter_secure_storage
      storage.operation = write
      storage.key = auth.token

(on app restart)
  secure_storage read auth.token

(on logout)
  secure_storage delete auth.token
  secure_storage deleteAll        <- no storage.key
```

The stored value never appears on any span.
