import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/word_entry.dart';

class DictionaryRepository {
  static final DictionaryRepository _instance = DictionaryRepository._internal();
  factory DictionaryRepository() => _instance;
  DictionaryRepository._internal();

  List<WordEntry> _allWords = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<WordEntry> get allWords => _allWords;

  Future<void> loadDictionary() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/words_500.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _allWords = jsonList.map((j) => WordEntry.fromJson(j)).toList();
      _isLoaded = true;
    } catch (e) {
      // Fallback in case asset loading has issues during dev
      _allWords = _getFallbackWords();
      _isLoaded = true;
    }
  }

  WordEntry? getWordById(int id) {
    try {
      return _allWords.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  WordEntry? getWordByString(String word) {
    try {
      return _allWords.firstWhere((w) => w.word.toUpperCase() == word.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  List<WordEntry> getWordsByCategory(String category) {
    if (category == 'Todos' || category.isEmpty) return _allWords;
    return _allWords.where((w) => w.category.toLowerCase() == category.toLowerCase()).toList();
  }

  List<WordEntry> getWordsByDifficulty(String difficulty) {
    return _allWords.where((w) => w.difficulty.toLowerCase() == difficulty.toLowerCase()).toList();
  }

  List<WordEntry> searchWords(String query, {String? categoryFilter}) {
    query = query.toLowerCase().trim();
    List<WordEntry> list = _allWords;
    if (categoryFilter != null && categoryFilter != 'Todos') {
      list = list.where((w) => w.category.toLowerCase() == categoryFilter.toLowerCase()).toList();
    }
    if (query.isEmpty) return list;

    return list.where((w) =>
      w.word.toLowerCase().contains(query) ||
      w.clue.toLowerCase().contains(query) ||
      w.category.toLowerCase().contains(query)
    ).toList();
  }

  List<String> getCategories() {
    final cats = _allWords.map((w) => w.category).toSet().toList();
    cats.sort();
    return ['Todos', ...cats];
  }

  List<WordEntry> _getFallbackWords() {
    return [
      WordEntry(id: 1, word: "ALQUIMIA", clue: "Doctrina y estudio especulativo de la transmutación de la materia", category: "Historia", difficulty: "medio", etymology: "Del árabe al-kīmiyā", example: "La alquimia fue la antecesora de la química moderna."),
      WordEntry(id: 2, word: "BIBLIOTECA", clue: "Lugar donde se conservan libros ordenados para la lectura", category: "Historia", difficulty: "avanzado", etymology: "Del griego bibliothēkē", example: "La biblioteca de Alejandría era célebre."),
      WordEntry(id: 3, word: "NEBULOSA", clue: "Nube gigante de polvo y gas en el espacio exterior", category: "Ciencia", difficulty: "medio", etymology: "Del latín nebulosus", example: "De la nebulosa nacen miles de estrellas."),
      WordEntry(id: 4, word: "METAFORA", clue: "Traslación del sentido recto de una voz a otro figurado", category: "Lenguaje", difficulty: "medio", etymology: "Del griego metaphora", example: "Utilizó una metáfora poética."),
    ];
  }
}
