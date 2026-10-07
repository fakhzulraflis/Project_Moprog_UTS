import 'package:flutter/material.dart';

import '../models/vocabulary.dart';
import '../services/api_service.dart';
import '../services/mistake_service.dart';

class MistakeReviewPage extends StatefulWidget {
  final String selectedLanguage;

  const MistakeReviewPage({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<MistakeReviewPage> createState() =>
      _MistakeReviewPageState();
}

class _MistakeReviewPageState
    extends State<MistakeReviewPage> {
  List<Vocabulary> allVocabularies = [];
  List<Vocabulary> mistakeVocabularies = [];
  List<String> answerOptions = [];

  Vocabulary? currentVocabulary;

  String? selectedAnswer;
  String? errorMessage;

  bool isLoading = true;
  bool isAnswerChecked = false;
  bool? isAnswerCorrect;
  bool isFinished = false;

  int questionIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;

  @override
  void initState() {
    super.initState();

    loadMistakes();
  }

  String getTranslation(
    Vocabulary vocabulary,
  ) {
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

  Future<void> loadMistakes() async {
    setState(() {
      isLoading = true;
      errorMessage = null;

      questionIndex = 0;

      correctAnswers = 0;
      wrongAnswers = 0;

      isFinished = false;
    });

    try {
      final vocabularies =
          await ApiService.getVocabularies();

      final mistakeIds =
          await MistakeService.getMistakeIds();

      if (!mounted) return;

      final mistakes = vocabularies
          .where(
            (vocabulary) =>
                mistakeIds.contains(
              vocabulary.id,
            ),
          )
          .toList()
        ..shuffle();

      setState(() {
        allVocabularies =
            vocabularies;

        mistakeVocabularies =
            mistakes;

        if (mistakes.isNotEmpty) {
          generateQuestion();
        }

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Gagal mengambil data kesalahan.';

        isLoading = false;
      });
    }
  }

  void generateQuestion() {
    if (mistakeVocabularies.isEmpty) {
      return;
    }

    currentVocabulary =
        mistakeVocabularies[
            questionIndex];

    final correctAnswer =
        getTranslation(
      currentVocabulary!,
    );

    final distractors =
        allVocabularies
            .where(
              (vocabulary) =>
                  vocabulary.id !=
                  currentVocabulary!.id,
            )
            .toList()
          ..shuffle();

    final options = <String>[
      correctAnswer,
    ];

    for (final vocabulary
        in distractors) {
      final translation =
          getTranslation(
        vocabulary,
      );

      if (!options.contains(
        translation,
      )) {
        options.add(
          translation,
        );
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

  void selectAnswer(
    String answer,
  ) {
    if (isAnswerChecked) {
      return;
    }

    setState(() {
      selectedAnswer = answer;
    });
  }

  Future<void> checkAnswer() async {
    if (selectedAnswer == null ||
        currentVocabulary == null) {
      return;
    }

    final vocabulary =
        currentVocabulary!;

    final correct =
        selectedAnswer ==
            getTranslation(
              vocabulary,
            );

    setState(() {
      isAnswerChecked = true;
      isAnswerCorrect = correct;

      if (correct) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }
    });

    if (correct) {
      await MistakeService
          .removeMistake(
        vocabulary.id,
      );
    }
  }

  void nextQuestion() {
    if (questionIndex >=
        mistakeVocabularies
                .length -
            1) {
      setState(() {
        isFinished = true;
      });

      return;
    }

    setState(() {
      questionIndex++;

      generateQuestion();
    });
  }

  Color optionColor(
    String option,
  ) {
    if (!isAnswerChecked) {
      return selectedAnswer ==
              option
          ? const Color(
              0xFFE7C249,
            )
          : const Color(
              0xFF20272B,
            );
    }

    final correctAnswer =
        getTranslation(
      currentVocabulary!,
    );

    if (option ==
        correctAnswer) {
      return const Color(
        0xFF356859,
      );
    }

    if (option ==
        selectedAnswer) {
      return const Color(
        0xFF8B3A3A,
      );
    }

    return const Color(
      0xFF20272B,
    );
  }

  Widget buildEmpty() {
    return const Center(
      child: Padding(
        padding:
            EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Icon(
              Icons
                  .check_circle_rounded,
              color:
                  Color(
                0xFFE7C249,
              ),
              size: 90,
            ),

            SizedBox(
              height: 20,
            ),

            Text(
              'Semua Aman!',
              style: TextStyle(
                color:
                    Colors.white,
                fontSize: 27,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 10,
            ),

            Text(
              'Belum ada kosakata yang perlu direview.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGame() {
    if (currentVocabulary ==
        null) {
      return buildEmpty();
    }

    return SingleChildScrollView(
      padding:
          const EdgeInsets.all(
        20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              const Text(
                'Review Kesalahan',
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontSize: 23,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(
                '${questionIndex + 1}/${mistakeVocabularies.length}',
                style:
                    const TextStyle(
                  color:
                      Color(
                    0xFFE7C249,
                  ),
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 50,
          ),

          const Center(
            child: Text(
              'Apa terjemahan dari:',
              style: TextStyle(
                color:
                    Colors.white70,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          Center(
            child: Text(
              currentVocabulary!
                  .indonesian,
              style:
                  const TextStyle(
                color:
                    Colors.white,
                fontSize: 34,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            height: 35,
          ),

          ...answerOptions.map(
            (option) =>
                Padding(
              padding:
                  const EdgeInsets
                      .only(
                bottom: 12,
              ),
              child:
                  GestureDetector(
                onTap: () =>
                    selectAnswer(
                  option,
                ),
                child:
                    AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds:
                        200,
                  ),
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .all(18),
                  decoration:
                      BoxDecoration(
                    color:
                        optionColor(
                      option,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      16,
                    ),
                  ),
                  child: Text(
                    option,
                    style:
                        TextStyle(
                      color:
                          !isAnswerChecked &&
                                  selectedAnswer ==
                                      option
                              ? const Color(
                                  0xFF272F33,
                                )
                              : Colors
                                  .white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (isAnswerChecked) ...[
            const SizedBox(
              height: 10,
            ),

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets
                      .all(16),
              decoration:
                  BoxDecoration(
                color:
                    isAnswerCorrect ==
                            true
                        ? const Color(
                            0xFF356859,
                          )
                        : const Color(
                            0xFF8B3A3A,
                          ),
                borderRadius:
                    BorderRadius
                        .circular(
                  14,
                ),
              ),
              child: Text(
                isAnswerCorrect ==
                        true
                    ? 'Benar! Kata ini sudah dikuasai.'
                    : 'Masih salah. Kata ini akan tetap ada di Review Kesalahan.',
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(
            height: 20,
          ),

          SizedBox(
            width:
                double.infinity,
            child:
                ElevatedButton(
              onPressed:
                  isAnswerChecked
                      ? nextQuestion
                      : selectedAnswer !=
                              null
                          ? () {
                              checkAnswer();
                            }
                          : null,
              child: Text(
                isAnswerChecked
                    ? 'LANJUT'
                    : 'PERIKSA JAWABAN',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFinished() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons
                .task_alt_rounded,
            color:
                Color(
              0xFFE7C249,
            ),
            size: 90,
          ),

          const SizedBox(
            height: 20,
          ),

          const Text(
            'Review Selesai!',
            style: TextStyle(
              color:
                  Colors.white,
              fontSize: 28,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          ElevatedButton(
            onPressed:
                loadMistakes,
            child:
                const Text(
              'MUAT ULANG',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(
        0xFF272F33,
      ),
      appBar: AppBar(
        backgroundColor:
            const Color(
          0xFF272F33,
        ),
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Review Kesalahan',
          style: TextStyle(
            color:
                Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      Color(
                    0xFFE7C249,
                  ),
                ),
              )
            : errorMessage !=
                    null
                ? Center(
                    child: Text(
                      errorMessage!,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),
                    ),
                  )
                : mistakeVocabularies
                        .isEmpty
                    ? buildEmpty()
                    : isFinished
                        ? buildFinished()
                        : buildGame(),
      ),
    );
  }
}