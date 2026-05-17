# otel_aws_eventbridge

Dartastic OpenTelemetry bridge for AWS EventBridge (event bus).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_aws_eventbridge/otel_aws_eventbridge.dart';

await tracedAwsEventBridge<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AwsEventBridgeCallResult(value: r, result: AwsEventBridgeResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAwsEventBridgeInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
