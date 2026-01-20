import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';

class MonthlyReportViewModel extends ChangeNotifier {
  MonthlyReportViewModel(this._repository);

  final LogRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  String? _offlineMessage;
  List<MonthlyTotal> _totals = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get offlineMessage => _offlineMessage;
  List<MonthlyTotal> get totals => _totals;

  Future<void> loadMonthlyTotals() async {
    _isLoading = true;
    _errorMessage = null;
    _offlineMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchAllLogs();
      _totals = _computeTotals(result.data);
      if (result.isOffline) {
        _offlineMessage = 'Offline: showing cached report.';
      }
    } catch (_) {
      _errorMessage = 'Offline: unable to load report.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MonthlyTotal> _computeTotals(List<LogEntry> logs) {
    final intakeTotals = <String, double>{};
    final burnTotals = <String, double>{};

    for (final log in logs) {
      if (log.date.length < 7) {
        continue;
      }
      final monthKey = log.date.substring(0, 7);
      final type = log.type.toLowerCase();
      if (type == 'burn') {
        burnTotals[monthKey] = (burnTotals[monthKey] ?? 0) + log.amount;
      } else {
        intakeTotals[monthKey] = (intakeTotals[monthKey] ?? 0) + log.amount;
      }
    }

    final months = {...intakeTotals.keys, ...burnTotals.keys};
    final list = months.map((month) {
      final intake = intakeTotals[month] ?? 0;
      final burn = burnTotals[month] ?? 0;
      return MonthlyTotal(
        month: month,
        intakeTotal: intake,
        burnTotal: burn,
        netTotal: intake - burn,
        sumTotal: intake + burn,
      );
    }).toList();

    list.sort((a, b) => b.netTotal.compareTo(a.netTotal));
    return list;
  }
}

class MonthlyTotal {
  MonthlyTotal({
    required this.month,
    required this.intakeTotal,
    required this.burnTotal,
    required this.netTotal,
    required this.sumTotal,
  });

  final String month;
  final double intakeTotal;
  final double burnTotal;
  final double netTotal;
  final double sumTotal;
}
