class CrosswordCell {
  final int row;
  final int col;
  final String solutionChar;
  String userChar;
  bool isBlack;
  int? number; // Clue number (e.g. 1, 2, 3)
  bool isRevealed;
  bool isError;

  CrosswordCell({
    required this.row,
    required this.col,
    required this.solutionChar,
    this.userChar = '',
    this.isBlack = false,
    this.number,
    this.isRevealed = false,
    this.isError = false,
  });

  bool get isCorrect => !isBlack && userChar.toUpperCase() == solutionChar.toUpperCase();
  bool get isFilled => !isBlack && userChar.isNotEmpty;

  CrosswordCell copyWith({
    String? userChar,
    bool? isRevealed,
    bool? isError,
    int? number,
  }) {
    return CrosswordCell(
      row: row,
      col: col,
      solutionChar: solutionChar,
      userChar: userChar ?? this.userChar,
      isBlack: isBlack,
      number: number ?? this.number,
      isRevealed: isRevealed ?? this.isRevealed,
      isError: isError ?? this.isError,
    );
  }
}

class PlacedWord {
  final String word;
  final String clue;
  final String category;
  final int wordId;
  final int startRow;
  final int startCol;
  final bool isAcross; // true: Horizontal (Across), false: Vertical (Down)
  final int number;    // Standard clue number (1, 2, ...)

  PlacedWord({
    required this.word,
    required this.clue,
    required this.category,
    required this.wordId,
    required this.startRow,
    required this.startCol,
    required this.isAcross,
    required this.number,
  });

  int get endRow => isAcross ? startRow : startRow + word.length - 1;
  int get endCol => isAcross ? startCol + word.length - 1 : startCol;

  bool containsCell(int row, int col) {
    if (isAcross) {
      return row == startRow && col >= startCol && col <= endCol;
    } else {
      return col == startCol && row >= startRow && row <= endRow;
    }
  }

  int getCharIndexForCell(int row, int col) {
    if (isAcross) {
      return col - startCol;
    } else {
      return row - startRow;
    }
  }
}
