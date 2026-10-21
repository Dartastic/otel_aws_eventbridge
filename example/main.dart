// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_aws_eventbridge/otel_aws_eventbridge.dart';

/// Traces Aws Eventbridge calls with OpenTelemetry.
///
/// `otel_aws_eventbridge` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Aws Eventbridge call in
/// [tracedAwsEventBridge]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'aws-eventbridge-example');

  // Traces a Aws Eventbridge call.
  final awsEventBridgeId = await tracedAwsEventBridge<String>(
    operation: 'create',
    invoke: () async {
      // Make the Aws Eventbridge call here, then report what it returned.
      const id = 'aws_eventbridge_8f3a2c';
      return const AwsEventBridgeCallResult(
          value: id,
          result: AwsEventBridgeResult(
              busName: 'example',
              ruleName: 'example',
              eventId: 'event_8f3a2c',
              source: 'example',
              detailType: 'standard',
              target: 'example',
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAwsEventBridge create returned $awsEventBridgeId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAwsEventBridgeInstrumentationAsync.
  await runWithoutAwsEventBridgeInstrumentationAsync(
    () => tracedAwsEventBridge<String>(
      operation: 'create',
      invoke: () async {
        const id = 'aws_eventbridge_8f3a2c';
        return const AwsEventBridgeCallResult(
            value: id,
            result: AwsEventBridgeResult(
                busName: 'example',
                ruleName: 'example',
                eventId: 'event_8f3a2c',
                source: 'example',
                detailType: 'standard',
                target: 'example',
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
