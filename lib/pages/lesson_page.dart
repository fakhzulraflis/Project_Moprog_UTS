import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/question.dart';
import '../services/api_service.dart';
import '../services/player_progress.dart';

const Color _bg = Color(0xFF272F33);
const Color _surface = Color(0xFF1F292E);
const Color _border = Color(0xFF414F57);
const Color _yellow = Color(0xFFFCCF10);
const Color _yellowDark = Color(0xFFC9A200);
const Color _onYellow = Color(0xFF3B3000);
const Color _red = Color(0xFFFF4B4B);
const Color _redDark = Color(0xFFC93636);
const Color _gold = Color(0xFFFFC800);
const Color _blue = Color(0xFF1CB0F6);
const Color _blueDark = Color(0xFF1899D6);
const Color _green = Color(0xFF58CC02);
const Color _orange = Color(0xFFFF9600);

const List<Color> _pairPalette = [
  Color(0xFF1CB0F6),
  Color(0xFFCE82FF),
  Color(0xFFFF9600),
  Color(0xFF58CC02),
  Color(0xFFFF86D0),
  Color(0xFF2B70C9),
];

Color _pairColor(int index) => _pairPalette[index % _pairPalette.length];

Color _tint(Color c, [double amount = 0.14]) =>
    Color.alphaBlend(c.withValues(alpha: amount), _bg);

const double kFastSecondsPerQuestion = 10;
const double kSlowSecondsPerQuestion = 30;

class ResultVariant {
  final String title;
  final String subtitle;
  final String asset;
  final Color color;

  const ResultVariant({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.color,
  });
}

const ResultVariant _vPerfect = ResultVariant(
  title: 'Sempurna!',
  subtitle: 'Tidak ada satu pun jawaban yang salah.',
  asset: 'assets/chars/result_perfect.png',
  color: _gold,
);

const ResultVariant _vSuperFast = ResultVariant(
  title: 'Super cepat!',
  subtitle: 'Kamu menyelesaikan pelajaran ini dengan sangat cepat.',
  asset: 'assets/chars/result_super_fast.png',
  color: _gold,
);

const ResultVariant _vHigh = ResultVariant(
  title: 'Luar biasa!',
  subtitle: 'Akurasimu sangat tinggi. Pertahankan!',
  asset: 'assets/chars/result_high.png',
  color: _green,
);

const ResultVariant _vGood = ResultVariant(
  title: 'Bagus!',
  subtitle: 'Kamu sudah berada di jalur yang tepat.',
  asset: 'assets/chars/result_good.png',
  color: _green,
);

const ResultVariant _vSlowSteady = ResultVariant(
  title: 'Pelan tapi pasti!',
  subtitle: 'Kamu teliti, dan hasilnya pun bagus.',
  asset: 'assets/chars/result_good.png',
  color: _blue,
);

const ResultVariant _vLow = ResultVariant(
  title: 'Terus berlatih!',
  subtitle: 'Masih ada yang bisa diperbaiki. Coba ulangi pelajaran ini.',
  asset: 'assets/chars/result_low.png',
  color: _orange,
);

ResultVariant pickResultVariant({
  required int accuracy,
  required double secondsPerQuestion,
}) {
  final fast = secondsPerQuestion <= kFastSecondsPerQuestion;
  final slow = secondsPerQuestion >= kSlowSecondsPerQuestion;

  if (accuracy == 100) return _vPerfect;
  if (fast && accuracy >= 70) return _vSuperFast;
  if (accuracy >= 90) return _vHigh;
  if (accuracy >= 70) return slow ? _vSlowSteady : _vGood;
  return _vLow;
}

String accuracyLabel(int accuracy) {
  if (accuracy >= 90) return 'LUAR BIASA';
  if (accuracy >= 70) return 'BAGUS';
  return 'LATIH LAGI';
}

