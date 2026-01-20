import 'dart:convert';

import 'package:flutter_logs_mobile_app/core/constants.dart';
import 'package:flutter_logs_mobile_app/core/logger.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<LogEntry>> getLogs() async {
    final url = Uri.parse('${getBaseUrl()}/logs');
    AppLogger.info('GET $url');
    final response = await _client.get(url);
    if (response.statusCode != 200) {
      AppLogger.error('GET /logs failed', response.statusCode);
      throw Exception('Failed to load logs');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => LogEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<LogEntry> getLog(int id) async {
    final url = Uri.parse('${getBaseUrl()}/log/$id');
    AppLogger.info('GET $url');
    final response = await _client.get(url);
    if (response.statusCode != 200) {
      AppLogger.error('GET /log/$id failed', response.statusCode);
      throw Exception('Failed to load log');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return LogEntry.fromJson(data);
  }

  Future<LogEntry> createLog(LogDraft draft) async {
    final url = Uri.parse('${getBaseUrl()}/log');
    AppLogger.info('POST $url');
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(draft.toJson()),
    );
    if (response.statusCode != 201) {
      AppLogger.error('POST /log failed', response.statusCode);
      throw Exception('Failed to create log');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return LogEntry.fromJson(data);
  }

  Future<void> deleteLog(int id) async {
    final url = Uri.parse('${getBaseUrl()}/log/$id');
    AppLogger.info('DELETE $url');
    final response = await _client.delete(url);
    if (response.statusCode != 200) {
      AppLogger.error('DELETE /log/$id failed', response.statusCode);
      throw Exception('Failed to delete log');
    }
  }

  Future<List<LogEntry>> getAllLogs() async {
    final url = Uri.parse('${getBaseUrl()}/allLogs');
    AppLogger.info('GET $url');
    final response = await _client.get(url);
    if (response.statusCode != 200) {
      AppLogger.error('GET /allLogs failed', response.statusCode);
      throw Exception('Failed to load all logs');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => LogEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
