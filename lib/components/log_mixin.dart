// https://www.vojtech.net/posts/better-logs-flutter/
import 'dart:async';
import 'dart:developer' as dev;

mixin LogMixin on Object {
  String get _className => runtimeType.toString();

  void log(
    String message, {
    // DateTime? time,
    int? sequenceNumber,
    int level = 0,
    String? name,
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      name: name ?? _className,
      time: DateTime.now(),
      sequenceNumber: sequenceNumber,
      level: level,
      zone: zone,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
