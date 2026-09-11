import 'dart:math';
import '../models/word_entry.dart';
import '../models/crossword_cell.dart';
import '../models/crossword_board.dart';
import 'dictionary_repository.dart';

class TempWord {
  final WordEntry entry;
  final int startRow;
  final int startCol;
  final bool isAcross;

  TempWord({
    required this.entry,
    required this.startRow,
    required this.startCol,
    required this.isAcross,
  });

  int get endRow => isAcross ? startRow : startRow + entry.word.length - 1;
  int get endCol => isAcross ? startCol + entry.word.length - 1 : startCol;
}

class CrosswordGenerator {
  static const int maxGridSize = 32;

  static Future<CrosswordBoard> generateBoard({
    required String title,
    required String category,
    int targetWordsCount = 10,
    int targetGridDimension = 10,
    String? difficultyFilter,
  }) async {
    final repo = DictionaryRepository();
    if (!repo.isLoaded) {
      await repo.loadDictionary();
    }

    List<WordEntry> candidates = repo.getWordsByCategory(category);
    if (difficultyFilter != null) {
      final diffFiltered = candidates.where((w) => w.difficulty == difficultyFilter).toList();
      if (diffFiltered.length >= targetWordsCount + 5) {
        candidates = diffFiltered;
      } else {
        // Supplement with other words of the same category
        final remainingInCat = candidates.where((w) => w.difficulty != difficultyFilter).toList()..shuffle();
        candidates = [...diffFiltered, ...remainingInCat];
      }
    }

    // Ensure we have a generous candidate pool (at least targetWordsCount + 25)
    if (candidates.length < targetWordsCount + 25) {
      final allMatchingDiff = repo.allWords.where((w) => difficultyFilter == null || w.difficulty == difficultyFilter).toList()..shuffle();
      candidates = {...candidates, ...allMatchingDiff, ...repo.allWords}.toList();
    }

    CrosswordBoard? bestBoard;
    int maxScore = -999999;

    // Run multiple procedural attempts to get the highest density, best connected layout
    final random = Random();
    for (int attempt = 0; attempt < 70; attempt++) {
      // Pick one of the longest candidate words as the starting root
      final sortedLongest = [...candidates]..sort((a, b) => b.word.length.compareTo(a.word.length));
      final rootCandidates = sortedLongest.take(10).toList();
      final firstWord = rootCandidates[random.nextInt(rootCandidates.length)];
      final remainingCandidates = candidates.where((w) => w.id != firstWord.id).toList()..shuffle(random);

      final board = _buildSingleBoardAttempt(
        title: title,
        category: category,
        firstWord: firstWord,
        candidates: remainingCandidates,
        targetWordsCount: targetWordsCount,
        maxSize: maxGridSize,
      );

      if (board != null) {
        // Words placed is given massive priority over area penalty
        int area = board.rows * board.cols;
        int score = (board.placedWords.length * 1000) - (area * 3) - ((board.rows - board.cols).abs() * 15);
        if (score > maxScore) {
          maxScore = score;
          bestBoard = board;
        }

        // If an attempt successfully reached the requested targetWordsCount, we have an excellent board!
        if (board.placedWords.length >= targetWordsCount && attempt > 15) {
          break;
        }
      }
    }

    if (bestBoard != null) {
      return bestBoard;
    }

    // Ultimate fallback if procedural generation failed
    return _buildFallbackBoard(title: title, category: category);
  }

