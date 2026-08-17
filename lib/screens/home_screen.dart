import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../data/categories.dart';
import '../models/app_language.dart';
import '../models/word_category.dart';
import '../services/localization.dart';
import '../services/stats_service.dart';
import '../services/settings_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppLanguage _language = AppLanguage.en;

  @override
  Widget build(BuildContext context) {
    final t = Strings(_language);
    final stats = context.watch<StatsService>();
    final available = categories.where((c) => c.supports(_language)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(t('appTitle')),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: SegmentedButton<AppLanguage>(
                segments: AppLanguage.values
                    .map((l) => ButtonSegment(
                          value: l,
                          label: Text(l.flagEmoji),
                        ))
                    .toList(),
                selected: {_language},
                onSelectionChanged: (s) => setState(() => _language = s.first),
                showSelectedIcon: false,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context, t),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatsBar(stats: stats, language: _language, t: t),
          const SizedBox(height: 16),
          Text(t('chooseCategory'),
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...available.map((c) => _CategoryCard(
                category: c,
                language: _language,
                t: t,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        GameScreen(category: c, language: _language),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, Strings t) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t('settings')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t('theme'), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Consumer<SettingsService>(
                builder: (context, settings, _) {
                  return SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(t('themeSystem')),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(t('themeLight')),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(t('themeDark')),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (s) => settings.setThemeMode(s.first),
                    showSelectedIcon: false,
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(t('data'), style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.upload),
                      label: Text(t('exportStats')),
                      onPressed: () async {
                        final stats = context.read<StatsService>();
                        final json = stats.exportStats();
                        final downloadsDir = await getDownloadsDirectory();
                        final pathUri = await FilePicker.saveFile(
                          dialogTitle: 'Save WordDash Stats',
                          fileName: 'worddash_stats.json',
                          bytes: Uint8List.fromList(utf8.encode(json)),
                          initialDirectory: downloadsDir?.path,
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                        );

                        if (pathUri != null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t('statsExported'))),
                            );
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.download),
                      label: Text(t('importStats')),
                      onPressed: () async {
                        final result = await FilePicker.pickFile(
                          type: FileType.custom,
                          allowedExtensions: ['json'],
                        );
                        if (result != null && result.path != null) {
                          final file = File(result.path!);
                          final text = await file.readAsString();
                          if (context.mounted) {
                            final stats = context.read<StatsService>();
                            final success = await stats.importStats(text);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(success
                                      ? t('importSuccess')
                                      : t('invalidData')),
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

class _StatsBar extends StatelessWidget {
  final StatsService stats;
  final AppLanguage language;
  final Strings t;
  const _StatsBar({required this.stats, required this.language, required this.t});

  @override
  Widget build(BuildContext context) {
    final langStats = stats.getStatsFor(language);
    Widget stat(String label, String value) => Column(
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => _DetailedStatsDialog(langStats: langStats, t: t),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              stat(t('played'), '${langStats.played}'),
              stat(t('won'), '${langStats.won}'),
              stat(t('streak'), '${langStats.streak}'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailedStatsDialog extends StatelessWidget {
  final LanguageStats langStats;
  final Strings t;

  const _DetailedStatsDialog({required this.langStats, required this.t});

  @override
  Widget build(BuildContext context) {
    int maxDist = 1;
    for (var v in langStats.guessDistribution.values) {
      if (v > maxDist) maxDist = v;
    }
    
    final winRate = langStats.played > 0 
        ? (langStats.won / langStats.played * 100).round() 
        : 0;

    return AlertDialog(
      title: Text(t('detailedStats'), textAlign: TextAlign.center),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _stat(context, t('bestStreak'), '${langStats.bestStreak}'),
                _stat(context, t('winRate'), '$winRate%'),
              ],
            ),
            const SizedBox(height: 24),
            Text(t('guessDistribution'), style: Theme.of(context).textTheme.titleSmall, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            for (int i = 1; i <= 6; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text('$i', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final value = langStats.guessDistribution[i] ?? 0;
                          final fraction = value / maxDist;
                          final barWidth = constraints.maxWidth * fraction;
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              height: 24,
                              width: barWidth < 24 ? 24 : barWidth,
                              decoration: BoxDecoration(
                                color: value > 0 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '$value',
                                style: TextStyle(
                                  color: value > 0 ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget _stat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final WordCategory category;
  final AppLanguage language;
  final Strings t;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.language,
    required this.t,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Text(category.icon, style: const TextStyle(fontSize: 28)),
        title: Text(category.nameFor(language)),
        subtitle:
            Text('${category.wordsFor(language).length} ${t('wordsCount')}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
