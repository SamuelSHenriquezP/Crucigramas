import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crossword_board.dart';
import '../models/crossword_cell.dart';
import '../models/word_entry.dart';
import 'dictionary_repository.dart';
import 'crossword_generator.dart';

class GameStateProvider with ChangeNotifier {
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

  // Daily Challenge Tracking
  String _lastDailyCompletedDate = '';
  bool _isDailyLevel = false;
  int _levelReward = 100;

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
  int get levelReward => _levelReward;

  String get todayDateString {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  bool get isDailyCompletedToday => _lastDailyCompletedDate == todayDateString;

  GameStateProvider() {
    _loadStateFromPrefs();
  }

  bool _hasNoAds = false;
  Set<String> _unlockedShopItems = {'default_theme', 'font_playfair'};
  String _activeThemeId = 'default_theme';
  String _activeFontId = 'font_playfair';

  // Draft Auto-Save State
  bool _hasSavedDraft = false;
  String _draftTitle = '';
  String _draftCategory = '';
  int _draftElapsedSeconds = 0;
  List<String> _draftGridState = [];

  Set<String> get unlockedShopItems => _unlockedShopItems;
  String get activeThemeId => _activeThemeId;
  String get activeFontId => _activeFontId;
  bool get hasNoAds => _hasNoAds;
  bool get hasSavedDraft => _hasSavedDraft;
  String get draftTitle => _draftTitle.isNotEmpty ? _draftTitle : "Edición en Borrador";

  Future<void> _loadStateFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _coins = prefs.getInt('coins') ?? 150;
      _streak = prefs.getInt('streak') ?? 1;
      _completedLevelsCount = prefs.getInt('completed_levels') ?? 0;
      _activeThemeId = prefs.getString('active_theme') ?? 'default_theme';
      _activeFontId = prefs.getString('active_font') ?? 'font_playfair';
      _lastDailyCompletedDate = prefs.getString('last_daily_date') ?? '';
      _hasNoAds = prefs.getBool('has_no_ads') ?? false;

      // Draft state loading
      _hasSavedDraft = prefs.getBool('has_saved_draft') ?? false;
      _draftTitle = prefs.getString('draft_title') ?? '';
      _draftCategory = prefs.getString('draft_category') ?? '';
      _draftElapsedSeconds = prefs.getInt('draft_elapsed') ?? 0;
      _draftGridState = prefs.getStringList('draft_grid_state') ?? [];

      final unlockedList = prefs.getStringList('unlocked_shop') ?? ['default_theme', 'font_playfair'];
      _unlockedShopItems = unlockedList.toSet();
      
      final solvedList = prefs.getStringList('solved_words') ?? [];
      _solvedWordIds = solvedList.map((e) => int.parse(e)).toSet();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveStateToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('coins', _coins);
      await prefs.setInt('streak', _streak);
      await prefs.setInt('completed_levels', _completedLevelsCount);
      await prefs.setString('active_theme', _activeThemeId);
      await prefs.setString('active_font', _activeFontId);
      await prefs.setString('last_daily_date', _lastDailyCompletedDate);
      await prefs.setBool('has_no_ads', _hasNoAds);

      // Draft state saving
      await prefs.setBool('has_saved_draft', _hasSavedDraft);
      await prefs.setString('draft_title', _draftTitle);
      await prefs.setString('draft_category', _draftCategory);
      await prefs.setInt('draft_elapsed', _draftElapsedSeconds);
      await prefs.setStringList('draft_grid_state', _draftGridState);

      await prefs.setStringList('unlocked_shop', _unlockedShopItems.toList());
      await prefs.setStringList(
        'solved_words',
        _solvedWordIds.map((e) => e.toString()).toList(),
      );
    } catch (_) {}
  }

  void saveLevelDraft() {
    if (_currentBoard == null || _isLevelComplete) return;
    _hasSavedDraft = true;
    _draftTitle = _currentBoard!.title;
    _draftCategory = _currentBoard!.category;
    _draftElapsedSeconds = _elapsedSeconds;
    
    _draftGridState = [];
    for (int r = 0; r < _currentBoard!.rows; r++) {
      for (int c = 0; c < _currentBoard!.cols; c++) {
        final cell = _currentBoard!.grid[r][c];
        if (!cell.isBlack && cell.userChar.isNotEmpty) {
          _draftGridState.add("$r,$c:${cell.userChar}:${cell.isRevealed ? '1' : '0'}");
        }
      }
    }
    _saveStateToPrefs();
    notifyListeners();
  }

  Future<void> resumeSavedDraft() async {
    if (!_hasSavedDraft) return;
    await startNewLevel(
      title: _draftTitle.isNotEmpty ? _draftTitle : "Borrador de Edición",
      category: _draftCategory.isNotEmpty ? _draftCategory : "Todos",
    );
    
    if (_currentBoard != null) {
      for (final entry in _draftGridState) {
        final parts = entry.split(':');
        if (parts.length >= 3) {
          final coords = parts[0].split(',');
          int r = int.parse(coords[0]);
          int c = int.parse(coords[1]);
          String char = parts[1];
          bool isRev = parts[2] == '1';

          if (r < _currentBoard!.rows && c < _currentBoard!.cols) {
            final cell = _currentBoard!.grid[r][c];
            if (!cell.isBlack) {
              cell.userChar = char;
              cell.isRevealed = isRev;
            }
          }
        }
      }
      _elapsedSeconds = _draftElapsedSeconds;
    }
    notifyListeners();
  }

  void clearLevelDraft() {
    _hasSavedDraft = false;
    _draftTitle = '';
    _draftCategory = '';
    _draftElapsedSeconds = 0;
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

  Future<void> startDailyChallenge() async {
    _isDailyLevel = true;
    _levelReward = 200;
    final dateStr = todayDateString;
    await startNewLevel(
      title: "Crucigrama del Día ($dateStr)",
      category: "Todos",
      targetWordsCount: 10,
      reward: 200,
    );
  }

  Future<void> startNewLevel({
    required String title,
    required String category,
    int targetWordsCount = 8,
    String? difficultyFilter,
    int reward = 100,
  }) async {
    _isLoading = true;
    _isLevelComplete = false;
    _newlyDiscoveredWords = [];
    _elapsedSeconds = 0;
    _levelReward = reward;
    if (!_isDailyLevel) {
      _isDailyLevel = false;
    }
    notifyListeners();

    _currentBoard = await CrosswordGenerator.generateBoard(
      title: title,
      category: category,
      targetWordsCount: targetWordsCount,
      difficultyFilter: difficultyFilter,
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
          _isAcrossFocus = true;
          return;
        }
      }
    }
  }

  void selectCell(int r, int c) {
    if (_currentBoard == null) return;
    final cell = _currentBoard!.grid[r][c];
    if (cell.isBlack) return;

    if (_focusedRow == r && _focusedCol == c) {
      // Toggle direction if tapping the same cell again
      _isAcrossFocus = !_isAcrossFocus;
    } else {
      _focusedRow = r;
      _focusedCol = c;
    }
    notifyListeners();
  }

  PlacedWord? get currentFocusedWord {
    if (_currentBoard == null || _focusedRow == -1) return null;
    return _currentBoard!.getWordForCell(_focusedRow, _focusedCol, _isAcrossFocus);
  }

  void selectNextWord() {
    if (_currentBoard == null) return;
    final words = _isAcrossFocus ? _currentBoard!.acrossWords : _currentBoard!.downWords;
    if (words.isEmpty) return;

    int curIdx = words.indexWhere((w) => w == currentFocusedWord);
    int nextIdx = (curIdx + 1) % words.length;
    final nextW = words[nextIdx];
    _focusedRow = nextW.startRow;
    _focusedCol = nextW.startCol;
    notifyListeners();
  }

  void selectPreviousWord() {
    if (_currentBoard == null) return;
    final words = _isAcrossFocus ? _currentBoard!.acrossWords : _currentBoard!.downWords;
    if (words.isEmpty) return;

    int curIdx = words.indexWhere((w) => w == currentFocusedWord);
    int prevIdx = (curIdx - 1 + words.length) % words.length;
    final prevW = words[prevIdx];
    _focusedRow = prevW.startRow;
    _focusedCol = prevW.startCol;
    notifyListeners();
  }

  void onKeyInput(String letter) {
    if (_currentBoard == null || _focusedRow == -1 || _isLevelComplete) return;

    final cell = _currentBoard!.grid[_focusedRow][_focusedCol];
    if (cell.isBlack) return;

    cell.userChar = letter.toUpperCase();
    cell.isError = false; // Reset error state on edit

    _checkWordAndBoardCompletion();
    _advanceCursor();
    saveLevelDraft();
    notifyListeners();
  }

  void onBackspace() {
    if (_currentBoard == null || _focusedRow == -1 || _isLevelComplete) return;

    final cell = _currentBoard!.grid[_focusedRow][_focusedCol];
    if (cell.userChar.isNotEmpty) {
      cell.userChar = '';
      cell.isError = false;
      _moveCursorBack();
    } else {
      _moveCursorBack();
      final prevCell = _currentBoard!.grid[_focusedRow][_focusedCol];
      prevCell.userChar = '';
      prevCell.isError = false;
    }
    saveLevelDraft();
    notifyListeners();
  }

  void _advanceCursor() {
    if (_currentBoard == null || _focusedRow == -1) return;
    final word = currentFocusedWord;
    if (word == null) return;

    if (_isAcrossFocus) {
      int nextC = _focusedCol + 1;
      if (nextC <= word.endCol && !_currentBoard!.grid[_focusedRow][nextC].isBlack) {
        _focusedCol = nextC;
      } else {
        // Automatically advance to the next word in the list
        selectNextWord();
      }
    } else {
      int nextR = _focusedRow + 1;
      if (nextR <= word.endRow && !_currentBoard!.grid[nextR][_focusedCol].isBlack) {
        _focusedRow = nextR;
      } else {
        // Automatically advance to the next word in the list
        selectNextWord();
      }
    }
  }

  void _moveCursorBack() {
    if (_currentBoard == null || _focusedRow == -1) return;
    final word = currentFocusedWord;
    if (word == null) return;

    if (_isAcrossFocus) {
      int prevC = _focusedCol - 1;
      if (prevC >= word.startCol && !_currentBoard!.grid[_focusedRow][prevC].isBlack) {
        _focusedCol = prevC;
      }
    } else {
      int prevR = _focusedRow - 1;
      if (prevR >= word.startRow && !_currentBoard!.grid[prevR][_focusedCol].isBlack) {
        _focusedRow = prevR;
      }
    }
  }

  void _checkWordAndBoardCompletion() {
    if (_currentBoard == null) return;

    if (_currentBoard!.isComplete) {
      _isLevelComplete = true;
      _completedLevelsCount++;
      _coins += _levelReward;

      if (_isDailyLevel && !isDailyCompletedToday) {
        _lastDailyCompletedDate = todayDateString;
        _streak++;
      }

      // Collect newly discovered words for the dictionary
      final repo = DictionaryRepository();
      _newlyDiscoveredWords = [];

      for (final pw in _currentBoard!.placedWords) {
        if (!_solvedWordIds.contains(pw.wordId)) {
          _solvedWordIds.add(pw.wordId);
          final entry = repo.getWordById(pw.wordId);
          if (entry != null) {
            _newlyDiscoveredWords.add(entry);
          }
        }
      }

      clearLevelDraft();
      _saveStateToPrefs();
    }
  }

  // Hint: Reveal Letter (35 coins)
  bool revealLetter() {
    if (_currentBoard == null || _focusedRow == -1 || _coins < 35) return false;
    final cell = _currentBoard!.grid[_focusedRow][_focusedCol];
    if (cell.isBlack || cell.isCorrect) return false;

    cell.userChar = cell.solutionChar;
    cell.isRevealed = true;
    cell.isError = false;
    _coins -= 35;

    _checkWordAndBoardCompletion();
    _saveStateToPrefs();
    notifyListeners();
    return true;
  }

  // Hint: Reveal Word (80 coins)
  bool revealWord() {
    final word = currentFocusedWord;
    if (_currentBoard == null || word == null || _coins < 80) return false;

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
    _saveStateToPrefs();
    notifyListeners();
    return true;
  }

  // Hint: Check for errors (25 coins)
  bool checkErrors() {
    if (_currentBoard == null || _coins < 25) return false;

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
