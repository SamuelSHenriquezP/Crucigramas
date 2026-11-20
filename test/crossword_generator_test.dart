import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crucigramas/models/crossword_board.dart';
import 'package:crucigramas/models/crossword_cell.dart';
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

    test(
      'DictionaryRepository loads 4000 unique words balanced across 25 categories',
      () {
        expect(repo.isLoaded, isTrue);
        expect(repo.allWords.length, equals(4000));
        expect(repo.allWords.map((w) => w.word).toSet().length, equals(4000));
        final cats = repo.getCategories().where((c) => c != 'Todos').toList();
        expect(cats.length, equals(25));
        for (final c in cats) {
          expect(repo.getWordsByCategory(c).length, greaterThanOrEqualTo(150));
        }
      },
    );

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

    test(
      'CrosswordGenerator generates a large board with advanced difficulty',
      () async {
        final board = await CrosswordGenerator.generateBoard(
          title: "Edición Avanzada Grande",
          category: "Todos",
          targetWordsCount: 12,
          difficultyFilter: "avanzado",
        );

        expect(board, isNotNull);
        expect(board.placedWords.length, greaterThanOrEqualTo(8));
        expect(board.rows, greaterThan(4));
        expect(board.cols, greaterThan(4));
      },
    );

    test(
      'CrosswordBoard calculates completion percentage accurately',
      () async {
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
      },
    );

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

    test(
      'CrosswordGenerator avoids solved words when fresh candidates exist',
      () async {
        final firstBoard = await CrosswordGenerator.generateBoard(
          title: "Historia 1",
          category: "Historia",
          targetWordsCount: 6,
        );
        final solvedIds = firstBoard.placedWords.map((w) => w.wordId).toSet();

        final secondBoard = await CrosswordGenerator.generateBoard(
          title: "Historia 2",
          category: "Historia",
          targetWordsCount: 6,
          excludeWordIds: solvedIds,
        );
        final secondIds = secondBoard.placedWords.map((w) => w.wordId).toSet();

        expect(secondIds.intersection(solvedIds), isEmpty);
      },
    );

    test(
      'Solving one word immediately updates solvedWordIds before level completion',
      () async {
        SharedPreferences.setMockInitialValues({});
        final gameState = GameStateProvider();
        await gameState.startNewLevel(
          title: "Progreso Vivo",
          category: "Todos",
          targetWordsCount: 6,
        );

        final firstWord = gameState.currentBoard!.placedWords.first;
        expect(gameState.solvedWordIds.contains(firstWord.wordId), isFalse);

        // Fill all cells of firstWord except the final character
        for (int i = 0; i < firstWord.word.length - 1; i++) {
          final r = firstWord.isAcross
              ? firstWord.startRow
              : firstWord.startRow + i;
          final c = firstWord.isAcross
              ? firstWord.startCol + i
              : firstWord.startCol;
          gameState.currentBoard!.grid[r][c].userChar = firstWord.word[i];
        }

        final lastIdx = firstWord.word.length - 1;
        final lastR = firstWord.isAcross
            ? firstWord.startRow
            : firstWord.startRow + lastIdx;
        final lastC = firstWord.isAcross
            ? firstWord.startCol + lastIdx
            : firstWord.startCol;
        gameState.selectCell(lastR, lastC);
        gameState.onKeyInput(firstWord.word[lastIdx]);

        expect(gameState.solvedWordIds.contains(firstWord.wordId), isTrue);
        expect(gameState.isLevelComplete, isFalse);
      },
    );

    test(
      'clearCurrentWord clears editable cells but preserves completed crossings and revealed letters',
      () async {
        SharedPreferences.setMockInitialValues({});
        final gameState = GameStateProvider();
        await gameState.startTutorialLevel();

        // Complete vertical word "PAPEL" at col 0 (rows 0..4), intersecting "PALABRA" at (0,0)
        const papel = 'PAPEL';
        for (int r = 0; r < papel.length; r++) {
          gameState.selectCell(r, 0);
          gameState.onKeyInput(papel[r]);
        }
        expect(
          gameState.completedWordIdsInCurrentLevel.contains(99902),
          isTrue,
        );

        // Reveal (0, 3) in "PALABRA"
        gameState.selectCell(0, 3);
        expect(gameState.revealLetter(), isTrue);
        expect(gameState.currentBoard!.grid[0][3].isRevealed, isTrue);

        // Type letters in editable cells of horizontal "PALABRA"
        gameState.selectCell(0, 1);
        gameState.onKeyInput('X');
        gameState.selectCell(0, 2);
        gameState.onKeyInput('Y');
        gameState.selectCell(0, 4);
        gameState.onKeyInput('Z');

        // Focus "PALABRA" horizontally and clear it
        gameState.selectCell(0, 1);
        gameState.clearCurrentWord();

        // Editable cells cleared
        expect(gameState.currentBoard!.grid[0][1].userChar, isEmpty);
        expect(gameState.currentBoard!.grid[0][2].userChar, isEmpty);
        expect(gameState.currentBoard!.grid[0][4].userChar, isEmpty);
        // Completed perpendicular crossing (0,0) and revealed cell (0,3) preserved
        expect(gameState.currentBoard!.grid[0][0].userChar, equals('P'));
        expect(gameState.currentBoard!.grid[0][3].userChar, equals('A'));
      },
    );

    test(
      'useFreeDailyHint reveals one letter for 0 coins and only works once per day',
      () async {
        SharedPreferences.setMockInitialValues({});
        final gameState = GameStateProvider();
        await gameState.startTutorialLevel();

        expect(gameState.hasFreeDailyHintToday, isTrue);
        final initialCoins = gameState.coins;

        gameState.selectCell(0, 1);
        final firstUse = gameState.useFreeDailyHint();
        expect(firstUse, isTrue);
        expect(gameState.coins, equals(initialCoins));
        expect(gameState.currentBoard!.grid[0][1].isCorrect, isTrue);
        expect(gameState.currentBoard!.grid[0][1].isRevealed, isTrue);
        expect(gameState.hasFreeDailyHintToday, isFalse);

        // Second use on the same day must be rejected
        gameState.selectCell(0, 2);
        final secondUse = gameState.useFreeDailyHint();
        expect(secondUse, isFalse);
        expect(gameState.currentBoard!.grid[0][2].userChar, isEmpty);
        expect(gameState.coins, equals(initialCoins));

        // Persists across provider instances
        final reloadedState = GameStateProvider();
        await reloadedState.startTutorialLevel();
        expect(reloadedState.hasFreeDailyHintToday, isFalse);
      },
    );

    test(
      'onKeyInput skips completed perpendicular crossing cells when advancing cursor',
      () async {
        // Deterministic board: "CASA" across at (1,0)..(1,3), "OSO" down at (0,2)..(2,2)
        final wAcross = PlacedWord(
          word: 'CASA',
          clue: 'Vivienda',
          category: 'Hogar',
          wordId: 88001,
          startRow: 1,
          startCol: 0,
          isAcross: true,
          number: 1,
        );
        final wDown = PlacedWord(
          word: 'OSO',
          clue: 'Estrella',
          category: 'Naturaleza',
          wordId: 88002,
          startRow: 0,
          startCol: 2,
          isAcross: false,
          number: 2,
        );
        final grid = List.generate(
          3,
          (r) => List.generate(
            4,
            (c) =>
                CrosswordCell(row: r, col: c, solutionChar: '', isBlack: true),
          ),
        );
        for (final pw in [wAcross, wDown]) {
          for (int i = 0; i < pw.word.length; i++) {
            final r = pw.isAcross ? pw.startRow : pw.startRow + i;
            final c = pw.isAcross ? pw.startCol + i : pw.startCol;
            grid[r][c] = CrosswordCell(
              row: r,
              col: c,
              solutionChar: pw.word[i],
              isBlack: false,
            );
          }
        }
        final customBoard = CrosswordBoard(
          title: 'Tablero Cruce',
          category: 'Todos',
          rows: 3,
          cols: 4,
          grid: grid,
          placedWords: [wAcross, wDown],
        );

        SharedPreferences.setMockInitialValues({
          'has_saved_draft': true,
          'draft_title': 'Tablero Cruce',
          'draft_category': 'Todos',
          'draft_board_json': jsonEncode(customBoard.toJson()),
        });

        final gameState = GameStateProvider();
        await Future<void>.delayed(const Duration(milliseconds: 50));
        expect(gameState.hasSavedDraft, isTrue);
        await gameState.resumeSavedDraft();

        // Complete vertical "OSO" so intersection (1,2) is locked by completed cross
        gameState.selectCell(0, 2);
        gameState.onKeyInput('O');
        gameState.onKeyInput('S');
        gameState.onKeyInput('O');
        expect(
          gameState.completedWordIdsInCurrentLevel.contains(88002),
          isTrue,
        );

        // Type "CA" starting at (1,0); after typing at (1,1), cursor must skip (1,2) and land on (1,3)
        gameState.selectCell(1, 0);
        gameState.onKeyInput('C');
        expect(gameState.focusedRow, equals(1));
        expect(gameState.focusedCol, equals(1));

        gameState.onKeyInput('A');
        expect(gameState.focusedRow, equals(1));
        expect(gameState.focusedCol, equals(3));
        expect(gameState.currentBoard!.grid[1][2].userChar, equals('S'));
      },
    );

    test('soundEnabled defaults to true and toggles cleanly', () async {
      SharedPreferences.setMockInitialValues({});
      final gameState = GameStateProvider();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(gameState.soundEnabled, isTrue);
      gameState.toggleSound();
      expect(gameState.soundEnabled, isFalse);
      gameState.toggleSound();
      expect(gameState.soundEnabled, isTrue);
    });
  });
}
