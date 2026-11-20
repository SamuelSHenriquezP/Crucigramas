import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crucigramas/services/game_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({'sound_enabled': false}));

  test(
    'daily draft retains daily completion and its full reward after reopening',
    () async {
      final original = GameStateProvider();
      await original.startDailyChallenge();
      original.saveLevelDraft();
      final reopened = GameStateProvider();
      await reopened.ready;
      await reopened.resumeSavedDraft();
      expect(reopened.isDailyLevel, isTrue);
      expect(reopened.levelReward, 200);
      final coins = reopened.coins;
      final cells = reopened.currentBoard!.grid
          .expand((row) => row)
          .where((c) => !c.isBlack)
          .toList();
      for (final cell in cells.take(cells.length - 1)) {
        cell.userChar = cell.solutionChar;
      }
      final last = cells.last;
      reopened.selectCell(last.row, last.col);
      reopened.onKeyInput(last.solutionChar);
      expect(reopened.isLevelComplete, isTrue);
      expect(reopened.isDailyCompletedToday, isTrue);
      expect(reopened.coins, coins + 200);
      reopened.onKeyInput(last.solutionChar);
      expect(reopened.coins, coins + 200);
      await reopened.flushPendingChanges();
      original.dispose();
      reopened.dispose();
    },
  );

  test(
    'normal level started after daily does not count as a daily level',
    () async {
      final game = GameStateProvider();
      await game.startDailyChallenge();
      await game.startNewLevel(title: 'Normal', category: 'Todos');
      expect(game.isDailyLevel, isFalse);
      game.dispose();
    },
  );

  test('tutorial draft preserves its 150 coin reward', () async {
    final original = GameStateProvider();
    await original.startTutorialLevel();
    original.saveLevelDraft();
    final reopened = GameStateProvider();
    await reopened.resumeSavedDraft();
    expect(reopened.isTutorialLevel, isTrue);
    expect(reopened.levelReward, 150);
    original.dispose();
    reopened.dispose();
  });
}
