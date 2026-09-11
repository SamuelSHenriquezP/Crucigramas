import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crucigramas/models/crossword_board.dart';
import 'package:crucigramas/models/crossword_cell.dart';
import 'package:crucigramas/models/completed_edition.dart';
import 'package:crucigramas/services/crossword_generator.dart';
import 'package:crucigramas/services/game_state_provider.dart';
import 'package:crucigramas/services/dictionary_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final dict = DictionaryRepository();
    await dict.loadDictionary();
  });

  group('CrosswordBoard Serialization Tests', () {
    test('CrosswordBoard toJson and fromJson preserves exact structure', () {
      final tutorialBoard = CrosswordGenerator.generateTutorialBoard();
      final json = tutorialBoard.toJson();
      final restoredBoard = CrosswordBoard.fromJson(json);

      expect(restoredBoard.title, equals(tutorialBoard.title));
      expect(restoredBoard.category, equals(tutorialBoard.category));
      expect(restoredBoard.rows, equals(tutorialBoard.rows));
      expect(restoredBoard.cols, equals(tutorialBoard.cols));
      expect(restoredBoard.placedWords.length, equals(tutorialBoard.placedWords.length));
      expect(restoredBoard.placedWords[0].word, equals("PALABRA"));
      expect(restoredBoard.placedWords[1].word, equals("PAPEL"));
      expect(restoredBoard.grid[0][0].solutionChar, equals('P'));
      expect(restoredBoard.grid[0][1].solutionChar, equals('A'));
      expect(restoredBoard.grid[0][2].solutionChar, equals('L'));
    });
  });

  group('Draft Persistence & Exact Restoration', () {
    test('Saving draft and resuming restores exact board layout without regenerating', () async {
      SharedPreferences.setMockInitialValues({});
      final gameState = GameStateProvider();

      // Start a tutorial level
      await gameState.startTutorialLevel();
      final originalBoard = gameState.currentBoard!;
      expect(originalBoard.title, contains("Tutorial"));

      // Enter first letter 'P'
      gameState.onKeyInput('P');
      expect(gameState.hasSavedDraft, isTrue);
      expect(gameState.currentBoard!.grid[0][0].userChar, equals('P'));

      // Enter second letter 'A'
      gameState.onKeyInput('A');
      expect(gameState.currentBoard!.grid[0][1].userChar, equals('A'));

      // Simulate resuming saved draft
      await gameState.resumeSavedDraft();

      expect(gameState.currentBoard, isNotNull);
      // Ensure the restored board is NOT a different random board
      expect(gameState.currentBoard!.title, equals(originalBoard.title));
      expect(gameState.currentBoard!.category, equals("Tutorial"));
      expect(gameState.currentBoard!.rows, equals(originalBoard.rows));
      expect(gameState.currentBoard!.cols, equals(originalBoard.cols));
      expect(gameState.currentBoard!.grid[0][0].userChar, equals('P'));
      expect(gameState.currentBoard!.grid[0][1].userChar, equals('A'));
      expect(gameState.currentBoard!.placedWords[0].word, equals("PALABRA"));
      expect(gameState.currentBoard!.placedWords[1].word, equals("PAPEL"));
    });
  });

  group('Tutorial Level Mechanics', () {
    test('Tutorial board is correctly configured with PALABRA and PAPEL', () async {
      final gameState = GameStateProvider();
      await gameState.startTutorialLevel();

      expect(gameState.isTutorialLevel, isTrue);
      expect(gameState.currentBoard, isNotNull);

      final acrossWord = gameState.currentBoard!.placedWords.firstWhere((w) => w.isAcross);
      expect(acrossWord.word, equals("PALABRA"));
      expect(acrossWord.clue, contains("significado"));

      final downWord = gameState.currentBoard!.placedWords.firstWhere((w) => !w.isAcross);
      expect(downWord.word, equals("PAPEL"));
      expect(downWord.clue, contains("imprenta"));

      // Intersection check at (0, 0)
      expect(gameState.currentBoard!.grid[0][0].solutionChar, equals('P'));
      expect(gameState.currentBoard!.grid[0][0].number, equals(1));
    });

    test('Completing tutorial marks isTutorialCompleted and archives in history', () async {
      SharedPreferences.setMockInitialValues({});
      final gameState = GameStateProvider();
      await gameState.startTutorialLevel();

      // Solve PALABRA: P A L A B R A at row 0, cols 0..6
      const palabra = "PALABRA";
      for (int c = 0; c < palabra.length; c++) {
        gameState.currentBoard!.grid[0][c].userChar = palabra[c];
      }

      // Solve PAPEL: P A P E L at col 0, rows 0..4 (leaving last letter 'L' empty)
      gameState.currentBoard!.grid[1][0].userChar = 'A';
      gameState.currentBoard!.grid[2][0].userChar = 'P';
      gameState.currentBoard!.grid[3][0].userChar = 'E';

      // Focus last cell at (4, 0) and type 'L'
      gameState.selectCell(4, 0);
      gameState.onKeyInput('L');

      expect(gameState.isLevelComplete, isTrue);
      expect(gameState.isTutorialCompleted, isTrue);
      expect(gameState.completedHistory.length, greaterThanOrEqualTo(1));

      final lastEdition = gameState.completedHistory.first;
      expect(lastEdition.category, equals("Tutorial"));
      expect(lastEdition.wordsCount, equals(2));
      expect(lastEdition.boardData, isNotNull);
    });
  });

  group('Hemeroteca (History) Tests', () {
    test('CompletedEdition serialization', () {
      final edition = CompletedEdition(
        id: "test_1",
        title: "Edición Especial",
        category: "Historia",
        wordsCount: 5,
        elapsedSeconds: 125,
        completedAt: DateTime(2026, 9, 11, 10, 30),
        coinsEarned: 100,
      );

      final json = edition.toJson();
      final restored = CompletedEdition.fromJson(json);

      expect(restored.id, equals("test_1"));
      expect(restored.title, equals("Edición Especial"));
      expect(restored.formattedDuration, equals("02:05"));
      expect(restored.wordsCount, equals(5));
      expect(restored.coinsEarned, equals(100));
    });

    test('Load board from history activates review mode', () async {
      final gameState = GameStateProvider();
      final tutorialBoard = CrosswordGenerator.generateTutorialBoard();
      
      final edition = CompletedEdition(
        id: "hist_1",
        title: "Archivo Histórico",
        category: "Tutorial",
        wordsCount: 2,
        elapsedSeconds: 60,
        completedAt: DateTime.now(),
        coinsEarned: 150,
        boardData: tutorialBoard.toJson(),
      );

      gameState.loadBoardFromHistory(edition);

      expect(gameState.isReviewMode, isTrue);
      expect(gameState.isLevelComplete, isTrue);
      expect(gameState.currentBoard, isNotNull);
      expect(gameState.currentBoard!.title, equals(tutorialBoard.title));
    });
  });
}
