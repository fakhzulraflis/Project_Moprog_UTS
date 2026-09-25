class Question {
  final int id;
  final int lessonId;
  final String type;
  final String prompt;
  final String correctAnswer;
  final List<String> options;
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
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : [],
      order: json['order'],
    );
  }
}
