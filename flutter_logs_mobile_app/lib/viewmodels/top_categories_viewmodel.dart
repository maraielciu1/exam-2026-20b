import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';

class TopCategoriesViewModel extends ChangeNotifier {
  TopCategoriesViewModel(this._repository);

  final LogRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _offlineMessage;
  List<CategoryTotal> _totals = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get offlineMessage => _offlineMessage;
  List<CategoryTotal> get totals => _totals;

  Future<void> loadTopCategories() async {
    _isLoading = true;
    _errorMessage = null;
    _offlineMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchAllLogs();
      _totals = _computeTopCategories(result.data);
      if (result.isOffline) {
        _offlineMessage = 'Offline: showing cached insights.';
      }
    } catch (_) {
      _errorMessage = 'Offline: unable to load insights.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<CategoryTotal> _computeTopCategories(List<LogEntry> logs) {
    final totals = <String, double>{};
    for (final log in logs) {
      final category = log.category.trim();
      if (category.isEmpty) {
        continue;
      }
      totals[category] = (totals[category] ?? 0) + log.amount;
    }
    final list = totals.entries
        .map((entry) => CategoryTotal(category: entry.key, total: entry.value))
        .toList();
    list.sort((a, b) => b.total.compareTo(a.total));
    if (list.length > 3) {
      return list.sublist(0, 3);
    }
    return list;
  }
}

class CategoryTotal {
  CategoryTotal({required this.category, required this.total});

  final String category;
  final double total;
}