String timeLabel(double secondsPerQuestion) {
  if (secondsPerQuestion <= kFastSecondsPerQuestion) return 'KILAT';
  if (secondsPerQuestion >= kSlowSecondsPerQuestion) return 'SANTAI';
  return 'NORMAL';
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;

  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class LessonPage extends StatefulWidget {
  final int lessonId;
  final String ttsCode;

  const LessonPage({super.key, required this.lessonId, this.ttsCode = 'en-US'});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _WordDragData {
  final bool fromBank;
  final int index;

  const _WordDragData({required this.fromBank, required this.index});
}

class _LessonPageState extends State<LessonPage> {
  final FlutterTts _flutterTts = FlutterTts();
  List<Question> questions = [];

  bool isLoading = true;
  String? errorMessage;

  int currentQuestionIndex = 0;
  int hearts = 5;
  bool heartHit = false;

  int combo = 0;
  int comboDisplay = 2;
  int totalAttempts = 0;
  int correctAttempts = 0;
  final Stopwatch _stopwatch = Stopwatch();

  String? selectedAnswer;
  String typedAnswer = '';
  final TextEditingController _textController = TextEditingController();

  List<String> selectedWords = [];
  List<int> selectedWordIndexes = [];

  String? selectedLeft;
  final Map<String, String> matchedPairs = {};

  final Map<int, List<String>> _shuffledRight = {};

  bool hasChecked = false;
  bool isCorrect = false;
  String feedbackTitle = '';

  final math.Random _random = math.Random();

  static const List<String> _praise = [
    'Benar!',
    'Mantap!',
    'Keren!',
    'Hebat!',
    'Bagus sekali!',
  ];

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _textController.dispose();
    super.dispose();
  }

  Future<void> loadQuestions() async {
    try {
      final result = await ApiService.getQuestions(widget.lessonId);

      final bonusHearts = await PlayerProgress.instance.takeBonusHearts();

      if (!mounted) return;

      setState(() {
        questions = result;
        hearts += bonusHearts;
        isLoading = false;
      });

      _stopwatch.start();
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

    final done = currentQuestionIndex + (hasChecked && isCorrect ? 1 : 0);

    return done / questions.length;
  }

  bool usesChoices(Question q) {
    return q.type == 'multiple_choice' ||
        q.type == 'image_choice' ||
        (q.type == 'fill_blank' && q.choiceOptions.isNotEmpty);
  }

  void resetQuestionState() {
    selectedAnswer = null;
    typedAnswer = '';
    _textController.clear();

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

  Future<void> _speak(String text, {bool slow = false}) async {
    if (text.trim().isEmpty) return;

    try {
      await _flutterTts.stop();

      await _flutterTts.setLanguage(widget.ttsCode);

      await _flutterTts.setSpeechRate(slow ? 0.35 : 0.5);

      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);

      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS ERROR: $e');
    }
  }

  List<String> _rightItemsFor(Question q) {
    return _shuffledRight.putIfAbsent(q.id, () {
      final original = q.matchingOptions
          .map((pair) => pair['right'].toString())
          .toList();

      final items = List<String>.from(original)..shuffle(_random);

      if (items.length > 1) {
        bool same = true;
        for (int i = 0; i < items.length; i++) {
          if (items[i] != original[i]) {
            same = false;
            break;
          }
        }
        if (same) items.add(items.removeAt(0));
      }

      return items;
    });
  }

  String? _ownerOf(String right) {
    for (final entry in matchedPairs.entries) {
      if (entry.value == right) return entry.key;
    }
    return null;
  }

  bool _isPairCorrect(String left, String right) {
    return currentQuestion.matchingOptions.any(
      (pair) =>
          pair['left'].toString() == left && pair['right'].toString() == right,
    );
  }

  void checkAnswer() {
    if (hasChecked) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final question = currentQuestion;

    if (question.type == 'matching') {
      checkMatching();
      return;
    }

    String answer = '';

    if (usesChoices(question)) {
      answer = selectedAnswer ?? '';
    } else if (question.type == 'translation' ||
        question.type == 'fill_blank') {
      answer = typedAnswer.trim();
    } else if (question.type == 'word_bank' || question.type == 'listening') {
      answer = selectedWords.join(' ');
    }

    if (answer.isEmpty) {
      return;
    }

    final correct =
        normalizeAnswer(answer) == normalizeAnswer(question.correctAnswer);

    _applyResult(correct);
  }

  void checkMatching() {
    final pairs = currentQuestion.matchingOptions;

    final correct = pairs.every(
      (pair) =>
          matchedPairs[pair['left'].toString()] == pair['right'].toString(),
    );

    _applyResult(correct);
  }

  void _applyResult(bool correct) {
    if (correct) PlayerProgress.instance.recordCorrectAnswer();

    setState(() {
      hasChecked = true;
      isCorrect = correct;

      totalAttempts++;

      if (correct) {
        correctAttempts++;
        combo++;
        if (combo >= 2) comboDisplay = combo;
      } else {
        combo = 0;
      }

      feedbackTitle = correct
          ? _praise[_random.nextInt(_praise.length)]
          : 'Jawaban belum tepat';

      if (!correct && hearts > 0) {
        hearts--;
      }
    });

    if (!correct) _pulseHeart();

    if (!correct && hearts == 0) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          showOutOfHeartsDialog();
        }
      });
    }
  }

  void _pulseHeart() {
    setState(() => heartHit = true);

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => heartHit = false);
    });
  }

  void continueQuestion() {
    if (hearts == 0) {
      return;
    }

    if (!isCorrect) {
      setState(resetQuestionState);

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

  Future<void> showLessonComplete() async {
    _stopwatch.stop();

    final duration = _stopwatch.elapsed;

    final accuracy = totalAttempts == 0
        ? 100
        : (correctAttempts * 100 / totalAttempts).round();

    final secondsPerQuestion = questions.isEmpty
        ? 0.0
        : duration.inSeconds / questions.length;

    final xpEarned = await PlayerProgress.instance.completeLesson();

    if (!mounted) return;

    final variant = pickResultVariant(
      accuracy: accuracy,
      secondsPerQuestion: secondsPerQuestion,
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LessonCompleteScreen(
          variant: variant,
          xpEarned: xpEarned,
          accuracy: accuracy,
          duration: duration,
          secondsPerQuestion: secondsPerQuestion,
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

  Future<void> confirmExit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final leave = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tunggu, jangan pergi dulu!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Kalau keluar sekarang, progres pelajaran ini akan hilang.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: Button3D(
                    color: _yellow,
                    lipColor: _yellowDark,
                    holdBeforeTap: true,
                    height: 52,
                    depth: 5,
                    radius: 16,
                    alignment: Alignment.center,
                    onTap: () => Navigator.pop(sheetContext, false),
                    child: const Text(
                      'LANJUT BELAJAR',
                      style: TextStyle(
                        color: _onYellow,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                TextButton(
                  onPressed: () => Navigator.pop(sheetContext, true),
                  child: const Text(
                    'KELUAR',
                    style: TextStyle(
                      color: _red,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (leave == true && mounted) {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: CircularProgressIndicator(color: _yellow)),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
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
        backgroundColor: _bg,
        body: Center(
          child: Text('Tidak ada soal.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) confirmExit();
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            children: [
              buildTopBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.08, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topLeft,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(currentQuestionIndex),
                      child: buildQuestion(),
                    ),
                  ),
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.4),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: hasChecked ? buildFeedbackPanel() : buildCheckButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 22, 20, 6),
      child: Row(
        children: [
          IconButton(
            onPressed: confirmExit,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white54,
              size: 30,
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                LessonProgressBar(value: progress),

                Positioned(
                  left: 2,
                  top: -22,
                  child: AnimatedOpacity(
                    opacity: combo >= 2 ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      'COMBO x$comboDisplay',
                      style: const TextStyle(
                        color: _yellow,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          AnimatedScale(
            scale: heartHit ? 1.35 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Row(
              children: [
                Image.asset(
                  'assets/icons/hearts.png',
                  width: 26,
                  height: 26,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.favorite, color: _red, size: 26),
                ),

                const SizedBox(width: 6),

                Text(
                  '$hearts',
                  style: const TextStyle(
                    color: _red,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuestion() {
    final question = currentQuestion;
    final type = question.type;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getQuestionInstruction(type),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 24),

          buildPromptArea(question),

          const SizedBox(height: 28),

          if (usesChoices(question) && type != 'image_choice')
            buildMultipleChoice(question),

          if (type == 'image_choice') buildImageChoice(question),

          if (type == 'translation') buildTranslation(),

          if (type == 'word_bank' || type == 'listening')
            buildWordBank(question),

          if (type == 'fill_blank' && question.choiceOptions.isEmpty)
            buildFillBlank(),

          if (type == 'matching') buildMatching(question),
        ],
      ),
    );
  }

  String getQuestionInstruction(String type) {
    switch (type) {
      case 'multiple_choice':
        return 'Pilih terjemahan yang benar';

      case 'image_choice':
        return 'Pilih gambar yang benar';

      case 'translation':
        return 'Terjemahkan kalimat ini';

      case 'word_bank':
        return 'Susun kata-kata menjadi kalimat';

      case 'listening':
        return 'Ketuk apa yang kamu dengar';

      case 'fill_blank':
        return 'Lengkapi kalimat berikut';

      case 'matching':
        return 'Cocokkan pasangan yang benar';

      default:
        return 'Jawab pertanyaan berikut';
    }
  }

  Widget buildPromptArea(Question q) {
    const character = 'assets/chars/qua_idle.gif';

    switch (q.type) {
      case 'matching':
        if (q.prompt.isEmpty) return const SizedBox.shrink();

        return Text(
          q.prompt,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        );

      case 'image_choice':
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (q.audioText != null) ...[
              _AudioSquare(onTap: () => _speak(q.audioText!)),
              const SizedBox(width: 14),
            ],
            Expanded(child: _romanizedText(q, fontSize: 28)),
          ],
        );

      case 'listening':
        final heard = q.audioText ?? q.correctAnswer;

        return CharacterBubble(
          asset: character,
          bubblePadding: EdgeInsets.zero,
          child: _BubbleAudioButtons(
            onNormal: () => _speak(heard),
            onSlow: () => _speak(heard, slow: true),
          ),
        );

      default:
        return CharacterBubble(
          asset: character,
          child: Row(
            children: [
              if (q.audioText != null) ...[
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _speak(q.audioText!),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: _blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(child: _romanizedText(q, fontSize: 22)),
            ],
          ),
        );
    }
  }

  Widget _romanizedText(Question q, {required double fontSize}) {
    final romaji = q.romanization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (romaji != null && romaji.isNotEmpty)
          Text(
            romaji,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),

        Text(
          q.prompt,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  _ChoiceStyle _choiceStyle({
    required bool isSelected,
    required bool isRight,
    required bool isWrong,
  }) {
    if (isWrong) return _ChoiceStyle(_tint(_red, 0.18), _red, _red);

    if (isRight) return _ChoiceStyle(_tint(_yellow, 0.18), _yellow, _yellow);

    if (isSelected) return _ChoiceStyle(_tint(_yellow), _yellow, _yellow);

    return const _ChoiceStyle(_bg, _border, Colors.white);
  }

  Widget buildMultipleChoice(Question question) {
    final options = question.choiceOptions;

    final hasRomaji = options.any(
      (option) => (option.romanization ?? '').isNotEmpty,
    );

    return Column(
      children: options.map((option) {
        final isSelected = selectedAnswer == option.text;
        final romaji = option.romanization ?? '';

        final style = _choiceStyle(
          isSelected: isSelected,
          isRight: hasChecked && option.text == question.correctAnswer,
          isWrong: hasChecked && isSelected && !isCorrect,
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            width: double.infinity,
            child: Button3D(
              color: style.face,
              lipColor: style.edge,
              borderColor: style.edge,
              enabled: !hasChecked,
              depth: 4,
              radius: 16,
              padding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: hasRomaji ? 12 : 18,
              ),
              alignment: Alignment.center,
              onTap: () {
                setState(() {
                  selectedAnswer = option.text;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (romaji.isNotEmpty)
                    Text(
                      romaji,
                      style: TextStyle(
                        color: style.text.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                  Text(
                    option.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: style.text,
                      fontSize: hasRomaji ? 26 : 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget buildImageChoice(Question question) {
    final items = question.imageOptions;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items.map((item) {
            final label = item['label']?.toString() ?? '';
            final image = item['image']?.toString();

            final isSelected = selectedAnswer == label;

            final style = _choiceStyle(
              isSelected: isSelected,
              isRight: hasChecked && label == question.correctAnswer,
              isWrong: hasChecked && isSelected && !isCorrect,
            );

            return SizedBox(
              width: cardWidth,
              child: Button3D(
                color: style.face,
                lipColor: style.edge,
                borderColor: style.edge,
                enabled: !hasChecked,
                depth: 4,
                radius: 18,
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                onTap: () {
                  setState(() {
                    selectedAnswer = label;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 110,
                      width: double.infinity,
                      child: _optionImage(image),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: style.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _optionImage(String? src) {
    Widget fallback() => const Center(
      child: Icon(Icons.image_not_supported_rounded, color: Colors.white24),
    );

    if (src == null || src.isEmpty) return fallback();

    if (src.startsWith('http')) {
      return Image.network(
        src,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => fallback(),
      );
    }

    return Image.asset(
      src,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => fallback(),
    );
  }

  OutlineInputBorder _outline(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: 2),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    final doneColor = isCorrect ? _yellow : _red;

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white30,
        fontWeight: FontWeight.normal,
      ),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.all(18),
      border: _outline(_border),
      enabledBorder: _outline(_border),
      disabledBorder: _outline(hasChecked ? doneColor : _border),
      focusedBorder: _outline(_yellow),
    );
  }

  Widget buildTranslation() {
    return TextField(
      controller: _textController,
      enabled: !hasChecked,
      onChanged: (value) {
        setState(() {
          typedAnswer = value;
        });
      },
      style: const TextStyle(color: Colors.white, fontSize: 18),
      minLines: 3,
      maxLines: 5,
      cursorColor: _yellow,
      decoration: _fieldDecoration('Ketik terjemahanmu di sini...'),
    );
  }

  Widget buildFillBlank() {
    return TextField(
      controller: _textController,
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
      cursorColor: _yellow,
      decoration: _fieldDecoration('Ketik kata yang hilang...'),
    );
  }

  void _addWord(int index) {
    if (hasChecked) return;
    if (selectedWordIndexes.contains(index)) return;

    setState(() {
      selectedWords.add(currentQuestion.choiceOptions[index].text);
      selectedWordIndexes.add(index);
    });
  }

  void _removeWord(int position) {
    if (hasChecked) return;
    if (position < 0 || position >= selectedWords.length) return;

    setState(() {
      selectedWords.removeAt(position);
      selectedWordIndexes.removeAt(position);
    });
  }

  void _insertWordFromBank(int bankIndex, int position) {
    if (hasChecked) return;
    if (selectedWordIndexes.contains(bankIndex)) return;

    final word = currentQuestion.choiceOptions[bankIndex].text;

    setState(() {
      final safePosition = position.clamp(0, selectedWords.length);

      selectedWords.insert(safePosition, word);
      selectedWordIndexes.insert(safePosition, bankIndex);
    });
  }

  void _returnWordToBank(int position) {
    if (hasChecked) return;
    if (position < 0 || position >= selectedWords.length) return;

    setState(() {
      selectedWords.removeAt(position);
      selectedWordIndexes.removeAt(position);
    });
  }

  void _moveWord(int oldIndex, int newIndex) {
    if (hasChecked) return;
    if (oldIndex < 0 || oldIndex >= selectedWords.length) return;
    if (newIndex < 0 || newIndex >= selectedWords.length) return;

    if (oldIndex == newIndex) return;

    setState(() {
      final word = selectedWords.removeAt(oldIndex);
      final sourceIndex = selectedWordIndexes.removeAt(oldIndex);

      selectedWords.insert(newIndex, word);
      selectedWordIndexes.insert(newIndex, sourceIndex);
    });
  }

  Widget buildWordBank(Question question) {
    final words = question.choiceOptions;

    final hasRomaji = words.any((word) => (word.romanization ?? '').isNotEmpty);

    final chipHeight = hasRomaji ? 60.0 : 44.0;
    final pitch = chipHeight + 12;

    final chipEdge = hasChecked ? (isCorrect ? _yellow : _red) : _border;

    final chipFace = hasChecked ? _tint(chipEdge, 0.16) : _bg;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================
        // AREA JAWABAN
        // =========================
        DragTarget<_WordDragData>(
          onWillAcceptWithDetails: (details) {
            return !hasChecked;
          },
          onAcceptWithDetails: (details) {
            final data = details.data;

            if (data.fromBank) {
              _insertWordFromBank(data.index, selectedWords.length);
            }
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;

            return Container(
              width: double.infinity,
              constraints: BoxConstraints(minHeight: pitch * 2 + 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isHovering
                    ? Border.all(color: _yellow, width: 2)
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _AnswerLinesPainter(pitch)),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 8),
                    child: selectedWords.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: Text(
                                isHovering
                                    ? 'Lepaskan di sini'
                                    : 'Tarik kata ke sini',
                                style: TextStyle(
                                  color: isHovering ? _yellow : Colors.white24,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(selectedWords.length, (i) {
                              final source = words[selectedWordIndexes[i]];

                              return _answerWordTarget(
                                position: i,
                                word: source.text,
                                romaji: source.romanization,
                                height: chipHeight,
                                edge: chipEdge,
                                face: chipFace,
                              );
                            }),
                          ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 28),

        DragTarget<_WordDragData>(
          onWillAcceptWithDetails: (details) {
            return !hasChecked && !details.data.fromBank;
          },

          onAcceptWithDetails: (details) {
            final data = details.data;

            _returnWordToBank(data.index);
          },

          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isHovering ? _yellow : Colors.transparent,
                  width: 2,
                ),
              ),

              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(words.length, (index) {
                  final word = words[index];

                  final isUsed = selectedWordIndexes.contains(index);

                  return _bankWordChip(
                    index: index,
                    word: word.text,
                    romaji: word.romanization,
                    height: chipHeight,
                    enabled: !hasChecked && !isUsed,
                    ghost: isUsed,
                  );
                }),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _bankWordChip({
    required int index,
    required String word,
    String? romaji,
    required double height,
    required bool enabled,
    required bool ghost,
  }) {
    final chip = _wordChip(
      word,
      romaji: romaji,
      height: height,
      edge: _border,
      face: _bg,
      onTap: enabled ? () => _addWord(index) : null,
      ghost: ghost,
    );

    if (!enabled || ghost) {
      return chip;
    }

    return Draggable<_WordDragData>(
      data: _WordDragData(fromBank: true, index: index),

      feedback: Material(
        color: Colors.transparent,
        child: _wordChip(
          word,
          romaji: romaji,
          height: height,
          edge: _yellow,
          face: _tint(_yellow, 0.18),
          onTap: null,
        ),
      ),

      childWhenDragging: Opacity(opacity: 0.25, child: chip),

      child: chip,
    );
  }

  Widget _answerWordTarget({
    required int position,
    required String word,
    String? romaji,
    required double height,
    required Color edge,
    required Color face,
  }) {
    return DragTarget<_WordDragData>(
      onWillAcceptWithDetails: (details) {
        return !hasChecked && !details.data.fromBank;
      },

      onAcceptWithDetails: (details) {
        final data = details.data;

        _moveWord(data.index, position);
      },

      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;

        final chip = _answerWordChip(
          position: position,
          word: word,
          romaji: romaji,
          height: height,
          edge: isHovering ? _yellow : edge,
          face: isHovering ? _tint(_yellow, 0.18) : face,
        );

        if (!isHovering) {
          return chip;
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _yellow, width: 2),
          ),
          child: chip,
        );
      },
    );
  }

  Widget _answerWordChip({
    required int position,
    required String word,
    String? romaji,
    required double height,
    required Color edge,
    required Color face,
  }) {
    final chip = _wordChip(
      word,
      romaji: romaji,
      height: height,
      edge: edge,
      face: face,
      onTap: hasChecked ? null : () => _removeWord(position),
    );

    if (hasChecked) {
      return chip;
    }

    return Draggable<_WordDragData>(
      data: _WordDragData(fromBank: false, index: position),

      feedback: Material(
        color: Colors.transparent,
        child: _wordChip(
          word,
          romaji: romaji,
          height: height,
          edge: _yellow,
          face: _tint(_yellow, 0.18),
          onTap: null,
        ),
      ),

      childWhenDragging: Opacity(opacity: 0.25, child: chip),

      child: chip,
    );
  }

  Widget _chipLabel(
    String word,
    String? romaji, {
    required Color textColor,
    required Color romajiColor,
  }) {
    final hasRomaji = (romaji ?? '').isNotEmpty;

    return Center(
      widthFactor: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasRomaji)
            Text(
              romaji!,
              style: TextStyle(
                color: romajiColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

          Text(
            word,
            style: TextStyle(
              color: textColor,
              fontSize: hasRomaji ? 18 : 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wordChip(
    String word, {
    String? romaji,
    required double height,
    required Color edge,
    required VoidCallback? onTap,
    Color face = _bg,
    bool ghost = false,
  }) {
    if (ghost) {
      return Button3D(
        color: _surface,
        lipColor: _surface,
        enabled: false,
        onTap: null,
        height: height,
        depth: 4,
        radius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _chipLabel(
          word,
          romaji,
          textColor: Colors.transparent,
          romajiColor: Colors.transparent,
        ),
      );
    }

    return Button3D(
      color: face,
      lipColor: edge,
      borderColor: edge,
      enabled: onTap != null,
      onTap: onTap,
      height: height,
      depth: 4,
      radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _chipLabel(
        word,
        romaji,
        textColor: Colors.white,
        romajiColor: Colors.white38,
      ),
    );
  }

  Widget buildMatching(Question question) {
    final pairs = question.matchingOptions;

    final leftItems = pairs.map((pair) => pair['left'].toString()).toList();

    final rightItems = _rightItemsFor(question);

    final order = matchedPairs.keys.toList();

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
                  final partner = matchedPairs[left];

                  return _matchItem(
                    text: left,
                    selected: selectedLeft == left,
                    pairColor: matched ? _pairColor(order.indexOf(left)) : null,
                    status: hasChecked && partner != null
                        ? (_isPairCorrect(left, partner) ? 1 : -1)
                        : 0,
                    onTap: hasChecked
                        ? null
                        : () {
                            setState(() {
                              if (matched) {
                                matchedPairs.remove(left);
                                selectedLeft = null;
                              } else {
                                selectedLeft = left;
                              }
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
                  final owner = _ownerOf(right);
                  final matched = owner != null;

                  return _matchItem(
                    text: right,
                    selected: false,
                    pairColor: matched
                        ? _pairColor(order.indexOf(owner))
                        : null,
                    status: hasChecked && owner != null
                        ? (_isPairCorrect(owner, right) ? 1 : -1)
                        : 0,
                    onTap: hasChecked
                        ? null
                        : () {
                            setState(() {
                              if (matched) {
                                matchedPairs.remove(owner);
                                selectedLeft = null;
                              } else if (selectedLeft != null) {
                                matchedPairs[selectedLeft!] = right;
                                selectedLeft = null;
                              }
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

  Widget _matchItem({
    required String text,
    required bool selected,
    required Color? pairColor,
    required int status,
    required VoidCallback? onTap,
  }) {
    Color face = _bg;
    Color edge = _border;
    Color textColor = Colors.white;

    if (selected) {
      face = _tint(Colors.white, 0.10);
      edge = Colors.white;
    }

    if (pairColor != null) {
      face = _tint(pairColor);
      edge = pairColor;
      textColor = pairColor;
    }

    if (status == 1) {
      face = _tint(_yellow, 0.18);
      edge = _yellow;
      textColor = _yellow;
    }

    if (status == -1) {
      face = _tint(_red, 0.18);
      edge = _red;
      textColor = _red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: Button3D(
          color: face,
          lipColor: edge,
          borderColor: edge,
          enabled: onTap != null,
          onTap: onTap,
          depth: 4,
          radius: 14,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCheckButton() {
    bool canCheck = false;

    final question = currentQuestion;
    final type = question.type;

    if (usesChoices(question)) {
      canCheck = selectedAnswer != null;
    } else if (type == 'translation' || type == 'fill_blank') {
      canCheck = typedAnswer.trim().isNotEmpty;
    } else if (type == 'word_bank' || type == 'listening') {
      canCheck = selectedWords.isNotEmpty;
    } else if (type == 'matching') {
      canCheck = matchedPairs.length == question.matchingOptions.length;
    }

    return SafeArea(
      key: const ValueKey('check'),
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
        decoration: const BoxDecoration(
          color: _bg,
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Button3D(
            color: canCheck ? _yellow : const Color(0xFF3A464D),
            lipColor: canCheck ? _yellowDark : const Color(0xFF2E383E),
            enabled: canCheck,
            holdBeforeTap: true,
            onTap: checkAnswer,
            height: 52,
            depth: 5,
            radius: 16,
            alignment: Alignment.center,
            child: Text(
              'PERIKSA',
              style: TextStyle(
                color: canCheck ? _onYellow : Colors.white30,
                fontWeight: FontWeight.w900,
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
    final accent = isCorrect ? _yellow : _red;
    final panelBg = isCorrect
        ? const Color(0xFF3A3410)
        : const Color(0xFF3B1D1D);

    final title = isCorrect
        ? feedbackTitle
        : hearts == 0
        ? 'Hati habis'
        : feedbackTitle;

    final meaning = currentQuestion.meaning;
    final showMeaning = isCorrect && meaning != null && meaning.isNotEmpty;

    return SafeArea(
      key: const ValueKey('feedback'),
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        decoration: BoxDecoration(
          color: panelBg,
          border: Border(top: BorderSide(color: accent, width: 2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCorrect ? Icons.check_rounded : Icons.close_rounded,
                    color: isCorrect ? _onYellow : Colors.white,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: accent,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),

                      if (showMeaning) ...[
                        const SizedBox(height: 4),

                        const Text(
                          'Artinya:',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          meaning,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],

                      if (!isCorrect) ...[
                        const SizedBox(height: 4),

                        const Text(
                          'Jawaban yang benar:',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          currentQuestion.correctAnswer,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Opacity(
              opacity: hearts > 0 ? 1 : 0.5,
              child: SizedBox(
                width: double.infinity,
                child: Button3D(
                  color: accent,
                  lipColor: isCorrect ? _yellowDark : _redDark,
                  enabled: hearts > 0,
                  holdBeforeTap: true,
                  onTap: continueQuestion,
                  height: 52,
                  depth: 5,
                  radius: 16,
                  alignment: Alignment.center,
                  child: Text(
                    isCorrect
                        ? 'LANJUT'
                        : hearts == 0
                        ? 'SELESAI'
                        : 'COBA LAGI',
                    style: TextStyle(
                      color: isCorrect ? _onYellow : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
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

              combo = 0;
              totalAttempts = 0;
              correctAttempts = 0;

              _stopwatch
                ..reset()
                ..start();

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

class _ChoiceStyle {
  final Color face;
  final Color edge;
  final Color text;

  const _ChoiceStyle(this.face, this.edge, this.text);
}

class CharacterBubble extends StatelessWidget {
  final String asset;
  final Widget child;
  final EdgeInsetsGeometry bubblePadding;

  const CharacterBubble({
    super.key,
    required this.asset,
    required this.child,
    this.bubblePadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CharacterImage(asset: asset, width: 150, height: 110),

        const SizedBox(width: 10),

        Expanded(
          child: _SpeechBubble(padding: bubblePadding, child: child),
        ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _SpeechBubble({required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    const edge = BorderSide(color: _border, width: 2);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72),
          padding: padding,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.fromBorderSide(edge),
          ),
          alignment: Alignment.centerLeft,
          child: child,
        ),

        Positioned(
          left: -9,
          top: 0,
          bottom: 0,
          child: Center(
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: _surface,
                  border: Border(left: edge, bottom: edge),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CharacterImage extends StatelessWidget {
  final String asset;
  final double width;
  final double height;

  const CharacterImage({
    super.key,
    required this.asset,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}

class _AudioSquare extends StatelessWidget {
  final VoidCallback onTap;

  const _AudioSquare({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      child: Button3D(
        color: _blue,
        lipColor: _blueDark,
        height: 52,
        depth: 4,
        radius: 16,
        alignment: Alignment.center,
        onTap: onTap,
        child: const Icon(
          Icons.volume_up_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}

class _BubbleAudioButtons extends StatelessWidget {
  final VoidCallback onNormal;
  final VoidCallback onSlow;

  const _BubbleAudioButtons({required this.onNormal, required this.onSlow});

  Widget _flat(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Icon(icon, color: _blue, size: 38)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _flat(Icons.volume_up_rounded, onNormal)),

          Container(width: 2, color: _border),

          Expanded(child: _flat(Icons.slow_motion_video_rounded, onSlow)),
        ],
      ),
    );
  }
}

class _AnswerLinesPainter extends CustomPainter {
  final double pitch;

  _AnswerLinesPainter(this.pitch);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _border
      ..strokeWidth = 2;

    for (double y = pitch; y < size.height; y += pitch) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AnswerLinesPainter oldDelegate) =>
      oldDelegate.pitch != pitch;
}

class LessonProgressBar extends StatelessWidget {
  final double value;

  const LessonProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fillWidth = constraints.maxWidth * value.clamp(0.0, 1.0);

        return Container(
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF3A464D),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              width: fillWidth,
              height: 16,
              decoration: BoxDecoration(
                color: _yellow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: fillWidth > 24
                  ? Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}

class Button3D extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final bool holdBeforeTap;
  final Color color;
  final Color? lipColor;
  final Color? borderColor;
  final double? height;
  final double depth;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment;

  const Button3D({
    super.key,
    required this.child,
    required this.onTap,
    required this.color,
    this.lipColor,
    this.borderColor,
    this.enabled = true,
    this.holdBeforeTap = false,
    this.height,
    this.depth = 4,
    this.radius = 14,
    this.padding,
    this.alignment,
  });

  @override
  State<Button3D> createState() => _Button3DState();
}

class _Button3DState extends State<Button3D> {
  bool _pressed = false;
  DateTime? _pressStart;

  static const Duration minPress = Duration(milliseconds: 120);

  bool get _active => widget.enabled && widget.onTap != null;

  Color _darken(Color c, [double amount = 0.15]) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  void _down() {
    if (!_active) return;

    _pressStart = DateTime.now();

    if (!_pressed) setState(() => _pressed = true);
  }

  Future<void> _up() async {
    final start = _pressStart;

    if (start != null) {
      final elapsed = DateTime.now().difference(start);

      if (elapsed < minPress) {
        await Future.delayed(minPress - elapsed);
      }
    }

    if (mounted && _pressed) setState(() => _pressed = false);
  }

  Future<void> _tap() async {
    if (!_active) return;

    if (widget.holdBeforeTap) {
      await _up();

      if (!mounted) return;

      widget.onTap?.call();
    } else {
      widget.onTap?.call();

      _up();
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.radius);
    final lip = widget.lipColor ?? _darken(widget.color);
    final border = widget.borderColor;

    return Listener(
      onPointerDown: (_) => _down(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapCancel: _up,
        onTap: _tap,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(
              top: widget.depth,
              child: DecoratedBox(
                decoration: BoxDecoration(color: lip, borderRadius: radius),
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              curve: Curves.easeOut,
              height: widget.height,
              margin: EdgeInsets.only(
                top: _pressed ? widget.depth : 0,
                bottom: _pressed ? 0 : widget.depth,
              ),
              padding: widget.padding,
              alignment: widget.alignment,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: radius,
                border: border != null
                    ? Border.all(color: border, width: 2)
                    : null,
              ),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

class PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double pressedOffset;

  const PressableButton({
    super.key,
    required this.child,
    required this.onTap,
    this.enabled = true,
    this.pressedOffset = 4,
  });

  @override
  State<PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<PressableButton> {
  bool isPressed = false;

  void pressDown() {
    if (!widget.enabled || widget.onTap == null) {
      return;
    }

    setState(() {
      isPressed = true;
    });
  }

  void pressUp() {
    if (!widget.enabled || widget.onTap == null) {
      return;
    }

    setState(() {
      isPressed = false;
    });
  }

  void handleTap() {
    if (!widget.enabled || widget.onTap == null) {
      return;
    }

    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      onTapDown: (_) {
        pressDown();
      },

      onTapUp: (_) {
        pressUp();
        handleTap();
      },

      onTapCancel: () {
        pressUp();
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,

        transform: Matrix4.translationValues(
          0,
          isPressed ? widget.pressedOffset : 0,
          0,
        ),

        child: widget.child,
      ),
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          color: _bg,
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
                          'Oh tidak!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Hati kamu habis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'Kamu perlu mengulang '
                          'untuk menyelesaikan pelajaran ini.',
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
        color: _red.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: _red.withValues(alpha: 0.35), width: 2),
      ),
      child: const Center(
        child: Icon(Icons.heart_broken_rounded, color: _red, size: 65),
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
          Icon(Icons.favorite, color: _red, size: 27),

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
            child: Button3D(
              color: _yellow,
              lipColor: _yellowDark,
              holdBeforeTap: true,
              onTap: onRetry,
              height: 54,
              depth: 5,
              radius: 16,
              alignment: Alignment.center,
              child: const Text(
                'COBA LAGI',
                style: TextStyle(
                  color: _onYellow,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          TextButton(
            onPressed: onExit,
            child: const Text(
              'KELUAR',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LessonCompleteScreen extends StatelessWidget {
  final ResultVariant variant;
  final int xpEarned;
  final int accuracy;
  final Duration duration;
  final double secondsPerQuestion;
  final VoidCallback onContinue;

  const LessonCompleteScreen({
    super.key,
    required this.variant,
    required this.xpEarned,
    required this.accuracy,
    required this.duration,
    required this.secondsPerQuestion,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Container(
          color: _bg,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            return Transform.scale(scale: value, child: child);
                          },
                          child: CharacterImage(
                            asset: variant.asset,
                            width: 240,
                            height: 240,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          variant.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: variant.color,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          variant.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 17,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 36),

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

  Widget buildStats() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _ResultStatCard(
            label: 'TOTAL XP',
            accent: _gold,
            labelColor: _onYellow,
            icon: Icons.bolt_rounded,
            value: '$xpEarned',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ResultStatCard(
            label: accuracyLabel(accuracy),
            accent: _green,
            labelColor: Colors.white,
            icon: Icons.track_changes_rounded,
            value: '$accuracy%',
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ResultStatCard(
            label: timeLabel(secondsPerQuestion),
            accent: _blue,
            labelColor: Colors.white,
            icon: Icons.speed_rounded,
            value: _formatDuration(duration),
          ),
        ),
      ],
    );
  }

  Widget buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: SizedBox(
        width: double.infinity,
        child: Button3D(
          color: _yellow,
          lipColor: _yellowDark,
          holdBeforeTap: true,
          onTap: onContinue,
          height: 54,
          depth: 5,
          radius: 16,
          alignment: Alignment.center,
          child: const Text(
            'LANJUTKAN',
            style: TextStyle(
              color: _onYellow,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStatCard extends StatelessWidget {
  final String label;
  final Color accent;
  final Color labelColor;
  final IconData icon;
  final String value;

  const _ResultStatCard({
    required this.label,
    required this.accent,
    required this.labelColor,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: accent, size: 24),

                const SizedBox(width: 5),

                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: accent,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
