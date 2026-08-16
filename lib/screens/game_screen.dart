import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_language.dart';
import '../models/letter_status.dart';
import '../models/word_category.dart';
import '../services/game_controller.dart';
import '../services/localization.dart';
import '../widgets/game_grid.dart';
import '../widgets/game_keyboard.dart';

class GameScreen extends StatefulWidget {
  final WordCategory category;
  final AppLanguage language;

  const GameScreen({super.key, required this.category, required this.language});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<GameController>()
          .startNewRound(category: widget.category, language: widget.language);
    });
  }

  void _handleKey(GameController controller, String key) {
    if (key == 'ENTER') {
      controller.submitGuess();
    } else if (key == '⌫') {
      controller.removeLetter();
    } else {
      controller.addLetter(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Strings(widget.language);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.nameFor(widget.language)),
      ),
      body: Consumer<GameController>(
        builder: (context, controller, _) {
          if (controller.category == null) {
            return const Center(child: CircularProgressIndicator());
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.status != GameStatus.playing && mounted) {
              _maybeShowResultDialog(context, controller, t);
            }
            if (controller.lastError != null && mounted) {
              final message = t(controller.lastError!);
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
                );
            }
          });

          return SafeArea(
            child: Column(
              children: [
                const Spacer(),
                GameGrid(
                  wordLength: controller.wordLength,
                  maxAttempts: GameController.maxAttempts,
                  guesses: controller.guesses,
                  guessStatuses: controller.guessStatuses,
                  currentGuess: controller.currentGuess,
                ),
                const Spacer(),
                GameKeyboard(
                  letterStatuses: controller.keyboardStatuses,
                  onLetter: (l) => _handleKey(controller, l),
                  onEnter: () => _handleKey(controller, 'ENTER'),
                  onBackspace: () => _handleKey(controller, '⌫'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _dialogShown = false;

  void _maybeShowResultDialog(
      BuildContext context, GameController controller, Strings t) {
    if (_dialogShown) return;
    _dialogShown = true;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(controller.status == GameStatus.won
            ? t('youWon')
            : t('youLost')),
        content: controller.status == GameStatus.lost
            ? Text('${t('theWordWas')}: ${controller.targetWord}')
            : null,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext)
              ..pop()
              ..pop(),
            child: Text(t('backToCategories')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _dialogShown = false;
              controller.startNewRound();
            },
            child: Text(t('playAgain')),
          ),
        ],
      ),
    );
  }
}
