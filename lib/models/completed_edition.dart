class CompletedEdition {
  final String id;
  final String title;
  final String category;
  final int wordsCount;
  final int elapsedSeconds;
  final DateTime completedAt;
  final int coinsEarned;
  final Map<String, dynamic>? boardData;

  CompletedEdition({
    required this.id,
    required this.title,
    required this.category,
    required this.wordsCount,
    required this.elapsedSeconds,
    required this.completedAt,
    required this.coinsEarned,
    this.boardData,
  });

  String get formattedDuration {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  String get formattedDate {
    final day = completedAt.day.toString().padLeft(2, '0');
    final month = completedAt.month.toString().padLeft(2, '0');
    final year = completedAt.year;
    final hour = completedAt.hour.toString().padLeft(2, '0');
    final minute = completedAt.minute.toString().padLeft(2, '0');
    return "$day/$month/$year $hour:$minute";
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'wordsCount': wordsCount,
    'elapsedSeconds': elapsedSeconds,
    'completedAt': completedAt.toIso8601String(),
    'coinsEarned': coinsEarned,
    if (boardData != null) 'boardData': boardData,
  };

  factory CompletedEdition.fromJson(Map<String, dynamic> json) => CompletedEdition(
    id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: json['title'] as String? ?? 'Edición Resuelta',
    category: json['category'] as String? ?? 'General',
    wordsCount: json['wordsCount'] as int? ?? 0,
    elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
    completedAt: json['completedAt'] != null
        ? DateTime.tryParse(json['completedAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    coinsEarned: json['coinsEarned'] as int? ?? 0,
    boardData: json['boardData'] as Map<String, dynamic>?,
  );
}
