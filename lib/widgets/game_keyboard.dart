import 'package:flutter/material.dart';

import '../models/letter_status.dart';

/// A self-contained on-screen keyboard so we never depend on the
/// system keyboard or its locale/autocorrect quirks.
class GameKeyboard extends StatelessWidget {
  final Map<String, LetterStatus> letterStatuses;
  final ValueChanged<String> onLetter;
  final VoidCallback onEnter;
  final VoidCallback onBackspace;

  const GameKeyboard({
    super.key,
    required this.letterStatuses,
    required this.onLetter,
    required this.onEnter,
    required this.onBackspace,
  });

  static const _rows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['ENTER', 'Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫'],
  ];

  Color _keyColor(BuildContext context, String key) {
    final status = letterStatuses[key];
    switch (status) {
      case LetterStatus.correct:
        return const Color(0xFF4CAF50);
      case LetterStatus.present:
        return const Color(0xFFE0A93E);
      case LetterStatus.absent:
        return const Color(0xFF3A3A3C);
      case LetterStatus.initial:
      case null:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxKeyboardWidth = screenWidth > 500 ? 500.0 : screenWidth;
    // 10 keys max per row, 4px padding per key (2px on each side)
    // 8px horizontal margin on each side of the keyboard = 16px total
    final availableWidth = maxKeyboardWidth - (10 * 4) - 16;
    final keyWidth = availableWidth / 10;

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _rows.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                final isWide = key == 'ENTER' || key == '⌫';
                final color = (key == 'ENTER' || key == '⌫')
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : _keyColor(context, key);
                final textColor = letterStatuses[key] != null &&
                        letterStatuses[key] != LetterStatus.initial
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        if (key == 'ENTER') {
                          onEnter();
                        } else if (key == '⌫') {
                          onBackspace();
                        } else {
                          onLetter(key);
                        }
                      },
                      child: Container(
                        width: isWide ? (keyWidth * 1.5) + 2 : keyWidth,
                        height: 56,
                        alignment: Alignment.center,
                        child: Text(
                          key == 'ENTER' ? 'GO' : key,
                          style: TextStyle(
                            fontSize: key == 'ENTER' ? 16 : 22,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}
