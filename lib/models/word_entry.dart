class WordEntry {
  final int id;
  final String word;
  final String clue;
  final String category;
  final String difficulty;
  final String etymology;
  final String example;

  WordEntry({
    required this.id,
    required this.word,
    required this.clue,
    required this.category,
    required this.difficulty,
    required this.etymology,
    required this.example,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      id: json['id'] as int,
      word: (json['word'] as String).toUpperCase(),
      clue: json['clue'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      etymology: json['etymology'] as String? ?? '',
      example: json['example'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'clue': clue,
      'category': category,
      'difficulty': difficulty,
      'etymology': etymology,
      'example': example,
    };
  }
}
