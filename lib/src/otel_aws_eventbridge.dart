// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_eventbridge_suppression.dart';

class AwsEventBridgeResult {
  /// Creates a result.
  const AwsEventBridgeResult({
    this.busName,
    this.ruleName,
    this.eventId,
    this.source,
    this.detailType,
    this.target,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? busName;
  final String? ruleName;
  final String? eventId;
  final String? source;
  final String? detailType;
  final String? target;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AwsEventBridgeCallResult<T> {
  /// Creates a call result.
  const AwsEventBridgeCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AwsEventBridgeResult? result;
}

Future<T> tracedAwsEventBridge<T>({
  required String operation,
  required Future<AwsEventBridgeCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (awsEventBridgeInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t =
      tracer ?? OTelAPI.tracerProvider().getTracer('otel_aws_eventbridge');
  final span = t.startSpan('eventbridge $operation', kind: SpanKind.producer);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('messaging.system', 'aws_eventbridge')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.busName != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('messaging.destination.name', res.busName!)
        ]));
      }
      if (res.ruleName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.eventbridge.rule', res.ruleName!)]));
      }
      if (res.eventId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('messaging.message.id', res.eventId!)]));
      }
      if (res.source != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.eventbridge.source', res.source!)]));
      }
      if (res.detailType != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
              'aws.eventbridge.detail_type', res.detailType!)
        ]));
      }
      if (res.target != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('aws.eventbridge.target', res.target!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('eventbridge.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'eventbridge.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
