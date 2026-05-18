// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_aws_eventbridge/otel_aws_eventbridge.dart';
import 'package:test/test.dart';

void main() {
  group('otel_aws_eventbridge', () {
    test('suppression toggles in zone', () async {
      expect(awsEventBridgeInstrumentationSuppressed(), isFalse);
      await runWithoutAwsEventBridgeInstrumentationAsync(() async {
        expect(awsEventBridgeInstrumentationSuppressed(), isTrue);
      });
      expect(awsEventBridgeInstrumentationSuppressed(), isFalse);
    });

    test('AwsEventBridgeResult fields default null', () {
      const r = AwsEventBridgeResult();
      expect(r.statusCode, isNull);
    });
  });
}
