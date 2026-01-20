import 'package:flutter_logs_mobile_app/core/logger.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:flutter_logs_mobile_app/data/services/api_service.dart';
import 'package:flutter_logs_mobile_app/data/services/cache_service.dart';

class LogRepository {
  LogRepository(this._apiService, this._cacheService);

  final ApiService _apiService;
  final CacheService _cacheService;

  Future<LogResult<List<LogEntry>>> fetchLogs() async {
    try {
      AppLogger.info('Repository fetch logs');
      final logs = await _apiService.getLogs();
      await _cacheService.saveLogs(logs);
      return LogResult(data: logs, isOffline: false);
    } catch (_) {
      AppLogger.error('Repository fetch logs failed');
      final cached = await _cacheService.getLogs();
      if (cached != null) {
        return LogResult(data: cached, isOffline: true);
      }
      rethrow;
    }
  }

  Future<LogResult<LogEntry>> fetchLog(int id) async {
    try {
      AppLogger.info('Repository fetch log $id');
      final log = await _apiService.getLog(id);
      await _cacheService.saveLog(log);
      return LogResult(data: log, isOffline: false);
    } catch (_) {
      AppLogger.error('Repository fetch log $id failed');
      final cached = await _cacheService.getLog(id);
      if (cached != null) {
        return LogResult(data: cached, isOffline: true);
      }
      rethrow;
    }
  }

  Future<LogEntry> createLog(LogDraft draft) async {
    AppLogger.info('Repository create log');
    final log = await _apiService.createLog(draft);
    await _cacheService.saveLog(log);
    final cachedLogs = await _cacheService.getLogs();
    if (cachedLogs != null) {
      await _cacheService.saveLogs([log, ...cachedLogs]);
    }
    return log;
  }

  Future<void> deleteLog(int id) async {
    AppLogger.info('Repository delete log $id');
    await _apiService.deleteLog(id);
    await _cacheService.removeLog(id);
    final cachedLogs = await _cacheService.getLogs();
    if (cachedLogs != null) {
      await _cacheService
          .saveLogs(cachedLogs.where((log) => log.id != id).toList());
    }
  }

  Future<LogResult<List<LogEntry>>> fetchAllLogs() async {
    try {
      AppLogger.info('Repository fetch all logs');
      final logs = await _apiService.getAllLogs();
      await _cacheService.saveLogs(logs);
      return LogResult(data: logs, isOffline: false);
    } catch (_) {
      AppLogger.error('Repository fetch all logs failed');
      final cached = await _cacheService.getLogs();
      if (cached != null) {
        return LogResult(data: cached, isOffline: true);
      }
      rethrow;
    }
  }
}

class LogResult<T> {
  LogResult({required this.data, required this.isOffline});

  final T data;
  final bool isOffline;
}
