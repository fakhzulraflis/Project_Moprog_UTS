import 'dart:async';

import 'package:flutter/material.dart';

import '../models/vocabulary.dart';
import '../services/api_service.dart';
import '../services/mistake_service.dart';

class WordChasePage extends StatefulWidget {
  final String selectedLanguage;

  const WordChasePage({super.key, required this.selectedLanguage});

  @override
  State<WordChasePage> createState() => _WordChasePageState();
}

class _WordChasePageState extends State<WordChasePage> {
  static const int gameDuration = 60;

  List<Vocabulary> vocabularies = [];
  List<String> answerOptions = [];

  Vocabulary? currentVocabulary;

  Timer? gameTimer;

  String? selectedAnswer;
  String? errorMessage;

  bool isLoading = true;
  bool isAnswerChecked = false;
  bool? isAnswerCorrect;
  bool isFinished = false;

  int questionIndex = 0;
  int remainingSeconds = gameDuration;

  int score = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;

  int combo = 0;
  int bestCombo = 0;

  @override
  void initState() {
    super.initState();

    loadVocabularies();
  }

  @override
  void dispose() {
    gameTimer?.cancel();

    super.dispose();
  }

  String getTranslation(Vocabulary vocabulary) {
    switch (widget.selectedLanguage) {
      case 'Japanese':
        return vocabulary.japanese;

      case 'Korean':
        return vocabulary.korean;

      case 'English':
      default:
        return vocabulary.english;
    }
  }

  String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;

    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  double get accuracy {
    final totalAnswers = correctAnswers + wrongAnswers;

    if (totalAnswers == 0) {
      return 0;
    }

    return correctAnswers / totalAnswers * 100;
  }

  Future<void> loadVocabularies() async {
    gameTimer?.cancel();

    setState(() {
      isLoading = true;
      errorMessage = null;

      questionIndex = 0;
      remainingSeconds = gameDuration;

      score = 0;
      correctAnswers = 0;
      wrongAnswers = 0;

      combo = 0;
      bestCombo = 0;

      isFinished = false;

      selectedAnswer = null;
      isAnswerChecked = false;
      isAnswerCorrect = null;
    });

    try {
      final result = await ApiService.getVocabularies();

      if (!mounted) return;

      final shuffled = List<Vocabulary>.from(result)..shuffle();

      setState(() {
        vocabularies = shuffled;

        generateQuestion();

        isLoading = false;
      });

      startTimer();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Gagal mengambil kosakata dari server.';
        isLoading = false;
      });
    }
  }

  void startTimer() {
    gameTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          remainingSeconds = 0;
          isFinished = true;

          selectedAnswer = null;
          isAnswerChecked = false;
        });
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void generateQuestion() {
    if (vocabularies.isEmpty) {
      return;
    }

    if (questionIndex >= vocabularies.length) {
      vocabularies.shuffle();

      questionIndex = 0;
    }

    currentVocabulary = vocabularies[questionIndex];

    final correctAnswer = getTranslation(currentVocabulary!);

    final distractors =
        vocabularies
            .where((vocabulary) => vocabulary.id != currentVocabulary!.id)
            .toList()
          ..shuffle();

    final options = <String>[correctAnswer];

    for (final vocabulary in distractors) {
      final translation = getTranslation(vocabulary);

      if (!options.contains(translation)) {
        options.add(translation);
      }

      if (options.length == 4) {
        break;
      }
    }

    options.shuffle();

    answerOptions = options;

    selectedAnswer = null;
    isAnswerChecked = false;
    isAnswerCorrect = null;
  }

  void selectAnswer(String answer) {
    if (isAnswerChecked || isFinished) {
      return;
    }

    setState(() {
      selectedAnswer = answer;
    });
  }

  Future<void> checkAnswer() async {
    if (selectedAnswer == null ||
        currentVocabulary == null ||
        isAnswerChecked ||
        isFinished) {
      return;
    }

    final vocabulary = currentVocabulary!;

    final correctAnswer = getTranslation(vocabulary);

    final correct = selectedAnswer == correctAnswer;

    setState(() {
      isAnswerChecked = true;
      isAnswerCorrect = correct;

      if (correct) {
        correctAnswers++;

        score += 10;

        combo++;

        if (combo > bestCombo) {
          bestCombo = combo;
        }
      } else {
        wrongAnswers++;

        combo = 0;
      }
    });

    if (!correct) {
      await MistakeService.addMistake(vocabulary.id);
    }
  }

  void nextQuestion() {
    if (isFinished) {
      return;
    }

    setState(() {
      questionIndex++;

      generateQuestion();
    });
  }

  Color getOptionColor(String option) {
    if (!isAnswerChecked) {
      if (selectedAnswer == option) {
        return const Color(0xFFE7C249);
      }

      return const Color(0xFF20272B);
    }

    final correctAnswer = getTranslation(currentVocabulary!);

    if (option == correctAnswer) {
      return const Color(0xFF356859);
    }

    if (option == selectedAnswer && option != correctAnswer) {
      return const Color(0xFF8B3A3A);
    }

    return const Color(0xFF20272B);
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFE7C249)),
    );
  }

  Widget buildOption(String option) {
    return GestureDetector(
      onTap: () => selectAnswer(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: getOptionColor(option),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selectedAnswer == option
                ? const Color(0xFFE7C249)
                : const Color.fromARGB(50, 255, 255, 255),
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: !isAnswerChecked && selectedAnswer == option
                ? const Color(0xFF272F33)
                : Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildGame() {
    if (currentVocabulary == null) {
      return const Center(
        child: Text(
          'Kosakata tidak tersedia.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Waktu ${formatTime(remainingSeconds)}',
                style: const TextStyle(
                  color: Color(0xFFE7C249),
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                'Skor $score',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(
                'Combo x$combo',
                style: const TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 45),

          const Center(
            child: Text(
              'Apa terjemahan dari:',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              currentVocabulary!.indonesian,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 35),

          ...answerOptions.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: buildOption(option),
            ),
          ),

          const SizedBox(height: 20),

          if (isAnswerChecked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAnswerCorrect == true
                    ? const Color(0xFF356859)
                    : const Color(0xFF8B3A3A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                isAnswerCorrect == true
                    ? 'Benar! +10 poin'
                    : 'Belum tepat. Jawaban yang benar adalah ${getTranslation(currentVocabulary!)}.',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isAnswerChecked
                  ? nextQuestion
                  : selectedAnswer != null
                  ? () {
                      checkAnswer();
                    }
                  : null,
              child: Text(
                isAnswerChecked ? 'SOAL BERIKUTNYA' : 'PERIKSA JAWABAN',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResult() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFE7C249),
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              'Waktu Habis!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Skor: $score',
              style: const TextStyle(
                color: Color(0xFFE7C249),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'Benar: $correctAnswers',
              style: const TextStyle(color: Colors.white),
            ),

            Text(
              'Salah: $wrongAnswers',
              style: const TextStyle(color: Colors.white),
            ),

            Text(
              'Akurasi: ${accuracy.toStringAsFixed(0)}%',
              style: const TextStyle(color: Colors.white),
            ),

            Text(
              'Combo Terbaik: x$bestCombo',
              style: const TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loadVocabularies,
                child: const Text('MAIN LAGI'),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('KEMBALI KE LATIHAN'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor: const Color(0xFF272F33),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Kejar Kata',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? buildLoading()
            : errorMessage != null
            ? Center(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : isFinished
            ? buildResult()
            : buildGame(),
      ),
    );
  }
}
