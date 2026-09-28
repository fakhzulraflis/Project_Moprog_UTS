class Question {
  final int id;
  final int lessonId;
  final String type;
  final String prompt;
  final String correctAnswer;
  final dynamic options;
  final int order;

  Question({
    required this.id,
    required this.lessonId,
    required this.type,
    required this.prompt,
    required this.correctAnswer,
    required this.options,
    required this.order,
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
    );
  }

  List<String> get stringOptions {
    if (options is List) {
      return List<String>.from(options);
    }

    return [];
  }

  List<Map<String, dynamic>> get matchingOptions {
    if (options is List) {
      return List<Map<String, dynamic>>.from(
        options.map((item) => Map<String, dynamic>.from(item)),
      );
    }

    return [];
  }
}
