import 'package:flutter/material.dart';
import 'package:flutter_logs_mobile_app/data/repositories/log_repository.dart';
import 'package:flutter_logs_mobile_app/data/services/api_service.dart';
import 'package:flutter_logs_mobile_app/data/services/cache_service.dart';
import 'package:flutter_logs_mobile_app/views/log_list_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (_) => LogRepository(ApiService(), CacheService()),
        ),
      ],
      child: MaterialApp(
        title: 'Calorie Manager',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const LogListScreen(),
      ),
    );
  }
}
