import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/categories.dart';
import '../models/app_language.dart';
import '../models/word_category.dart';
import '../services/localization.dart';
import '../services/stats_service.dart';
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
            padding: const EdgeInsets.only(right: 12),
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
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatsBar(stats: stats, t: t),
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
}

class _StatsBar extends StatelessWidget {
  final StatsService stats;
  final Strings t;
  const _StatsBar({required this.stats, required this.t});

  @override
  Widget build(BuildContext context) {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            stat(t('played'), '${stats.played}'),
            stat(t('won'), '${stats.won}'),
            stat(t('streak'), '${stats.streak}'),
          ],
        ),
      ),
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
