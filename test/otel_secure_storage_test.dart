// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otel_flutter_secure_storage/otel_flutter_secure_storage.dart';

class _MemorySpanExporter implements SpanExporter {
  final List<Span> spans = [];
  bool _shutdown = false;

  @override
  Future<void> export(List<Span> s) async {
    if (_shutdown) return;
    spans.addAll(s);
  }

  @override
  Future<void> forceFlush() async {}

  @override
  Future<void> shutdown() async {
    _shutdown = true;
  }
}

Map<String, Object> _attrs(Span span) =>
    {for (final a in span.attributes.toList()) a.key: a.value};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('tracedSecureStorageCall', () {
    late _MemorySpanExporter exporter;

    setUp(() async {
      await OTel.reset();
      exporter = _MemorySpanExporter();
      await OTel.initialize(
        serviceName: 'secure-storage-otel-test',
        detectPlatformResources: false,
        spanProcessor: SimpleSpanProcessor(exporter),
      );
    });

    tearDown(() async {
      await OTel.shutdown();
      await OTel.reset();
    });

    test('emits CLIENT span with storage.* attrs + key, NEVER value', () async {
      await tracedSecureStorageCall<void>(
        operation: 'write',
        key: 'auth.token',
        invoke: () async {},
      );

      final span = exporter.spans.single;
      expect(span.kind, equals(SpanKind.client));
      expect(span.name, equals('secure_storage write auth.token'));
      final attrs = _attrs(span);
      expect(attrs['storage.system'], equals('flutter_secure_storage'));
      expect(attrs['storage.operation'], equals('write'));
      expect(attrs['storage.key'], equals('auth.token'));
      // Verify no value-shaped attribute leaked.
      expect(
        attrs.keys.where((k) => k.contains('value')).toList(),
        isEmpty,
      );
    });

    test('operation without key (e.g. deleteAll) omits storage.key', () async {
      await tracedSecureStorageCall<void>(
        operation: 'deleteAll',
        invoke: () async {},
      );

      final span = exporter.spans.single;
      expect(span.name, equals('secure_storage deleteAll'));
      expect(_attrs(span).containsKey('storage.key'), isFalse);
    });

    test('exception flips span to Error', () async {
      await expectLater(
        tracedSecureStorageCall<void>(
          operation: 'read',
          key: 'k',
          invoke: () async => throw StateError('keychain locked'),
        ),
        throwsStateError,
      );

      final span = exporter.spans.single;
      expect(span.status, equals(SpanStatusCode.Error));
      expect(_attrs(span)['error.type'], equals('StateError'));
    });

    test('runWithoutSecureStorageInstrumentationAsync bypasses spans',
        () async {
      await runWithoutSecureStorageInstrumentationAsync(() async {
        await tracedSecureStorageCall<void>(
          operation: 'write',
          key: 'k',
          invoke: () async {},
        );
      });
      expect(exporter.spans, isEmpty);
    });
  });
}