  static CrosswordBoard? _buildSingleBoardAttempt({
    required String title,
    required String category,
    required WordEntry firstWord,
    required List<WordEntry> candidates,
    required int targetWordsCount,
    required int maxSize,
  }) {
    // Virtual workspace matrix initialized with nulls
    List<List<String?>> matrix = List.generate(
      maxSize,
      (_) => List.generate(maxSize, (_) => null),
    );

    List<TempWord> placedTempWords = [];

    // 1. Place first word in middle horizontally
    int startRow = maxSize ~/ 2;
    int startCol = (maxSize - firstWord.word.length) ~/ 2;

    for (int i = 0; i < firstWord.word.length; i++) {
      matrix[startRow][startCol + i] = firstWord.word[i];
    }
    placedTempWords.add(TempWord(
      entry: firstWord,
      startRow: startRow,
      startCol: startCol,
      isAcross: true,
    ));

    // 2. Try placing remaining candidate words by finding intersecting letters
    for (int cIdx = 0; cIdx < candidates.length && placedTempWords.length < targetWordsCount; cIdx++) {
      final candidate = candidates[cIdx];
      bool placed = false;

      // Find all possible intersections with already placed letters
      for (final existingWord in placedTempWords.toList()) {
        if (placed) break;

        for (int i = 0; i < candidate.word.length; i++) {
          if (placed) break;

          final char = candidate.word[i];

          for (int j = 0; j < existingWord.entry.word.length; j++) {
            if (existingWord.entry.word[j] == char) {
              final newIsAcross = !existingWord.isAcross;
              int newStartRow, newStartCol;

              if (existingWord.isAcross) {
                int intRow = existingWord.startRow;
                int intCol = existingWord.startCol + j;
                newStartRow = intRow - i;
                newStartCol = intCol;
              } else {
                int intRow = existingWord.startRow + j;
                int intCol = existingWord.startCol;
                newStartRow = intRow;
                newStartCol = intCol - i;
              }

              if (_canPlaceWord(matrix, candidate.word, newStartRow, newStartCol, newIsAcross, maxSize)) {
                _placeWordInMatrix(matrix, candidate.word, newStartRow, newStartCol, newIsAcross);
                placedTempWords.add(TempWord(
                  entry: candidate,
                  startRow: newStartRow,
                  startCol: newStartCol,
                  isAcross: newIsAcross,
                ));
                placed = true;
                break;
              }
            }
          }
        }
      }
    }

    if (placedTempWords.length < 3) {
      return null; // Not enough words connected
    }

    // 3. Compute Bounding Box
    int minR = maxSize, maxR = 0, minC = maxSize, maxC = 0;
    for (int r = 0; r < maxSize; r++) {
      for (int c = 0; c < maxSize; c++) {
        if (matrix[r][c] != null) {
          if (r < minR) minR = r;
          if (r > maxR) maxR = r;
          if (c < minC) minC = c;
          if (c > maxC) maxC = c;
        }
      }
    }

    // Crop strictly around the active word bounding box
    int rows = maxR - minR + 1;
    int cols = maxC - minC + 1;

    // 4. Shift words to cropped grid coordinates
    List<TempWord> shiftedWords = [];
    for (final tw in placedTempWords) {
      shiftedWords.add(TempWord(
        entry: tw.entry,
        startRow: tw.startRow - minR,
        startCol: tw.startCol - minC,
        isAcross: tw.isAcross,
      ));
    }

    // 5. Assign Clue Numbers in natural reading order
    Map<String, int> cellToNumberMap = {};
    int currentNumber = 1;

    // Sort all start positions top-to-bottom, left-to-right
    List<Point<int>> startPoints = [];
    for (final sw in shiftedWords) {
      final pt = Point(sw.startRow, sw.startCol);
      if (!startPoints.contains(pt)) {
        startPoints.add(pt);
      }
    }
    startPoints.sort((a, b) {
      if (a.x != b.x) return a.x.compareTo(b.x);
      return a.y.compareTo(b.y);
    });

    for (final pt in startPoints) {
      cellToNumberMap["${pt.x}_${pt.y}"] = currentNumber++;
    }

    List<PlacedWord> finalPlacedWords = [];
    for (final sw in shiftedWords) {
      final num = cellToNumberMap["${sw.startRow}_${sw.startCol}"]!;
      finalPlacedWords.add(PlacedWord(
        word: sw.entry.word,
        clue: sw.entry.clue,
        category: sw.entry.category,
        wordId: sw.entry.id,
        startRow: sw.startRow,
        startCol: sw.startCol,
        isAcross: sw.isAcross,
        number: num,
      ));
    }

    // 6. Construct Final CrosswordCell grid
    List<List<CrosswordCell>> finalGrid = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) {
          int origR = minR + r;
          int origC = minC + c;
          String? letter = matrix[origR][origC];
          int? number = cellToNumberMap["${r}_$c"];

          return CrosswordCell(
            row: r,
            col: c,
            solutionChar: letter ?? '',
            userChar: '',
            isBlack: letter == null,
            number: number,
          );
        },
      ),
    );

    return CrosswordBoard(
      title: title,
      category: category,
      rows: rows,
      cols: cols,
      grid: finalGrid,
      placedWords: finalPlacedWords,
    );
  }

  static bool _canPlaceWord(
    List<List<String?>> matrix,
    String word,
    int startRow,
    int startCol,
    bool isAcross,
    int maxSize,
  ) {
    int endRow = isAcross ? startRow : startRow + word.length - 1;
    int endCol = isAcross ? startCol + word.length - 1 : startCol;

    if (startRow < 1 || startCol < 1 || endRow >= maxSize - 1 || endCol >= maxSize - 1) {
      return false; // Stay clear of outermost matrix edges
    }

    // Check pre/post cells (word ends must have empty space or matrix boundary)
    if (isAcross) {
      if (matrix[startRow][startCol - 1] != null) return false;
      if (matrix[startRow][endCol + 1] != null) return false;
    } else {
      if (matrix[startRow - 1][startCol] != null) return false;
      if (matrix[endRow + 1][startCol] != null) return false;
    }

    for (int i = 0; i < word.length; i++) {
      int r = isAcross ? startRow : startRow + i;
      int c = isAcross ? startCol + i : startCol;

      String? existing = matrix[r][c];

      if (existing != null) {
        if (existing != word[i]) {
          return false; // Collision with a different letter!
        }
      } else {
        // Parallel adjacency check: surrounding cells perpendicular to direction must be empty
        if (isAcross) {
          if (matrix[r - 1][c] != null || matrix[r + 1][c] != null) return false;
        } else {
          if (matrix[r][c - 1] != null || matrix[r][c + 1] != null) return false;
        }
      }
    }

    return true;
  }

  static void _placeWordInMatrix(
    List<List<String?>> matrix,
    String word,
    int startRow,
    int startCol,
    bool isAcross,
  ) {
    for (int i = 0; i < word.length; i++) {
      int r = isAcross ? startRow : startRow + i;
      int c = isAcross ? startCol + i : startCol;
      matrix[r][c] = word[i];
    }
  }

  static CrosswordBoard _buildFallbackBoard({required String title, required String category}) {
    // Tightly cropped fallback crossword board (5 rows x 8 cols)
    final w1 = PlacedWord(word: "ALQUIMIA", clue: "Doctrina especulativa enfocada en la transmutación de la materia", category: "Historia", wordId: 1, startRow: 1, startCol: 0, isAcross: true, number: 1);
    final w2 = PlacedWord(word: "CINE", clue: "Arte y técnica de la cinematografía", category: "Cine", wordId: 14, startRow: 0, startCol: 4, isAcross: false, number: 2);
    final w3 = PlacedWord(word: "METAFORA", clue: "Traslación del sentido recto de una voz a otro figurado", category: "Lenguaje", wordId: 4, startRow: 3, startCol: 0, isAcross: true, number: 3);
    final w4 = PlacedWord(word: "ARTE", clue: "Manifestación de la actividad humana mediante la cual se expresa una visión estética", category: "Arte", wordId: 10, startRow: 1, startCol: 0, isAcross: false, number: 4);

    const rows = 5;
    const cols = 8;
    List<List<CrosswordCell>> grid = List.generate(rows, (r) => List.generate(cols, (c) => CrosswordCell(row: r, col: c, solutionChar: '', isBlack: true)));

    // Fill grid
    for (final pw in [w1, w2, w3, w4]) {
      for (int i = 0; i < pw.word.length; i++) {
        int r = pw.isAcross ? pw.startRow : pw.startRow + i;
        int c = pw.isAcross ? pw.startCol + i : pw.startCol;
        grid[r][c] = CrosswordCell(
          row: r,
          col: c,
          solutionChar: pw.word[i],
          isBlack: false,
          number: (r == pw.startRow && c == pw.startCol) ? pw.number : grid[r][c].number,
        );
      }
    }

    return CrosswordBoard(
      title: title,
      category: category,
      rows: rows,
      cols: cols,
      grid: grid,
      placedWords: [w1, w2, w3, w4],
    );
  }

  static CrosswordBoard generateTutorialBoard() {
    // Tutorial Board: "PALABRA" (Horizontal) and "PAPEL" (Vertical)
    // Both intersect perfectly at (0, 0) sharing the letter 'P'.
    final w1 = PlacedWord(
      word: "PALABRA",
      clue: "Unidad lingüística dotada de significado que compone los crucigramas.",
      category: "Tutorial",
      wordId: 99901,
      startRow: 0,
      startCol: 0,
      isAcross: true,
      number: 1,
    );
    final w2 = PlacedWord(
      word: "PAPEL",
      clue: "Soporte tradicional de imprenta donde se lee la prensa matutina.",
      category: "Tutorial",
      wordId: 99902,
      startRow: 0,
      startCol: 0,
      isAcross: false,
      number: 1,
    );

    const rows = 5;
    const cols = 7;
    List<List<CrosswordCell>> grid = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => CrosswordCell(row: r, col: c, solutionChar: '', isBlack: true),
      ),
    );

    for (final pw in [w1, w2]) {
      for (int i = 0; i < pw.word.length; i++) {
        int r = pw.isAcross ? pw.startRow : pw.startRow + i;
        int c = pw.isAcross ? pw.startCol + i : pw.startCol;
        grid[r][c] = CrosswordCell(
          row: r,
          col: c,
          solutionChar: pw.word[i],
          isBlack: false,
          number: (r == pw.startRow && c == pw.startCol) ? 1 : grid[r][c].number,
        );
      }
    }

    return CrosswordBoard(
      title: "Edición Tutorial: Tu Primer Crucigrama",
      category: "Tutorial",
      rows: rows,
      cols: cols,
      grid: grid,
      placedWords: [w1, w2],
    );
  }
}
