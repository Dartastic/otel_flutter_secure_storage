// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'dart:async';

const Symbol _suppressKey = #otel_flutter_secure_storage_suppress;

/// Whether secure-storage instrumentation is suppressed in the
/// current [Zone] (see [runWithoutSecureStorageInstrumentation]).
bool secureStorageInstrumentationSuppressed() {
  return Zone.current[_suppressKey] == true;
}

/// Runs [body] with secure-storage instrumentation suppressed:
/// `traced*` calls inside it invoke the underlying operation
/// without opening a span.
T runWithoutSecureStorageInstrumentation<T>(T Function() body) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}

/// Async variant of [runWithoutSecureStorageInstrumentation].
Future<T> runWithoutSecureStorageInstrumentationAsync<T>(
  Future<T> Function() body,
) {
  return runZoned(body, zoneValues: {_suppressKey: true});
}
