import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/models/log_entry.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';
import 'package:flutter_logs_mobile_app/data/services/websocket_service.dart';
import 'package:flutter_logs_mobile_app/viewmodels/log_list_viewmodel.dart';
import 'package:flutter_logs_mobile_app/views/add_log_screen.dart';
import 'package:flutter_logs_mobile_app/views/log_detail_screen.dart';
import 'package:flutter_logs_mobile_app/views/monthly_report_screen.dart';
import 'package:flutter_logs_mobile_app/views/top_categories_screen.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LogListScreen extends StatelessWidget {
  const LogListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LogListViewModel>(
      create: (_) =>
          LogListViewModel(context.read<LogRepository>())..loadLogs(),
      child: const _LogListView(),
    );
  }
}

class _LogListView extends StatefulWidget {
  const _LogListView();

  @override
  State<_LogListView> createState() => _LogListViewState();
}

class _LogListViewState extends State<_LogListView> {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  final WebSocketService _webSocketService = WebSocketService();
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel?.sink.close();
    _subscription?.cancel();
    _channel = _webSocketService.connect();
    _subscription = _channel!.stream.listen((message) {
      final log = _webSocketService.parseLog(message);
      if (log == null || !mounted) {
        return;
      }
      context.read<LogListViewModel>().upsertLog(log);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'New log: ${log.type} ${log.amount.toStringAsFixed(1)} '
            '(${log.category}) on ${log.date}',
          ),
        ),
      );
    }, onError: (_) {
      _scheduleReconnect();
    }, onDone: () {
      _scheduleReconnect();
    });
  }

  void _scheduleReconnect() {
    if (!mounted) {
      return;
    }
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), _connectWebSocket);
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LogListViewModel>();
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
        title: const Text('Calorie Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TopCategoriesScreen()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddLogScreen()),
          );
          if (created is LogEntry && context.mounted) {
            viewModel.insertLog(created);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (viewModel.isLoading) const LinearProgressIndicator(),
          if (viewModel.offlineMessage != null)
            _OfflineBanner(
              message: viewModel.offlineMessage!,
              onRetry: viewModel.loadLogs,
            ),
          if (!viewModel.isLoading && viewModel.errorMessage != null)
            _ErrorState(
              message: viewModel.errorMessage!,
              onRetry: viewModel.loadLogs,
            ),
          if (!viewModel.isLoading &&
              viewModel.errorMessage == null &&
              viewModel.logs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No logs available.'),
            ),
          if (!viewModel.isLoading &&
              viewModel.errorMessage == null &&
              viewModel.logs.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: viewModel.logs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final log = viewModel.logs[index];
                  return ListTile(
                    title: Text('${log.type} • ${log.category}'),
                    subtitle: Text('${log.date} • ${log.description}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(log.amount.toStringAsFixed(1)),
                        if (viewModel.isDeleting(log.id))
                          const Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete log'),
                                  content: const Text(
                                    'Are you sure you want to delete this log?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true) {
                                return;
                              }
                              final ok = await viewModel.deleteLog(log.id);
                              if (context.mounted && !ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Offline: unable to delete log.',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LogDetailScreen(logId: log.id),
                        ),
                      );
                    },
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
