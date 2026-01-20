import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';
import 'package:flutter_logs_mobile_app/viewmodels/top_categories_viewmodel.dart';
import 'package:provider/provider.dart';

class TopCategoriesScreen extends StatelessWidget {
  const TopCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          TopCategoriesViewModel(context.read<LogRepository>())
            ..loadTopCategories(),
      child: const _TopCategoriesView(),
    );
  }
}

class _TopCategoriesView extends StatefulWidget {
  const _TopCategoriesView();

  @override
  State<_TopCategoriesView> createState() => _TopCategoriesViewState();
}

class _TopCategoriesViewState extends State<_TopCategoriesView> {
  String? _lastError;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TopCategoriesViewModel>();
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
        title: const Text('Top Categories'),
      ),
      body: Column(
        children: [
          if (viewModel.offlineMessage != null)
            _OfflineBanner(
              message: viewModel.offlineMessage!,
              onRetry: viewModel.loadTopCategories,
            ),
          if (viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (!viewModel.isLoading && viewModel.errorMessage != null)
            _ErrorState(
              message: viewModel.errorMessage!,
              onRetry: viewModel.loadTopCategories,
            ),
          if (!viewModel.isLoading &&
              viewModel.errorMessage == null &&
              viewModel.totals.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No categories available.'),
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
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(item.category),
                    trailing: Text(item.total.toStringAsFixed(1)),
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
