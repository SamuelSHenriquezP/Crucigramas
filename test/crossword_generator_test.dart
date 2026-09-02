import 'package:flutter_test/flutter_test.dart';
import 'package:crucigramas/services/dictionary_repository.dart';
import 'package:crucigramas/services/crossword_generator.dart';
import 'package:crucigramas/services/game_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dictionary and Crossword Generator Tests', () {
    final repo = DictionaryRepository();

    setUp(() async {
      await repo.loadDictionary();
    });

    test('DictionaryRepository loads 1000 words correctly', () {
      expect(repo.isLoaded, isTrue);
      expect(repo.allWords.length, equals(1000));
    });

    test('CrosswordGenerator creates a valid board from database', () async {
      final board = await CrosswordGenerator.generateBoard(
        title: "Edición de Prueba",
        category: "Todos",
        targetWordsCount: 8,
      );

      expect(board, isNotNull);
      expect(board.placedWords.length, greaterThanOrEqualTo(3));
      expect(board.rows, greaterThan(0));
      expect(board.cols, greaterThan(0));
      expect(board.grid.length, equals(board.rows));
      expect(board.grid[0].length, equals(board.cols));
    });

    test('CrosswordBoard calculates completion percentage accurately', () async {
      final board = await CrosswordGenerator.generateBoard(
        title: "Prueba de Porcentaje",
        category: "Todos",
        targetWordsCount: 5,
      );

      expect(board.completionPercentage, equals(0.0));
      expect(board.isComplete, isFalse);

      // Solve all non-black cells
      for (int r = 0; r < board.rows; r++) {
        for (int c = 0; c < board.cols; c++) {
          final cell = board.grid[r][c];
          if (!cell.isBlack) {
            cell.userChar = cell.solutionChar;
          }
        }
      }

      expect(board.completionPercentage, equals(1.0));
      expect(board.isComplete, isTrue);
    });

    test('GameStateProvider draft auto-save and resume test', () async {
      final gameState = GameStateProvider();
      await gameState.startNewLevel(
        title: "Nivel en Borrador",
        category: "Todos",
      );

      expect(gameState.currentBoard, isNotNull);
      
      // Simulate user entering a letter
      gameState.onKeyInput('A');
      expect(gameState.hasSavedDraft, isTrue);
      expect(gameState.draftTitle, equals("Nivel en Borrador"));

      // Clear current board and resume from saved draft
      await gameState.resumeSavedDraft();
      expect(gameState.currentBoard, isNotNull);
      expect(gameState.currentBoard!.title, equals("Nivel en Borrador"));
    });

    test('Hint mechanics: revealLetter, revealWord, and checkErrors', () async {
      final gameState = GameStateProvider();
      await gameState.startNewLevel(
        title: "Nivel de Pistas",
        category: "Todos",
      );

      final initialCoins = gameState.coins;

      // Test reveal letter (35 coins)
      bool letterRevealed = gameState.revealLetter();
      if (initialCoins >= 35) {
        expect(letterRevealed, isTrue);
        expect(gameState.coins, equals(initialCoins - 35));
      }

      // Test reveal word (80 coins)
      final coinsBeforeWord = gameState.coins;
      bool wordRevealed = gameState.revealWord();
      if (coinsBeforeWord >= 80) {
        expect(wordRevealed, isTrue);
        expect(gameState.coins, equals(coinsBeforeWord - 80));
      }

      // Test check errors (25 coins)
      final coinsBeforeCheck = gameState.coins;
      bool checked = gameState.checkErrors();
      if (coinsBeforeCheck >= 25) {
        expect(checked, isTrue);
        expect(gameState.coins, equals(coinsBeforeCheck - 25));
      }
    });
  });
}
