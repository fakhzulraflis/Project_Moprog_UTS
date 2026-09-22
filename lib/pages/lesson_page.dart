import 'package:flutter/material.dart';

import '../data/section_1_data.dart';
import '../models/question.dart';
import '../services/translation_service.dart';

class LessonPage extends StatefulWidget {
  final String selectedLanguage;
  final String circleTitle;

  const LessonPage({
    super.key,
    required this.selectedLanguage,
    required this.circleTitle,
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  List<Question> questions = [];

  int currentQuestion = 0;
  int score = 0;

  bool isLoading = true;
  bool answered = false;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  String getLanguageCode() {
    switch (widget.selectedLanguage) {
      case 'English':
        return 'en';

      case 'Japanese':
        return 'ja';

      case 'Korean':
        return 'ko';

      default:
        return 'en';
    }
  }

  Future<void> loadQuestions() async {
    try {
      List<Question> loadedQuestions = [];

      final languageCode = getLanguageCode();

      for (int i = 0; i < section1Unit1Circle1.length; i++) {
        final vocabulary = section1Unit1Circle1[i];

        final translation = await TranslationService.translate(
          text: vocabulary.indonesian,
          targetLanguage: languageCode,
        );

        List<String> options = [];

        for (int j = 0; j < section1Unit1Circle1.length; j++) {
          if (i == j) {
            continue;
          }

          final wrongTranslation = await TranslationService.translate(
            text: section1Unit1Circle1[j].indonesian,
            targetLanguage: languageCode,
          );

          options.add(wrongTranslation);

          if (options.length == 3) {
            break;
          }
        }

        options.add(translation);
        options.shuffle();

        loadedQuestions.add(
          Question(
            question:
                'Apa bahasa ${widget.selectedLanguage} dari "${vocabulary.indonesian}"?',
            options: options,
            correctAnswer: translation,
          ),
        );
      }

      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data terjemahan.')),
      );
    }
  }

  void selectAnswer(String answer) {
    if (answered) {
      return;
    }

    setState(() {
      selectedAnswer = answer;
      answered = true;

      if (answer == questions[currentQuestion].correctAnswer) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        answered = false;
        selectedAnswer = null;
      });
    } else {
      showResult();
    }
  }

  void showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF20272B),
          title: const Text(
            'Lesson Complete!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Score kamu: $score/${questions.length}',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'CONTINUE',
                style: TextStyle(
                  color: Color(0xFFE7C249),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF272F33),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE7C249)),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF272F33),
        body: const Center(
          child: Text('Tidak ada soal.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final question = questions[currentQuestion];

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
          widget.circleTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestion + 1) / questions.length,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE7C249),
              ),
            ),

            const SizedBox(height: 30),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Question ${currentQuestion + 1}/${questions.length}',
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                question.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];

                  final isSelected = selectedAnswer == option;

                  final isCorrect = option == question.correctAnswer;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () {
                        selectAnswer(option);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE7C249)
                              : const Color(0xFF20272B),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: answered && isCorrect
                                ? Colors.green
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            if (answered)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: selectedAnswer == question.correctAnswer
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  selectedAnswer == question.correctAnswer
                      ? '✓ Correct!'
                      : '✕ Incorrect\n'
                            'Jawaban yang benar: '
                            '${question.correctAnswer}',
                  style: TextStyle(
                    color: selectedAnswer == question.correctAnswer
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: answered ? nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE7C249),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  currentQuestion == questions.length - 1
                      ? 'FINISH'
                      : 'CONTINUE',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
