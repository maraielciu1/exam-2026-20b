import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';

class LogDetailViewModel extends ChangeNotifier {
  LogDetailViewModel(this._repository);

  final LogRepository _repository;

  LogEntry? _log;
  int? _lastRequestedId;
  bool _isLoading = false;
  String? _errorMessage;
  String? _offlineMessage;

  LogEntry? get log => _log;
  int? get lastRequestedId => _lastRequestedId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get offlineMessage => _offlineMessage;

  Future<void> loadLog(int id) async {
    _lastRequestedId = id;
    _isLoading = true;
    _errorMessage = null;
    _offlineMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchLog(id);
      _log = result.data;
      if (result.isOffline) {
        _offlineMessage = 'Offline: showing cached log.';
      }
    } catch (_) {
      _errorMessage = 'Offline: unable to load log.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
