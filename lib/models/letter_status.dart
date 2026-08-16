/// The evaluation result of a single letter within a submitted guess.
enum LetterStatus {
  /// Not evaluated yet (tile is still empty or being typed).
  initial,

  /// Letter is correct and in the correct position.
  correct,

  /// Letter exists in the target word but in a different position.
  present,

  /// Letter does not exist in the target word (or all copies of it were
  /// already matched as correct/present elsewhere).
  absent,
}

/// The overall status of the current round.
enum GameStatus {
  playing,
  won,
  lost,
}
