// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage_suppression.dart';

const _tracerName = 'otel_flutter_secure_storage';
const _storageSystem = 'flutter_secure_storage';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

/// Generic helper. Opens a CLIENT span named
/// `secure_storage <operation> [<key>]` carrying
/// `storage.system=flutter_secure_storage`,
/// `storage.operation=<operation>`, and `storage.key=<key>` (when
/// supplied). **Never records the value.**
Future<R> tracedSecureStorageCall<R>({
  required String operation,
  String? key,
  required Future<R> Function() invoke,
}) async {
  if (secureStorageInstrumentationSuppressed()) return invoke();
  final span = _tracer().startSpan(
    key == null
        ? 'secure_storage $operation'
        : 'secure_storage $operation $key',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(<String, Object>{
      'storage.system': _storageSystem,
      'storage.operation': operation,
      if (key != null) 'storage.key': key,
    }),
  );
  try {
    return await invoke();
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

/// Traced operations on [FlutterSecureStorage].
///
/// **The stored value never appears in the span** — by definition,
/// secure storage holds credentials and sensitive data. Only the
/// key, operation, and result presence/absence (for read) are
/// recorded.
extension OTelFlutterSecureStorage on FlutterSecureStorage {
  /// Traced `write`. Adds `storage.value.present` = (value != null).
  Future<void> tracedWrite({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    return tracedSecureStorageCall<void>(
      operation: 'write',
      key: key,
      invoke: () => write(
        key: key,
        value: value,
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      ),
    );
  }

  /// Traced `read`. Result presence is not surfaced as a span
  /// attribute — that could leak whether a particular key exists.
  Future<String?> tracedRead({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    return tracedSecureStorageCall<String?>(
      operation: 'read',
      key: key,
      invoke: () => read(
        key: key,
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      ),
    );
  }

  /// Traced `delete`.
  Future<void> tracedDelete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    return tracedSecureStorageCall<void>(
      operation: 'delete',
      key: key,
      invoke: () => delete(
        key: key,
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      ),
    );
  }

  /// Traced `deleteAll`.
  Future<void> tracedDeleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    return tracedSecureStorageCall<void>(
      operation: 'deleteAll',
      invoke: () => deleteAll(
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      ),
    );
  }

  /// Traced `containsKey`.
  Future<bool> tracedContainsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) {
    return tracedSecureStorageCall<bool>(
      operation: 'containsKey',
      key: key,
      invoke: () => containsKey(
        key: key,
        iOptions: iOptions,
        aOptions: aOptions,
        lOptions: lOptions,
        webOptions: webOptions,
        mOptions: mOptions,
        wOptions: wOptions,
      ),
    );
  }
}
