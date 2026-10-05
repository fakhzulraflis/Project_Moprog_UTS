class Question {
  final int id;
  final int lessonId;
  final String type;
  final String prompt;
  final String correctAnswer;
  final dynamic options;
  final int order;

  // Opsional: boleh null kalau backend belum mengirim
  final String? audioText; // teks yang dibacakan (bahasa target)
  final String? romanization; // romaji / cara baca, tampil di atas prompt
  final String? meaning; // arti, tampil di panel "Benar! Artinya: ..."

  Question({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    required this.order,
    this.audioText,
    this.romanization,
    this.meaning,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      lessonId: json['lesson_id'],
      type: json['type'],
      prompt: json['prompt'],
      correctAnswer: json['correct_answer'],
      options: json['options'],
      order: json['order'],
      audioText: json['audio_text']?.toString(),
      romanization: json['romanization']?.toString(),
      meaning: json['meaning']?.toString(),
    );
  }

  List<String> get stringOptions {
    if (options is List) {
      return List<String>.from(options);
    }

    return [];
  }

  List<Map<String, dynamic>> get _mapOptions {
    if (options is List) {
      return List<Map<String, dynamic>>.from(
        options.map((item) => Map<String, dynamic>.from(item)),
      );
    }

    return [];
  }

  // matching: [{"left": "...", "right": "..."}]
  List<Map<String, dynamic>> get matchingOptions => _mapOptions;

  // image_choice: [{"label": "sushi", "image": "https://... atau assets/..."}]
  List<Map<String, dynamic>> get imageOptions => _mapOptions;
}
