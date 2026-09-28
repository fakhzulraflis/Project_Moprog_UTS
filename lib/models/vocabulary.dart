class Vocabulary {
  final int id;
  final String indonesian;
  final String english;
  final String japanese;
  final String korean;

  Vocabulary({
    required this.id,
    required this.indonesian,
    required this.english,
    required this.japanese,
    required this.korean,
  });

  factory Vocabulary.fromJson(Map<String, dynamic> json) {
    return Vocabulary(
      id: json['id'],
      indonesian: json['indonesian'],
      english: json['english'],
      japanese: json['japanese'],
      korean: json['korean'],
    );
  }
}
