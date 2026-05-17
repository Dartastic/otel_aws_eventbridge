// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_aws_eventbridge_suppression.dart';

class AwsEventBridgeResult {
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

class AwsEventBridgeCallResult<T> {
  const AwsEventBridgeCallResult({required this.value, this.result});
  final T value;
  final AwsEventBridgeResult? result;
}

Future<T> tracedAwsEventBridge<T>({
  required String operation,
  required Future<AwsEventBridgeCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (awsEventBridgeInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_aws_eventbridge');
  final span = t.startSpan('eventbridge $operation', kind: SpanKind.producer);
  try {
    span.setStringAttribute('messaging.system', 'aws_eventbridge');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.busName != null) {
        span.setStringAttribute('messaging.destination.name', res.busName!);
      }
      if (res.ruleName != null) {
        span.setStringAttribute('aws.eventbridge.rule', res.ruleName!);
      }
      if (res.eventId != null) {
        span.setStringAttribute('messaging.message.id', res.eventId!);
      }
      if (res.source != null) {
        span.setStringAttribute('aws.eventbridge.source', res.source!);
      }
      if (res.detailType != null) {
        span.setStringAttribute('aws.eventbridge.detail_type', res.detailType!);
      }
      if (res.target != null) {
        span.setStringAttribute('aws.eventbridge.target', res.target!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('eventbridge.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'eventbridge.error',
        );
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
