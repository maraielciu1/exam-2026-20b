import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';
import 'package:flutter_logs_mobile_app/viewmodels/monthly_report_viewmodel.dart';
import 'package:provider/provider.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          MonthlyReportViewModel(context.read<LogRepository>())
            ..loadMonthlyTotals(),
      child: const _MonthlyReportView(),
    );
  }
}

class _MonthlyReportView extends StatefulWidget {
  const _MonthlyReportView();

  @override
  State<_MonthlyReportView> createState() => _MonthlyReportViewState();
}

class _MonthlyReportViewState extends State<_MonthlyReportView> {
  String? _lastError;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MonthlyReportViewModel>();
    if (viewModel.errorMessage != null &&
        viewModel.errorMessage != _lastError) {
      _lastError = viewModel.errorMessage;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(viewModel.errorMessage!)),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Report'),
      ),
      body: Column(
        children: [
          if (viewModel.offlineMessage != null)
            _OfflineBanner(
              message: viewModel.offlineMessage!,
              onRetry: viewModel.loadMonthlyTotals,
            ),
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (!viewModel.isLoading && viewModel.errorMessage != null)
            _ErrorState(
              message: viewModel.errorMessage!,
              onRetry: viewModel.loadMonthlyTotals,
            ),
          if (!viewModel.isLoading &&
              viewModel.errorMessage == null &&
              viewModel.totals.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No logs available for report.'),
            ),
          if (!viewModel.isLoading &&
              viewModel.errorMessage == null &&
              viewModel.totals.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: viewModel.totals.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = viewModel.totals[index];
                  return ListTile(
                    title: Text(item.month),
                    subtitle: Text(
                      'Intake: ${item.intakeTotal.toStringAsFixed(1)} • '
                      'Burn: ${item.burnTotal.toStringAsFixed(1)}',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Net: ${item.netTotal.toStringAsFixed(1)}'),
                        Text('Sum: ${item.sumTotal.toStringAsFixed(1)}'),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
