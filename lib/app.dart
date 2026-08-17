import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/game_controller.dart';
import 'services/stats_service.dart';
import 'services/settings_service.dart';

class WordDashApp extends StatelessWidget {
  const WordDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsService()..load()),
        ChangeNotifierProvider(create: (_) => StatsService()..load()),
        ChangeNotifierProxyProvider<StatsService, GameController>(
          create: (context) =>
              GameController(statsService: context.read<StatsService>()),
          update: (context, stats, previous) =>
              previous ?? GameController(statsService: stats),
        ),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'WordDash',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: ThemeData(
              colorSchemeSeed: const Color(0xFF4CAF50),
              brightness: Brightness.light,
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: const Color(0xFF4CAF50),
              brightness: Brightness.dark,
              useMaterial3: true,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
