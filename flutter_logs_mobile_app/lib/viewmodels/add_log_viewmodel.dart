import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';

class AddLogViewModel extends ChangeNotifier {
  AddLogViewModel(this._repository);

  final LogRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<LogEntry?> createLog(LogDraft draft) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.createLog(draft);
    } catch (_) {
      _errorMessage = 'Offline: unable to create log.';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
