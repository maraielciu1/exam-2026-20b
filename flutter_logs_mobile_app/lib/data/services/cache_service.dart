import 'dart:convert';

import 'package:flutter_logs_mobile_app/core/logger.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _logsKey = 'logs_cache';
  static const String _logPrefix = 'log_cache_';

  Future<void> saveLogs(List<LogEntry> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(logs.map((e) => e.toJson()).toList());
    await prefs.setString(_logsKey, encoded);
    AppLogger.info('Cache saved logs (${logs.length})');
  }

  Future<List<LogEntry>?> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_logsKey);
    if (raw == null || raw.isEmpty) {
      AppLogger.info('Cache miss for logs');
      return null;
    }
    final data = jsonDecode(raw) as List<dynamic>;
    AppLogger.info('Cache loaded logs');
    return data
        .map((item) => LogEntry.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveLog(LogEntry log) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(log.toJson());
    await prefs.setString('$_logPrefix${log.id}', encoded);
    AppLogger.info('Cache saved log ${log.id}');
  }

  Future<LogEntry?> getLog(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_logPrefix$id');
    if (raw == null || raw.isEmpty) {
      AppLogger.info('Cache miss for log $id');
      return null;
    }
    final data = jsonDecode(raw) as Map<String, dynamic>;
    AppLogger.info('Cache loaded log $id');
    return LogEntry.fromJson(data);
  }

  Future<void> removeLog(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_logPrefix$id');
    AppLogger.info('Cache removed log $id');
  }
}
