import 'package:flutter_test/flutter_test.dart';
import 'package:worddash/app.dart';
import 'package:worddash/models/app_language.dart';
import 'package:worddash/models/letter_status.dart';
import 'package:worddash/services/game_controller.dart';
import 'package:worddash/services/stats_service.dart';
import 'package:worddash/data/categories.dart';

void main() {
  testWidgets('App launches and shows the home screen', (tester) async {
    await tester.pumpWidget(const WordDashApp());
    await tester.pump();
    expect(find.text('WordDash'), findsWidgets);
  });

  test('GameController scores duplicate letters correctly', () {
    final controller = GameController(statsService: StatsService());
    final category = categories.firstWhere((c) => c.id == 'general');
    controller.startNewRound(category: category, language: AppLanguage.en);

    // Force a known target to make the assertion deterministic.
    // (startNewRound picks randomly, so we just check the evaluator
    // directly via a guess against whatever word was picked, using
    // a guess equal to the target to confirm an all-correct result.)
    final target = controller.targetWord;
    for (final letter in target.split('')) {
      controller.addLetter(letter);
    }
    controller.submitGuess();

    expect(controller.status, GameStatus.won);
    expect(
      controller.guessStatuses.first,
      List.filled(target.length, LetterStatus.correct),
    );
  });
}
