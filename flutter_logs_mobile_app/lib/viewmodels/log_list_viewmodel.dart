import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';

class LogListViewModel extends ChangeNotifier {
  LogListViewModel(this._repository);

  final LogRepository _repository;

  List<LogEntry> _logs = [];
  final Set<int> _deletingIds = {};
  bool _isLoading = false;
  String? _errorMessage;
  String? _offlineMessage;

  List<LogEntry> get logs => _logs;
  bool get isLoading => _isLoading;
  bool isDeleting(int id) => _deletingIds.contains(id);
  String? get errorMessage => _errorMessage;
  String? get offlineMessage => _offlineMessage;

  Future<void> loadLogs() async {
    _isLoading = true;
    _errorMessage = null;
    _offlineMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchLogs();
      _logs = result.data;
      if (result.isOffline) {
        _offlineMessage = 'Offline: showing cached logs.';
      }
    } catch (_) {
      _errorMessage = 'Offline: unable to load logs.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void insertLog(LogEntry log) {
    upsertLog(log);
  }

  void upsertLog(LogEntry log) {
    final index = _logs.indexWhere((item) => item.id == log.id);
    if (index == -1) {
      _logs = [log, ..._logs];
    } else {
      final updated = [..._logs];
      updated[index] = log;
      _logs = updated;
    }
    notifyListeners();
  }

  Future<bool> deleteLog(int id) async {
    _deletingIds.add(id);
    notifyListeners();
    try {
      await _repository.deleteLog(id);
      _logs = _logs.where((log) => log.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    } finally {
      _deletingIds.remove(id);
      notifyListeners();
    }
  }
}
