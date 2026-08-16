import 'package:flutter/material.dart';

import '../models/letter_status.dart';

class LetterTile extends StatelessWidget {
  final String letter;
  final LetterStatus status;

  const LetterTile({super.key, required this.letter, required this.status});

  Color _background(BuildContext context) {
    switch (status) {
      case LetterStatus.correct:
        return const Color(0xFF4CAF50);
      case LetterStatus.present:
        return const Color(0xFFE0A93E);
      case LetterStatus.absent:
        return const Color(0xFF3A3A3C);
      case LetterStatus.initial:
        return letter.isEmpty
            ? Colors.transparent
            : Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Color _border(BuildContext context) {
    if (status != LetterStatus.initial) return _background(context);
    return letter.isEmpty
        ? Theme.of(context).colorScheme.outlineVariant
        : Theme.of(context).colorScheme.outline;
  }

  @override
  Widget build(BuildContext context) {
    final filled = status != LetterStatus.initial;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 56,
      height: 56,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: _background(context),
        border: Border.all(color: _border(context), width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: filled ? Colors.white : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
