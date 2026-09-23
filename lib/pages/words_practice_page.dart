import 'package:flutter/material.dart';

class WordsPracticePage extends StatefulWidget {
  const WordsPracticePage({super.key});

  @override
  State<WordsPracticePage> createState() => _WordsPracticePageState();
}

class _WordsPracticePageState extends State<WordsPracticePage> {
  int questionIndex = 0;
  int score = 0;

  String? selectedAnswer;
  bool isChecked = false;
  bool isFinished = false;

  final List<Map<String, dynamic>> questions = [
    {
      'word': 'Apple',
      'options': ['Buku', 'Apel', 'Air', 'Rumah'],
      'correct': 'Apel',
    },
    {
      'word': 'Book',
      'options': ['Makanan', 'Teman', 'Buku', 'Sekolah'],
      'correct': 'Buku',
    },
    {
      'word': 'Water',
      'options': ['Air', 'Susu', 'Kopi', 'Teh'],
      'correct': 'Air',
    },
    {
      'word': 'Hello',
      'options': ['Selamat tinggal', 'Halo', 'Maaf', 'Terima kasih'],
      'correct': 'Halo',
    },
    {
      'word': 'Goodbye',
      'options': ['Selamat pagi', 'Halo', 'Selamat tinggal', 'Malam'],
      'correct': 'Selamat tinggal',
    },
  ];

  void checkAnswer() {
    if (selectedAnswer == null) return;

    setState(() {
      isChecked = true;

      if (selectedAnswer == questions[questionIndex]['correct']) {
        score++;
      }
    });
  }

  void nextQuestion() {
    setState(() {
      if (questionIndex < questions.length - 1) {
        questionIndex++;
        selectedAnswer = null;
        isChecked = false;
      } else {
        isFinished = true;
      }
    });
  }

  void restartPractice() {
    setState(() {
      questionIndex = 0;
      score = 0;
      selectedAnswer = null;
      isChecked = false;
      isFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isFinished) {
      return Scaffold(
        backgroundColor: const Color(0xFF272F33),
        appBar: AppBar(
          backgroundColor: const Color(0xFF272F33),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFE7C249),
                size: 80,
              ),

              const SizedBox(height: 20),

              const Text(
                'Practice Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Your Score: $score / ${questions.length}',
                style: const TextStyle(
                  color: Color(0xFFE7C249),
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: restartPractice,
                child: const Text('PRACTICE AGAIN'),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[questionIndex];
    final options = question['options'] as List<String>;
    final correctAnswer = question['correct'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Words Practice',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (questionIndex + 1) / questions.length,
                backgroundColor: const Color(0xFF20272B),
                color: const Color(0xFFE7C249),
                minHeight: 10,
              ),

              const SizedBox(height: 20),

              Text(
                'Question ${questionIndex + 1} / ${questions.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'What is the meaning of "${question['word']}"?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = selectedAnswer == option;

                    return GestureDetector(
                      onTap: isChecked
                          ? null
                          : () {
                              setState(() {
                                selectedAnswer = option;
                              });
                            },

                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE7C249)
                              : const Color(0xFF20272B),
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: Text(
                          option,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (isChecked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Text(
                    selectedAnswer == correctAnswer
                        ? 'Correct! Great job!'
                        : 'Incorrect! Correct answer: $correctAnswer',
                    style: TextStyle(
                      color: selectedAnswer == correctAnswer
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedAnswer == null
                      ? null
                      : isChecked
                          ? nextQuestion
                          : checkAnswer,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE7C249),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                  ),

                  child: Text(
                    isChecked ? 'CONTINUE' : 'CHECK',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}