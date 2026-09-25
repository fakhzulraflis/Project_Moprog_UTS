import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/api_service.dart';

class LessonPage extends StatefulWidget {
  final int lessonId;

  const LessonPage({super.key, required this.lessonId});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  List<Question> questions = [];
  bool isLoading = true;
  String? errorMessage;

  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final result = await ApiService.getQuestions(widget.lessonId);

      setState(() {
        questions = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF272F33),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF272F33),
        appBar: AppBar(backgroundColor: const Color(0xFF272F33), elevation: 0),
        body: Center(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF272F33),
        body: Center(
          child: Text('Tidak ada soal.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '${currentQuestionIndex + 1}/${questions.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.prompt,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            if (question.type == 'multiple_choice')
              ...question.options.map((option) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      checkAnswer(option);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(option, style: const TextStyle(fontSize: 16)),
                  ),
                );
              }),

            if (question.type == 'translation')
              TranslationQuestion(
                question: question,
                onCorrect: () {
                  nextQuestion();
                },
              ),
          ],
        ),
      ),
    );
  }

  void checkAnswer(String answer) {
    final question = questions[currentQuestionIndex];

    if (answer == question.correctAnswer) {
      nextQuestion();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Jawaban salah')));
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      showLessonComplete();
    }
  }

  void showLessonComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Lesson selesai!'),
          content: const Text('Kamu telah menyelesaikan semua soal.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }
}

class TranslationQuestion extends StatefulWidget {
  final Question question;
  final VoidCallback onCorrect;

  const TranslationQuestion({
    super.key,
    required this.question,
    required this.onCorrect,
  });

  @override
  State<TranslationQuestion> createState() => _TranslationQuestionState();
}

class _TranslationQuestionState extends State<TranslationQuestion> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void checkAnswer() {
    final answer = controller.text.trim().toLowerCase();
    final correct = widget.question.correctAnswer.trim().toLowerCase();

    if (answer == correct) {
      widget.onCorrect();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Jawaban salah')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Ketik jawaban...',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: checkAnswer,
            child: const Text('CHECK'),
          ),
        ),
      ],
    );
  }
}
