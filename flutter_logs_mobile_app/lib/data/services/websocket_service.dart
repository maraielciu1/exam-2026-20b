import 'dart:convert';

import 'package:flutter_logs_mobile_app/core/constants.dart';
import 'package:flutter_logs_mobile_app/core/logger.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel connect() {
    final uri = Uri.parse(getWebSocketUrl());
    AppLogger.info('WebSocket connect $uri');
    return IOWebSocketChannel.connect(
      uri,
      pingInterval: const Duration(seconds: 10),
    );
  }

  LogEntry? parseLog(dynamic message) {
    try {
      if (message is String) {
        final data = jsonDecode(message) as Map<String, dynamic>;
        return LogEntry.fromJson(data);
      }
    } catch (_) {
      AppLogger.error('WebSocket message parse failed', message);
      return null;
    }
    return null;
  }
}
