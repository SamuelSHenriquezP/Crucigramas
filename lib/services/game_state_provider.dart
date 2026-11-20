import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crossword_board.dart';
import '../models/crossword_cell.dart';
import '../models/word_entry.dart';
import '../models/completed_edition.dart';
import 'dictionary_repository.dart';
import 'crossword_generator.dart';
import 'crossword_audio.dart';

class GameStateProvider with ChangeNotifier {
  static Future<void> _pendingWrites = Future.value();
  int _coins = 150;
  int _streak = 1;
  int _completedLevelsCount = 0;
  Set<int> _solvedWordIds = {};

  CrosswordBoard? _currentBoard;
  int _focusedRow = -1;
  int _focusedCol = -1;
  bool _isAcrossFocus = true;
  bool _isLevelComplete = false;
  int _elapsedSeconds = 0;
  bool _isLoading = false;

  // Word completion celebration
  final Set<int> _completedWordIdsInCurrentLevel = {};
  PlacedWord? _lastCompletedWordCelebration;
  bool _lastCelebratedWordIsNew = false;
  int _wordCelebrationTick = 0;

  // Daily Challenge & Tutorial Tracking
  String _lastDailyCompletedDate = '';
  String _lastFreeHintDate = '';
  bool _soundEnabled = true;
  bool _isDailyLevel = false;
  String _dailyLevelDate = '';
  bool _isTutorialLevel = false;
  bool _isTutorialCompleted = false;
  bool _isReviewMode = false;
  int _levelReward = 100;

  // History Tracking (Hemeroteca)
  List<CompletedEdition> _completedHistory = [];

  // New discovered words in current completed level
  List<WordEntry> _newlyDiscoveredWords = [];

  // Getters
  int get coins => _coins;
  int get streak => _streak;
  int get completedLevelsCount => _completedLevelsCount;
  Set<int> get solvedWordIds => _solvedWordIds;
  CrosswordBoard? get currentBoard => _currentBoard;
  int get focusedRow => _focusedRow;
  int get focusedCol => _focusedCol;
  bool get isAcrossFocus => _isAcrossFocus;
  bool get isLevelComplete => _isLevelComplete;
  int get elapsedSeconds => _elapsedSeconds;
  bool get isLoading => _isLoading;
  List<WordEntry> get newlyDiscoveredWords => _newlyDiscoveredWords;
  bool get isDailyLevel => _isDailyLevel;
  bool get isTutorialLevel => _isTutorialLevel;
  bool get isTutorialCompleted => _isTutorialCompleted;
  bool get isReviewMode => _isReviewMode;
  int get levelReward => _levelReward;
  Set<int> get completedWordIdsInCurrentLevel =>
      _completedWordIdsInCurrentLevel;
  PlacedWord? get lastCompletedWordCelebration => _lastCompletedWordCelebration;
  bool get lastCelebratedWordIsNew => _lastCelebratedWordIsNew;
  int get wordCelebrationTick => _wordCelebrationTick;
  List<CompletedEdition> get completedHistory =>
      List.unmodifiable(_completedHistory.reversed);

