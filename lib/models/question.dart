class ChoiceOption {
  final String text;
  final String? romanization;

  const ChoiceOption(this.text, [this.romanization]);
}

class Question {
  final int id;
  final int lessonId;
  final String type;
  final String prompt;
  final String correctAnswer;
  final dynamic options;
  final int order;
  final String? audioText;
  final String? romanization;
  final String? meaning;

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

  List<ChoiceOption> get choiceOptions {
    final raw = options;

    if (raw is! List) {
      return [];
    }

    return raw.map<ChoiceOption>((item) {
      if (item is Map) {
        return ChoiceOption(
          item['text']?.toString() ?? '',
          item['romanization']?.toString(),
        );
      }

      return ChoiceOption(item.toString());
    }).toList();
  }

  List<String> get stringOptions {
    return choiceOptions.map((option) => option.text).toList();
  }

  List<Map<String, dynamic>> get _mapOptions {
    if (options is List) {
      return List<Map<String, dynamic>>.from(
        options.map((item) => Map<String, dynamic>.from(item)),
      );
    }

    return [];
  }

  List<Map<String, dynamic>> get matchingOptions => _mapOptions;

  List<Map<String, dynamic>> get imageOptions => _mapOptions;
}
