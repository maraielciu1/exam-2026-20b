import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';
import 'package:flutter_logs_mobile_app/viewmodels/log_detail_viewmodel.dart';
import 'package:provider/provider.dart';

class LogDetailScreen extends StatelessWidget {
  const LogDetailScreen({super.key, required this.logId});

  final int logId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LogDetailViewModel>(
      create: (_) =>
          LogDetailViewModel(context.read<LogRepository>())..loadLog(logId),
      child: const _LogDetailView(),
    );
  }
}

class _LogDetailView extends StatefulWidget {
  const _LogDetailView();

  @override
  State<_LogDetailView> createState() => _LogDetailViewState();
}

class _LogDetailViewState extends State<_LogDetailView> {
  String? _lastError;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LogDetailViewModel>();
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
        title: const Text('Log Details'),
      ),
      body: Column(
        children: [
          if (viewModel.offlineMessage != null)
            _OfflineBanner(
              message: viewModel.offlineMessage!,
              onRetry: () => viewModel.loadLog(viewModel.lastRequestedId ?? 0),
            ),
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (!viewModel.isLoading && viewModel.errorMessage != null)
            _ErrorState(
              message: viewModel.errorMessage!,
              onRetry: () => viewModel.loadLog(viewModel.lastRequestedId ?? 0),
            ),
          if (!viewModel.isLoading &&
              viewModel.errorMessage == null &&
              viewModel.log != null)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DetailRow(label: 'ID', value: '${viewModel.log!.id}'),
                  _DetailRow(label: 'Date', value: viewModel.log!.date),
                  _DetailRow(
                    label: 'Amount',
                    value: viewModel.log!.amount.toStringAsFixed(1),
                  ),
                  _DetailRow(label: 'Type', value: viewModel.log!.type),
                  _DetailRow(label: 'Category', value: viewModel.log!.category),
                  _DetailRow(
                    label: 'Description',
                    value: viewModel.log!.description,
                  ),
                ],
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
