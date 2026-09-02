import 'crossword_cell.dart';

class CrosswordBoard {
  final String title;
  final String category;
  final int rows;
  final int cols;
  final List<List<CrosswordCell>> grid;
  final List<PlacedWord> placedWords;

  CrosswordBoard({
    required this.title,
    required this.category,
    required this.rows,
    required this.cols,
    required this.grid,
    required this.placedWords,
  });

  List<PlacedWord> get acrossWords =>
      placedWords.where((w) => w.isAcross).toList()
        ..sort((a, b) => a.number.compareTo(b.number));

  List<PlacedWord> get downWords =>
      placedWords.where((w) => !w.isAcross).toList()
        ..sort((a, b) => a.number.compareTo(b.number));

  bool get isComplete {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cell = grid[r][c];
        if (!cell.isBlack && !cell.isCorrect) {
          return false;
        }
      }
    }
    return true;
  }

  double get completionPercentage {
    int totalLetters = 0;
    int correctLetters = 0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cell = grid[r][c];
        if (!cell.isBlack) {
          totalLetters++;
          if (cell.isCorrect) {
            correctLetters++;
          }
        }
      }
    }

    if (totalLetters == 0) return 0.0;
    return correctLetters / totalLetters;
  }

  PlacedWord? getWordForCell(int row, int col, bool preferAcross) {
    final matches = placedWords.where((w) => w.containsCell(row, col)).toList();
    if (matches.isEmpty) return null;
    if (matches.length == 1) return matches.first;

    final preferred = matches.where((w) => w.isAcross == preferAcross);
    return preferred.isNotEmpty ? preferred.first : matches.first;
  }
}