  String get todayDateString {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  bool get isDailyCompletedToday => _lastDailyCompletedDate == todayDateString;
  bool get hasFreeDailyHintToday =>
      _lastFreeHintDate != todayDateString && !_isReviewMode;
  bool get soundEnabled => _soundEnabled;

  GameStateProvider() {
    ready = _loadStateFromPrefs();
  }
  late final Future<void> ready;

  Future<void> flushPendingChanges() => _pendingWrites;

  bool _hasNoAds = false;
  Set<String> _unlockedShopItems = {
    'default_theme',
    'font_playfair',
    'title_cronista',
  };
  String _activeThemeId = 'default_theme';
  String _activeFontId = 'font_playfair';
  String _activeTitleId = 'title_cronista';

  // Draft Auto-Save State
  bool _hasSavedDraft = false;
  String _draftTitle = '';
  String _draftCategory = '';
  int _draftElapsedSeconds = 0;
  String _draftBoardJson = '';
  String _draftDailyDate = '';
  int _draftLevelReward = 100;
  List<String> _draftGridState = [];

  Set<String> get unlockedShopItems => _unlockedShopItems;
  String get activeThemeId => _activeThemeId;
  String get activeFontId => _activeFontId;
  String get activeTitleId => _activeTitleId;
  bool get hasNoAds => _hasNoAds;
  bool get hasSavedDraft => _hasSavedDraft;
  String get draftTitle =>
      _draftTitle.isNotEmpty ? _draftTitle : "Edición en Borrador";

  Future<void> _loadStateFromPrefs() async {
    try {
      await _pendingWrites;
      final prefs = await SharedPreferences.getInstance();
      _coins = prefs.getInt('coins') ?? 150;
      _streak = prefs.getInt('streak') ?? 1;
      _completedLevelsCount = prefs.getInt('completed_levels') ?? 0;
      _activeThemeId = prefs.getString('active_theme') ?? 'default_theme';
      _activeFontId = prefs.getString('active_font') ?? 'font_playfair';
      _activeTitleId = prefs.getString('active_title') ?? 'title_cronista';
      _lastDailyCompletedDate = prefs.getString('last_daily_date') ?? '';
      _lastFreeHintDate = prefs.getString('last_free_hint_date') ?? '';
      _soundEnabled = prefs.getBool('sound_enabled') ?? true;
      _hasNoAds = prefs.getBool('has_no_ads') ?? false;
      _isTutorialCompleted = prefs.getBool('tutorial_completed') ?? false;

      // Draft state loading
      _hasSavedDraft = prefs.getBool('has_saved_draft') ?? false;
      _draftTitle = prefs.getString('draft_title') ?? '';
      _draftCategory = prefs.getString('draft_category') ?? '';
      _draftElapsedSeconds = prefs.getInt('draft_elapsed') ?? 0;
      _draftBoardJson = prefs.getString('draft_board_json') ?? '';
      // Older drafts carried their daily date only in the title.
      final legacyDailyDate = RegExp(
        r'\((\d{4}-\d{2}-\d{2})\)$',
      ).firstMatch(_draftTitle)?.group(1);
      _draftDailyDate =
          prefs.getString('draft_daily_date') ??
          (_draftTitle.startsWith('Crucigrama del Día')
              ? legacyDailyDate ?? ''
              : '');
      _draftLevelReward =
          prefs.getInt('draft_level_reward') ??
          (_draftDailyDate.isNotEmpty
              ? 200
              : (_draftCategory == 'Tutorial' ? 150 : 100));
      _draftGridState = prefs.getStringList('draft_grid_state') ?? [];

      // Completed history loading
      final historyJson = prefs.getString('completed_history_json');
      if (historyJson != null && historyJson.isNotEmpty) {
        try {
          final List decoded = jsonDecode(historyJson);
          _completedHistory = decoded
              .map((e) => CompletedEdition.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (_) {}
      }

      final unlockedList =
          prefs.getStringList('unlocked_shop') ??
          ['default_theme', 'font_playfair', 'title_cronista'];
      _unlockedShopItems = unlockedList.toSet();

      final solvedList = prefs.getStringList('solved_words') ?? [];
      _solvedWordIds = solvedList.map((e) => int.parse(e)).toSet();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveStateToPrefs() {
    _pendingWrites = _pendingWrites.then((_) => _persistState());
    return _pendingWrites;
  }

  Future<void> _persistState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('coins', _coins);
      await prefs.setInt('streak', _streak);
      await prefs.setInt('completed_levels', _completedLevelsCount);
      await prefs.setString('active_theme', _activeThemeId);
      await prefs.setString('active_font', _activeFontId);
      await prefs.setString('active_title', _activeTitleId);
      await prefs.setString('last_daily_date', _lastDailyCompletedDate);
      await prefs.setString('last_free_hint_date', _lastFreeHintDate);
      await prefs.setBool('sound_enabled', _soundEnabled);
      await prefs.setBool('has_no_ads', _hasNoAds);
      await prefs.setBool('tutorial_completed', _isTutorialCompleted);

      // Draft state saving
      await prefs.setBool('has_saved_draft', _hasSavedDraft);
      await prefs.setString('draft_title', _draftTitle);
      await prefs.setString('draft_category', _draftCategory);
      await prefs.setInt('draft_elapsed', _draftElapsedSeconds);
      await prefs.setString('draft_board_json', _draftBoardJson);
      await prefs.setString('draft_daily_date', _draftDailyDate);
      await prefs.setInt('draft_level_reward', _draftLevelReward);
      await prefs.setStringList('draft_grid_state', _draftGridState);

      // Completed history saving
      try {
        final histJson = jsonEncode(
          _completedHistory.map((e) => e.toJson()).toList(),
        );
        await prefs.setString('completed_history_json', histJson);
      } catch (_) {}

      await prefs.setStringList('unlocked_shop', _unlockedShopItems.toList());
      await prefs.setStringList(
        'solved_words',
        _solvedWordIds.map((e) => e.toString()).toList(),
      );
    } catch (_) {}
  }

  void saveLevelDraft() {
    if (_currentBoard == null || _isLevelComplete || _isReviewMode) return;
    _hasSavedDraft = true;
    _draftTitle = _currentBoard!.title;
    _draftCategory = _currentBoard!.category;
    _draftElapsedSeconds = _elapsedSeconds;
    _draftDailyDate = _isDailyLevel ? _dailyLevelDate : '';
    _draftLevelReward = _levelReward;
    try {
      _draftBoardJson = jsonEncode(_currentBoard!.toJson());
    } catch (e) {
      debugPrint("Error serializing board to JSON: $e");
    }
    _saveStateToPrefs();
    notifyListeners();
  }

  Future<void> resumeSavedDraft() async {
    await ready;
    if (!_hasSavedDraft) return;

    if (_draftBoardJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(_draftBoardJson) as Map<String, dynamic>;
        _currentBoard = CrosswordBoard.fromJson(decoded);
        _elapsedSeconds = _draftElapsedSeconds;
        _isLevelComplete = false;
        _isReviewMode = false;
        _dailyLevelDate = _draftDailyDate;
        _isDailyLevel = _dailyLevelDate.isNotEmpty;
        _levelReward = _draftLevelReward;
        _isTutorialLevel = _currentBoard!.category == 'Tutorial';
        _completedWordIdsInCurrentLevel.clear();

        // Restore already completed word IDs
        for (final word in _currentBoard!.placedWords) {
          bool wordComplete = true;
          for (int i = 0; i < word.word.length; i++) {
            int r = word.isAcross ? word.startRow : word.startRow + i;
            int c = word.isAcross ? word.startCol + i : word.startCol;
            final cell = _currentBoard!.grid[r][c];
            if (!cell.isCorrect) {
              wordComplete = false;
              break;
            }
          }
          if (wordComplete) {
            _completedWordIdsInCurrentLevel.add(word.wordId);
          }
        }

        _selectFirstPlayableCell();
        notifyListeners();
        return;
      } catch (e) {
        debugPrint("Error deserializing board JSON: $e");
      }
    }

    // Fallback if no json available
    await startNewLevel(
      title: _draftTitle.isNotEmpty ? _draftTitle : "Borrador de Edición",
      category: _draftCategory.isNotEmpty ? _draftCategory : "Todos",
      reward: _draftLevelReward,
      dailyDate: _draftDailyDate.isEmpty ? null : _draftDailyDate,
    );
    notifyListeners();
  }

  void clearLevelDraft() {
    _draftDailyDate = '';
    _draftLevelReward = 100;
    _hasSavedDraft = false;
    _draftTitle = '';
    _draftCategory = '';
    _draftElapsedSeconds = 0;
    _draftBoardJson = '';
    _draftGridState = [];
    _saveStateToPrefs();
    notifyListeners();
  }

  void addCoins(int amount) {
    _coins += amount;
    _saveStateToPrefs();
    notifyListeners();
  }

  void activateVipNoAds() {
    _hasNoAds = true;
    _saveStateToPrefs();
    notifyListeners();
  }

  bool isItemUnlocked(String id) => _unlockedShopItems.contains(id);

  bool buyShopItem(String itemId, int price) {
    if (_coins < price || isItemUnlocked(itemId)) return false;
    _coins -= price;
    _unlockedShopItems.add(itemId);
    _saveStateToPrefs();
    notifyListeners();
    return true;
  }

  void equipTheme(String themeId) {
    if (isItemUnlocked(themeId)) {
      _activeThemeId = themeId;
      _saveStateToPrefs();
      notifyListeners();
    }
  }

  void equipFont(String fontId) {
    if (isItemUnlocked(fontId)) {
      _activeFontId = fontId;
      _saveStateToPrefs();
      notifyListeners();
    }
  }

  void equipTitle(String titleId) {
    if (isItemUnlocked(titleId)) {
      _activeTitleId = titleId;
      _saveStateToPrefs();
      notifyListeners();
    }
  }

  Future<void> startDailyChallenge() async {
    await ready;
    _isTutorialLevel = false;
    _isReviewMode = false;
    _levelReward = 200;
    final dateStr = todayDateString;
    await startNewLevel(
      title: "Crucigrama del Día ($dateStr)",
      category: "Todos",
      targetWordsCount: 10,
      reward: 200,
      dailyDate: dateStr,
    );
  }

  Future<void> startTutorialLevel() async {
    await ready;
    _isLoading = true;
    _isLevelComplete = false;
    _isReviewMode = false;
    _isDailyLevel = false;
    _dailyLevelDate = '';
    _isTutorialLevel = true;
    _completedWordIdsInCurrentLevel.clear();
    _lastCompletedWordCelebration = null;
    _newlyDiscoveredWords = [];
    _elapsedSeconds = 0;
    _levelReward = 150;
    notifyListeners();

    _currentBoard = CrosswordGenerator.generateTutorialBoard();
    _selectFirstPlayableCell();
    _isLoading = false;
    notifyListeners();
  }

  void loadBoardFromHistory(CompletedEdition edition) {
    if (edition.boardData != null) {
      try {
        _currentBoard = CrosswordBoard.fromJson(edition.boardData!);
        _isReviewMode = true;
        _isLevelComplete = true;
        _isTutorialLevel = false;
        _isDailyLevel = false;
        _elapsedSeconds = edition.elapsedSeconds;
        _selectFirstPlayableCell();
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading history board: $e");
      }
    }
  }

  void clearCompletedHistory() {
    _completedHistory.clear();
    _saveStateToPrefs();
    notifyListeners();
  }

  Future<void> startNewLevel({
    required String title,
    required String category,
    int targetWordsCount = 8,
    String? difficultyFilter,
    int reward = 100,
    String? dailyDate,
  }) async {
    await ready;
    _isLoading = true;
    _isLevelComplete = false;
    _isReviewMode = false;
    _isTutorialLevel = false;
    _completedWordIdsInCurrentLevel.clear();
    _lastCompletedWordCelebration = null;
    _newlyDiscoveredWords = [];
    _elapsedSeconds = 0;
    _levelReward = reward;
    _dailyLevelDate = dailyDate ?? '';
    _isDailyLevel = _dailyLevelDate.isNotEmpty;
    notifyListeners();

    _currentBoard = await CrosswordGenerator.generateBoard(
      title: title,
      category: category,
      targetWordsCount: targetWordsCount,
      difficultyFilter: difficultyFilter,
      excludeWordIds: _solvedWordIds,
    );

    // Focus on first playable cell
    _selectFirstPlayableCell();

    _isLoading = false;
    notifyListeners();
  }

  void _selectFirstPlayableCell() {
    if (_currentBoard == null) return;
    for (int r = 0; r < _currentBoard!.rows; r++) {
      for (int c = 0; c < _currentBoard!.cols; c++) {
        if (!_currentBoard!.grid[r][c].isBlack) {
          _focusedRow = r;
          _focusedCol = c;
          final hasAcross = _currentBoard!.placedWords.any(
            (w) => w.isAcross && w.containsCell(r, c),
          );
          _isAcrossFocus = hasAcross;
          return;
        }
      }
    }
  }

  void selectCell(int r, int c) {
    if (_currentBoard == null) return;
    final cell = _currentBoard!.grid[r][c];
    if (cell.isBlack) return;

    final matchingWords = _currentBoard!.placedWords
        .where((w) => w.containsCell(r, c))
        .toList();
    if (matchingWords.isEmpty) return;

    final hasAcross = matchingWords.any((w) => w.isAcross);
    final hasDown = matchingWords.any((w) => !w.isAcross);

    if (_focusedRow == r && _focusedCol == c) {
      // Toggle direction only if this cell is an intersection of both Across & Down
      if (hasAcross && hasDown) {
        _isAcrossFocus = !_isAcrossFocus;
      }
    } else {
      _focusedRow = r;
      _focusedCol = c;
      // If cell only belongs to one direction, strictly enforce that direction
      if (hasAcross && !hasDown) {
        _isAcrossFocus = true;
      } else if (!hasAcross && hasDown) {
        _isAcrossFocus = false;
      }
      // If cell belongs to both, preserve the current direction so movement stays natural
    }
    notifyListeners();
  }

  PlacedWord? get currentFocusedWord {
    if (_currentBoard == null || _focusedRow == -1) return null;
    return _currentBoard!.getWordForCell(
      _focusedRow,
      _focusedCol,
      _isAcrossFocus,
    );
  }

  void selectNextWord() {
    if (_currentBoard == null) return;
    final allWords = _currentBoard!.placedWords;
    if (allWords.isEmpty) return;

    final curWord = currentFocusedWord;
    int curIdx = allWords.indexWhere((w) => w == curWord);
    int nextIdx = (curIdx + 1) % allWords.length;
    final nextW = allWords[nextIdx];
    _focusedRow = nextW.startRow;
    _focusedCol = nextW.startCol;
    _isAcrossFocus = nextW.isAcross;
    notifyListeners();
  }

  void selectPreviousWord() {
    if (_currentBoard == null) return;
    final allWords = _currentBoard!.placedWords;
    if (allWords.isEmpty) return;

    final curWord = currentFocusedWord;
    int curIdx = allWords.indexWhere((w) => w == curWord);
    int prevIdx = (curIdx - 1 + allWords.length) % allWords.length;
    final prevW = allWords[prevIdx];
    _focusedRow = prevW.startRow;
    _focusedCol = prevW.startCol;
    _isAcrossFocus = prevW.isAcross;
    notifyListeners();
  }

  /// Toggles optional tap/completion sound and haptic feedback.
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _saveStateToPrefs();
    notifyListeners();
  }

  void _playTapFeedback() {
    if (!_soundEnabled) return;
    CrosswordAudio.play('key');
  }

  void _playWordCompleteFeedback() {
    if (!_soundEnabled) return;
    CrosswordAudio.play('word');
  }

  bool _isCrossWordCompletedAt(int r, int c, PlacedWord activeWord) {
    if (_currentBoard == null) return false;
    final cell = _currentBoard!.grid[r][c];
    if (!cell.isCorrect) return false;
    return _currentBoard!.placedWords.any((other) {
      if (other.wordId == activeWord.wordId ||
          other.isAcross == activeWord.isAcross ||
          !other.containsCell(r, c)) {
        return false;
      }
      for (int i = 0; i < other.word.length; i++) {
        final int cr = other.isAcross ? other.startRow : other.startRow + i;
        final int cc = other.isAcross ? other.startCol + i : other.startCol;
        if (!_currentBoard!.grid[cr][cc].isCorrect) return false;
      }
      return true;
    });
  }

  bool _isCellEditableInWord(int r, int c, PlacedWord activeWord) {
    if (_currentBoard == null) return false;
    final cell = _currentBoard!.grid[r][c];
    return !cell.isBlack &&
        !cell.isRevealed &&
        !_isCrossWordCompletedAt(r, c, activeWord);
  }

  /// Clears editable cells in [currentFocusedWord], preserving revealed cells
  /// and intersections belonging to already completed perpendicular words.
  void clearCurrentWord() {
    if (_currentBoard == null || _isLevelComplete || _isReviewMode) return;
    final word = currentFocusedWord;
    if (word == null) return;

    bool changed = false;
    int? firstEditableRow;
    int? firstEditableCol;

    for (int i = 0; i < word.word.length; i++) {
      final int r = word.isAcross ? word.startRow : word.startRow + i;
      final int c = word.isAcross ? word.startCol + i : word.startCol;
      if (!_isCellEditableInWord(r, c, word)) continue;

      firstEditableRow ??= r;
      firstEditableCol ??= c;

      final cell = _currentBoard!.grid[r][c];
      if (cell.userChar.isNotEmpty || cell.isError) {
        cell.userChar = '';
        cell.isError = false;
        changed = true;
      }
    }

    if (changed) {
      _completedWordIdsInCurrentLevel.remove(word.wordId);
      if (firstEditableRow != null && firstEditableCol != null) {
        _focusedRow = firstEditableRow;
        _focusedCol = firstEditableCol;
      }
      saveLevelDraft();
      notifyListeners();
    }
  }

  void onKeyInput(String letter) {
    if (_currentBoard == null ||
        _focusedRow == -1 ||
        _isLevelComplete ||
        _isReviewMode) {
      return;
    }
    if (!RegExp(r'^[A-ZÑ]$').hasMatch(letter.toUpperCase())) return;
    final word = currentFocusedWord;
    if (word == null) return;
    if (!_isCellEditableInWord(_focusedRow, _focusedCol, word)) {
      if (!_moveToEditableCell(word, forward: true, wrap: true)) return;
    }
    final cell = _currentBoard!.grid[_focusedRow][_focusedCol];
    if (cell.isBlack) return;

    cell.userChar = letter.toUpperCase();
    cell.isError = false; // Reset error state on edit

    _playTapFeedback();
    _checkWordAndBoardCompletion();
    _advanceCursor();
    saveLevelDraft();
    notifyListeners();
  }

  void onBackspace() {
    if (_currentBoard == null ||
        _focusedRow == -1 ||
        _isLevelComplete ||
        _isReviewMode) {
      return;
    }
    final word = currentFocusedWord;
    if (word == null) return;
    var cell = _currentBoard!.grid[_focusedRow][_focusedCol];
    if (!_isCellEditableInWord(_focusedRow, _focusedCol, word) ||
        cell.userChar.isEmpty) {
      if (!_moveToEditableCell(word, forward: false)) return;
      cell = _currentBoard!.grid[_focusedRow][_focusedCol];
    }
    cell.userChar = '';
    cell.isError = false;
    _completedWordIdsInCurrentLevel.remove(word.wordId);
    saveLevelDraft();
    notifyListeners();
  }

  void _advanceCursor() {
    if (_currentBoard == null || _focusedRow == -1) return;
    final word = currentFocusedWord;
    if (word == null) return;

    final isAcross = word.isAcross;
    _isAcrossFocus =
        isAcross; // Ensure state is always in sync with active word

    final int curIdx = word.getCharIndexForCell(_focusedRow, _focusedCol);
    if (curIdx < 0) return;

    // 1. Prioritize next empty, editable cell ahead in the active word
    for (int i = curIdx + 1; i < word.word.length; i++) {
      final int r = isAcross ? word.startRow : word.startRow + i;
      final int c = isAcross ? word.startCol + i : word.startCol;
      if (_currentBoard!.grid[r][c].userChar.isEmpty &&
          _isCellEditableInWord(r, c, word)) {
        _focusedRow = r;
        _focusedCol = c;
        return;
      }
    }

    // 2. Otherwise advance to next editable cell ahead without overwriting completed crosses
    for (int i = curIdx + 1; i < word.word.length; i++) {
      final int r = isAcross ? word.startRow : word.startRow + i;
      final int c = isAcross ? word.startCol + i : word.startCol;
      if (_isCellEditableInWord(r, c, word)) {
        _focusedRow = r;
        _focusedCol = c;
        return;
      }
    }
  }

  bool _moveToEditableCell(
    PlacedWord word, {
    required bool forward,
    bool wrap = false,
  }) {
    final current = word.getCharIndexForCell(_focusedRow, _focusedCol);
    for (int step = 1; step < word.word.length; step++) {
      var index = current + (forward ? step : -step);
      if (wrap) index %= word.word.length;
      if (index < 0 || index >= word.word.length) break;
      final r = word.startRow + (word.isAcross ? 0 : index);
      final c = word.startCol + (word.isAcross ? index : 0);
      if (_isCellEditableInWord(r, c, word)) {
        _focusedRow = r;
        _focusedCol = c;
        return true;
      }
    }
    return false;
  }

  void _checkWordAndBoardCompletion() {
    if (_currentBoard == null || _isReviewMode || _isLevelComplete) return;

    // Check individual word completions for micro-celebration
    for (final word in _currentBoard!.placedWords) {
      if (!_completedWordIdsInCurrentLevel.contains(word.wordId)) {
        bool wordComplete = true;
        for (int i = 0; i < word.word.length; i++) {
          int r = word.isAcross ? word.startRow : word.startRow + i;
          int c = word.isAcross ? word.startCol + i : word.startCol;
          final cell = _currentBoard!.grid[r][c];
          if (!cell.isCorrect) {
            wordComplete = false;
            break;
          }
        }
        if (wordComplete) {
          _completedWordIdsInCurrentLevel.add(word.wordId);
          _lastCompletedWordCelebration = word;
          _wordCelebrationTick++;

          final bool isNew = !_solvedWordIds.contains(word.wordId);
          _lastCelebratedWordIsNew = isNew;
          if (isNew) {
            _solvedWordIds.add(word.wordId);
            final entry = DictionaryRepository().getWordById(word.wordId);
            if (entry != null &&
                !_newlyDiscoveredWords.any((w) => w.id == entry.id)) {
              _newlyDiscoveredWords.add(entry);
            }
            _saveStateToPrefs();
          }
          _playWordCompleteFeedback();
        }
      }
    }

    if (_currentBoard!.isComplete) {
      if (_soundEnabled) CrosswordAudio.play('board');
      _isLevelComplete = true;
      _completedLevelsCount++;
      _coins += _levelReward;

      if (_isTutorialLevel) {
        _isTutorialCompleted = true;
      }

      if (_isDailyLevel &&
          _dailyLevelDate.compareTo(_lastDailyCompletedDate) > 0) {
        _lastDailyCompletedDate = _dailyLevelDate;
        _streak++;
      }

      // Record in Completed Editions History (Hemeroteca)
      final edition = CompletedEdition(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _currentBoard!.title,
        category: _currentBoard!.category,
        wordsCount: _currentBoard!.placedWords.length,
        elapsedSeconds: _elapsedSeconds,
        completedAt: DateTime.now(),
        coinsEarned: _levelReward,
        boardData: _currentBoard!.toJson(),
      );
      _completedHistory.add(edition);

      // Ensure any remaining placed words are archived in dictionary
      final repo = DictionaryRepository();
      for (final pw in _currentBoard!.placedWords) {
        if (!_solvedWordIds.contains(pw.wordId)) {
          _solvedWordIds.add(pw.wordId);
          final entry = repo.getWordById(pw.wordId);
          if (entry != null &&
              !_newlyDiscoveredWords.any((w) => w.id == entry.id)) {
            _newlyDiscoveredWords.add(entry);
          }
        }
      }

      clearLevelDraft();
      _saveStateToPrefs();
    }
  }

  /// Reveals 1 pending letter from the focused word (or any pending cell)
  /// once per day at zero coin cost.
  bool useFreeDailyHint() {
    if (!hasFreeDailyHintToday || _currentBoard == null || _isLevelComplete) {
      return false;
    }

    CrosswordCell? targetCell;

    if (_focusedRow >= 0 && _focusedCol >= 0) {
      final focused = _currentBoard!.grid[_focusedRow][_focusedCol];
      if (!focused.isBlack && !focused.isCorrect) {
        targetCell = focused;
      }
    }

    final word = currentFocusedWord;
    if (targetCell == null && word != null) {
      for (int i = 0; i < word.word.length; i++) {
        final int r = word.isAcross ? word.startRow : word.startRow + i;
        final int c = word.isAcross ? word.startCol + i : word.startCol;
        final cell = _currentBoard!.grid[r][c];
        if (!cell.isBlack && !cell.isCorrect) {
          targetCell = cell;
          break;
        }
      }
    }

    if (targetCell == null) {
      for (int r = 0; r < _currentBoard!.rows && targetCell == null; r++) {
        for (int c = 0; c < _currentBoard!.cols; c++) {
          final cell = _currentBoard!.grid[r][c];
          if (!cell.isBlack && !cell.isCorrect) {
            targetCell = cell;
            break;
          }
        }
      }
    }

    if (targetCell == null) return false;

    targetCell.userChar = targetCell.solutionChar;
    targetCell.isRevealed = true;
    targetCell.isError = false;
    _lastFreeHintDate = todayDateString;

    _checkWordAndBoardCompletion();
    saveLevelDraft();
    _saveStateToPrefs();
    notifyListeners();
    return true;
  }

  // Hint: Reveal Letter (35 coins)
  bool revealLetter() {
    if (_currentBoard == null ||
        _focusedRow == -1 ||
        _coins < 35 ||
        _isReviewMode) {
      return false;
    }
    final cell = _currentBoard!.grid[_focusedRow][_focusedCol];
    if (cell.isBlack || cell.isCorrect) return false;

    cell.userChar = cell.solutionChar;
    cell.isRevealed = true;
    cell.isError = false;
    _coins -= 35;

    _checkWordAndBoardCompletion();
    saveLevelDraft();
    _saveStateToPrefs();
    notifyListeners();
    return true;
  }

  // Hint: Reveal Word (80 coins)
  bool revealWord() {
    final word = currentFocusedWord;
    if (_currentBoard == null || word == null || _coins < 80 || _isReviewMode) {
      return false;
    }

    for (int i = 0; i < word.word.length; i++) {
      int r = word.isAcross ? word.startRow : word.startRow + i;
      int c = word.isAcross ? word.startCol + i : word.startCol;
      final cell = _currentBoard!.grid[r][c];
      cell.userChar = cell.solutionChar;
      cell.isRevealed = true;
      cell.isError = false;
    }

    _coins -= 80;
    _checkWordAndBoardCompletion();
    saveLevelDraft();
    _saveStateToPrefs();
    notifyListeners();
    return true;
  }

  // Hint: Check for errors (25 coins)
  bool checkErrors() {
    if (_currentBoard == null || _coins < 25 || _isReviewMode) return false;

    for (int r = 0; r < _currentBoard!.rows; r++) {
      for (int c = 0; c < _currentBoard!.cols; c++) {
        final cell = _currentBoard!.grid[r][c];
        if (!cell.isBlack && cell.userChar.isNotEmpty && !cell.isCorrect) {
          cell.isError = true;
        }
      }
    }

    _coins -= 25;
    _saveStateToPrefs();
    notifyListeners();
    return true;
  }
}
