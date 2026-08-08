// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// Key-value-store attribute keys for `FlutterSecureStorage`.
enum SecureStorageSemantics implements OTelSemantic {
  /// `storage.system` — constant `flutter_secure_storage`.
  system('storage.system'),

  /// `storage.operation` — `write` / `read` / `delete` /
  /// `deleteAll` / `containsKey`.
  operation('storage.operation'),

  /// `storage.key` — the secure-storage key being accessed.
  /// The stored **value** is never recorded.
  storageKey('storage.key');

  @override
  final String key;

  @override
  String toString() => key;

  const SecureStorageSemantics(this.key);
}
