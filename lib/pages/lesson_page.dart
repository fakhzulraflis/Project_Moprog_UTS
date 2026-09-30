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
  static const Color backgroundColor = Color(0xFF272F33);
  static const Color yellowColor = Color(0xFFFCCF10);
  static const Color redColor = Color(0xFFFF4B4B);

  List<Question> questions = [];

  bool isLoading = true;
  String? errorMessage;

  int currentQuestionIndex = 0;
  int hearts = 5;

  // Answer states
  String? selectedAnswer;
  String typedAnswer = '';

  List<String> selectedWords = [];
  List<int> selectedWordIndexes = [];

  String? selectedLeft;
  final Map<String, String> matchedPairs = {};

  bool hasChecked = false;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      final result = await ApiService.getQuestions(widget.lessonId);

      if (!mounted) return;

      setState(() {
        questions = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Question get currentQuestion {
    return questions[currentQuestionIndex];
  }

  double get progress {
    if (questions.isEmpty) {
      return 0;
    }

    return (currentQuestionIndex + 1) / questions.length;
  }

  void resetQuestionState() {
    selectedAnswer = null;
    typedAnswer = '';

    selectedWords = [];
    selectedWordIndexes = [];

    selectedLeft = null;
    matchedPairs.clear();

    hasChecked = false;
    isCorrect = false;
  }

  String normalizeAnswer(String answer) {
    return answer
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[.!?,]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  void checkAnswer() {
    if (hasChecked) return;

    final question = currentQuestion;

    String answer = '';

    if (question.type == 'multiple_choice') {
      answer = selectedAnswer ?? '';
    }

    if (question.type == 'translation' || question.type == 'fill_blank') {
      answer = typedAnswer.trim();
    }

    if (question.type == 'word_bank') {
      answer = selectedWords.join(' ');
    }

    if (question.type == 'matching') {
      checkMatching();
      return;
    }

    if (answer.isEmpty) {
      return;
    }

    final correctAnswer = normalizeAnswer(question.correctAnswer);

    final userAnswer = normalizeAnswer(answer);

    final correct = userAnswer == correctAnswer;

    setState(() {
      hasChecked = true;
      isCorrect = correct;

      if (!correct && hearts > 0) {
        hearts--;
      }
    });

    // Kalau jawaban salah dan heart sudah habis
    if (!correct && hearts == 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          showOutOfHeartsDialog();
        }
      });
    }
  }

  void checkMatching() {
    final pairs = currentQuestion.matchingOptions;

    final correct = matchedPairs.length == pairs.length;

    setState(() {
      hasChecked = true;
      isCorrect = correct;

      if (!correct && hearts > 0) {
        hearts--;
      }
    });

    // Kalau matching salah dan heart sudah habis
    if (!correct && hearts == 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          showOutOfHeartsDialog();
        }
      });
    }
  }

  void continueQuestion() {
    if (hearts == 0) {
      return;
    }

    if (!isCorrect) {
      resetQuestionState();

      setState(() {});

      return;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        resetQuestionState();
      });
    } else {
      showLessonComplete();
    }
  }

  void showLessonComplete() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LessonCompleteScreen(
          totalQuestions: questions.length,
          onContinue: () {
            Navigator.pop(context);
            Navigator.pop(context, true);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(scale: curvedAnimation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: yellowColor)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(backgroundColor: backgroundColor, elevation: 0),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text('Tidak ada soal.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            buildTopBar(),
            buildProgressBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 140),
                child: buildQuestion(),
              ),
            ),

            if (hasChecked) buildFeedbackPanel() else buildCheckButton(),
          ],
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            icon: const Icon(Icons.close, color: Colors.white70, size: 28),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              'Lesson ${widget.lessonId}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.redAccent, size: 22),
              const SizedBox(width: 5),
              Text(
                '$hearts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: Colors.white12,
                color: yellowColor,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '${currentQuestionIndex + 1}/${questions.length}',
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuestion() {
    final question = currentQuestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getQuestionInstruction(question.type),
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          question.prompt,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
        ),

        const SizedBox(height: 30),

        if (question.type == 'multiple_choice') buildMultipleChoice(question),

        if (question.type == 'translation') buildTranslation(),

        if (question.type == 'word_bank') buildWordBank(question),

        if (question.type == 'fill_blank') buildFillBlank(),

        if (question.type == 'matching') buildMatching(question),
      ],
    );
  }

  String getQuestionInstruction(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Pilih jawaban yang benar';

      case 'translation':
        return 'Terjemahkan kalimat ini';

      case 'word_bank':
        return 'Susun kata-kata menjadi kalimat';

      case 'fill_blank':
        return 'Lengkapi kalimat berikut';

      case 'matching':
        return 'Cocokkan pasangan yang benar';

      default:
        return 'Jawab pertanyaan berikut';
    }
  }

  Widget buildMultipleChoice(Question question) {
    return Column(
      children: question.stringOptions.map((option) {
        final isSelected = selectedAnswer == option;

        Color background = Colors.transparent;

        Color border = Colors.white24;

        if (isSelected) {
          background = Colors.white.withValues(alpha: 0.10);
          border = Colors.white;
        }

        if (hasChecked && option == question.correctAnswer) {
          background = yellowColor.withValues(alpha: 0.18);
          border = yellowColor;
        }

        if (hasChecked && isSelected && !isCorrect) {
          background = redColor.withValues(alpha: 0.18);
          border = redColor;
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton(
            onPressed: hasChecked
                ? null
                : () {
                    setState(() {
                      selectedAnswer = option;
                    });
                  },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              alignment: Alignment.centerLeft,
              side: BorderSide(color: border, width: 2),
              backgroundColor: background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              option,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildTranslation() {
    return TextField(
      enabled: !hasChecked,
      onChanged: (value) {
        setState(() {
          typedAnswer = value;
        });
      },
      style: const TextStyle(color: Colors.white, fontSize: 18),
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Ketik terjemahan...',
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: yellowColor, width: 2),
        ),
      ),
    );
  }

  Widget buildFillBlank() {
    return TextField(
      enabled: !hasChecked,
      onChanged: (value) {
        setState(() {
          typedAnswer = value;
        });
      },
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        hintText: 'Ketik kata yang hilang...',
        hintStyle: const TextStyle(
          color: Colors.white38,
          fontWeight: FontWeight.normal,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: yellowColor, width: 2),
        ),
      ),
    );
  }

  Widget buildWordBank(Question question) {
    final words = question.stringOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 100),
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white24)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedWords.map((word) {
              return buildWordChip(word, selected: true, onTap: null);
            }).toList(),
          ),
        ),

        const SizedBox(height: 28),

        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: List.generate(words.length, (index) {
            final isUsed = selectedWordIndexes.contains(index);

            if (isUsed) {
              return const SizedBox(width: 70, height: 46);
            }

            return buildWordChip(
              words[index],
              selected: false,
              onTap: hasChecked
                  ? null
                  : () {
                      setState(() {
                        selectedWords.add(words[index]);

                        selectedWordIndexes.add(index);
                      });
                    },
            );
          }),
        ),

        if (selectedWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: TextButton(
              onPressed: hasChecked
                  ? null
                  : () {
                      setState(() {
                        selectedWords.clear();

                        selectedWordIndexes.clear();
                      });
                    },
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildWordChip(
    String word, {
    required bool selected,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white12 : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
          boxShadow: selected
              ? []
              : [const BoxShadow(color: Colors.black26, offset: Offset(0, 3))],
        ),
        child: Text(
          word,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildMatching(Question question) {
    final pairs = question.matchingOptions;

    final leftItems = pairs.map((pair) => pair['left'].toString()).toList();

    final rightItems = pairs.map((pair) => pair['right'].toString()).toList();

    return Column(
      children: [
        const Text(
          'Pilih kata di kiri, lalu pasangannya di kanan.',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),

        const SizedBox(height: 20),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: leftItems.map((left) {
                  final matched = matchedPairs.containsKey(left);

                  return buildMatchingButton(
                    text: left,
                    selected: selectedLeft == left,
                    matched: matched,
                    onTap: hasChecked || matched
                        ? null
                        : () {
                            setState(() {
                              selectedLeft = left;
                            });
                          },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                children: rightItems.map((right) {
                  final alreadyMatched = matchedPairs.values.contains(right);

                  return buildMatchingButton(
                    text: right,
                    selected: false,
                    matched: alreadyMatched,
                    onTap: hasChecked || alreadyMatched || selectedLeft == null
                        ? null
                        : () {
                            setState(() {
                              matchedPairs[selectedLeft!] = right;

                              selectedLeft = null;
                            });
                          },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildMatchingButton({
    required String text,
    required bool selected,
    required bool matched,
    required VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
          side: BorderSide(
            color: matched
                ? yellowColor
                : selected
                ? Colors.white
                : Colors.white24,
            width: 2,
          ),
          backgroundColor: matched
              ? yellowColor.withValues(alpha: 0.15)
              : selected
              ? Colors.white10
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildCheckButton() {
    bool canCheck = false;

    if (currentQuestion.type == 'multiple_choice') {
      canCheck = selectedAnswer != null;
    }

    if (currentQuestion.type == 'translation' ||
        currentQuestion.type == 'fill_blank') {
      canCheck = typedAnswer.trim().isNotEmpty;
    }

    if (currentQuestion.type == 'word_bank') {
      canCheck = selectedWords.isNotEmpty;
    }

    if (currentQuestion.type == 'matching') {
      canCheck = matchedPairs.length == currentQuestion.matchingOptions.length;
    }

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
        decoration: const BoxDecoration(
          color: backgroundColor,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canCheck ? checkAnswer : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: yellowColor,
              disabledBackgroundColor: Colors.white12,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white30,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'CHECK',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFeedbackPanel() {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
        decoration: BoxDecoration(
          color: isCorrect ? const Color(0xFF4A3D08) : const Color(0xFF461616),
          border: Border(
            top: BorderSide(
              color: isCorrect ? yellowColor : redColor,
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.cancel,
              color: isCorrect ? yellowColor : redColor,
              size: 34,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCorrect
                        ? 'Benar!'
                        : hearts == 0
                        ? 'Hearts habis'
                        : 'Jawaban belum tepat',
                    style: TextStyle(
                      color: isCorrect ? yellowColor : redColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  if (!isCorrect)
                    Text(
                      'Jawaban: ${currentQuestion.correctAnswer}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: continueQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect ? yellowColor : redColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isCorrect
                      ? 'CONTINUE'
                      : hearts == 0
                      ? 'SELESAI'
                      : 'TRY AGAIN',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showOutOfHeartsDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return OutOfHeartsScreen(
          onRetry: () {
            Navigator.pop(context);

            setState(() {
              hearts = 5;
              currentQuestionIndex = 0;
              resetQuestionState();
            });
          },
          onExit: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return ScaleTransition(scale: curvedAnimation, child: child);
      },
    );
  }
}

class OutOfHeartsScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onExit;

  const OutOfHeartsScreen({
    super.key,
    required this.onRetry,
    required this.onExit,
  });

  static const Color backgroundColor = Color(0xFF272F33);

  static const Color redColor = Color(0xFFFF4B4B);

  static const Color yellowColor = Color(0xFFFCCF10);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          color: backgroundColor,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildHeartIcon(),

                        const SizedBox(height: 30),

                        const Text(
                          'Oh no!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Hearts kamu habis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Kamu perlu mencoba lagi '
                          'untuk menyelesaikan lesson ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 30),

                        buildHeartCounter(),
                      ],
                    ),
                  ),
                ),
              ),

              buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeartIcon() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: redColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: redColor.withValues(alpha: 0.35), width: 2),
      ),
      child: const Center(
        child: Icon(Icons.heart_broken_rounded, color: redColor, size: 65),
      ),
    );
  }

  Widget buildHeartCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite, color: redColor, size: 27),

          SizedBox(width: 10),

          Text(
            '0 / 5',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: yellowColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'COBA LAGI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextButton(
              onPressed: onExit,
              child: const Text(
                'KELUAR',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LessonCompleteScreen extends StatelessWidget {
  final int totalQuestions;
  final VoidCallback onContinue;

  const LessonCompleteScreen({
    super.key,
    required this.totalQuestions,
    required this.onContinue,
  });

  static const Color backgroundColor = Color(0xFF272F33);

  static const Color yellowColor = Color(0xFFFCCF10);

  static const Color goldColor = Color(0xFFFFC800);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          color: backgroundColor,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildTrophy(),

                        const SizedBox(height: 28),

                        const Text(
                          'Lesson selesai!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Luar biasa! Kamu berhasil '
                          'menyelesaikan lesson ini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 32),

                        buildStats(),
                      ],
                    ),
                  ),
                ),
              ),

              buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTrophy() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: goldColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: goldColor.withValues(alpha: 0.4), width: 2),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.emoji_events_rounded, color: goldColor, size: 70),
      ),
    );
  }

  Widget buildStats() {
    return Row(
      children: [
        Expanded(
          child: buildStatCard(
            icon: Icons.bolt_rounded,
            iconColor: goldColor,
            title: '+10',
            subtitle: 'XP',
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: buildStatCard(
            icon: Icons.check_circle_rounded,
            iconColor: yellowColor,
            title: '$totalQuestions',
            subtitle: 'SOAL',
          ),
        ),
      ],
    );
  }

  Widget buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 30),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: yellowColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'LANJUTKAN',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
