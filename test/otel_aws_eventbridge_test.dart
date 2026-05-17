// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

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
