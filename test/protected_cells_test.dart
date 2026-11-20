import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crucigramas/services/game_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('direct typing and deletion preserve revealed cells', () async {
    SharedPreferences.setMockInitialValues({'sound_enabled': false});
    final game = GameStateProvider();
    await game.startTutorialLevel();
    game.selectCell(0, 1);
    expect(game.useFreeDailyHint(), isTrue);
    final revealed = game.currentBoard!.grid[0][1];
    final letter = revealed.userChar;
    game.selectCell(0, 1);
    game.onKeyInput('Z');
    expect(revealed.userChar, letter);
    game.selectCell(0, 1);
    game.onBackspace();
    expect(revealed.userChar, letter);
    game.clearCurrentWord();
    expect(revealed.userChar, letter);
    game.dispose();
  });

  test(
    'direct typing and deletion preserve completed perpendicular words',
    () async {
      SharedPreferences.setMockInitialValues({'sound_enabled': false});
      final game = GameStateProvider();
      await game.startTutorialLevel();
      final board = game.currentBoard!;
      final down = board.placedWords.firstWhere((w) => !w.isAcross);
      for (int i = 0; i < down.word.length; i++) {
        final cell = board.grid[down.startRow + i][down.startCol];
        cell.userChar = cell.solutionChar;
      }
      final across = board.placedWords.firstWhere(
        (w) => w.isAcross && w.containsCell(down.startRow, down.startCol),
      );
      game.selectCell(down.startRow, down.startCol);
      if (!game.isAcrossFocus) game.selectCell(down.startRow, down.startCol);
      expect(game.currentFocusedWord, across);
      final crossing = board.grid[down.startRow][down.startCol];
      final letter = crossing.userChar;
      game.onKeyInput('Z');
      game.selectCell(down.startRow, down.startCol);
      game.onBackspace();
      expect(crossing.userChar, letter);
      game.dispose();
    },
  );
}
