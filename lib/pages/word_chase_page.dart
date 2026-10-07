import 'package:flutter/material.dart';

import '../models/vocabulary.dart';
import '../services/api_service.dart';

class WordChasePage extends StatefulWidget {
  final String selectedLanguage;

  const WordChasePage({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<WordChasePage> createState() => _WordChasePageState();
}

class _WordChasePageState extends State<WordChasePage> {
  List<Vocabulary> vocabularies = [];
  List<String> answerOptions = [];

  Vocabulary? currentVocabulary;

  String? selectedAnswer;
  String? errorMessage;

  bool isLoading = true;
  bool isAnswerChecked = false;
  bool? isAnswerCorrect;

  int questionIndex = 0;

  @override
  void initState() {
    super.initState();

    loadVocabularies();
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

  Future<void> loadVocabularies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.getVocabularies();

      if (!mounted) return;

      final shuffled = List<Vocabulary>.from(result)
        ..shuffle();

      setState(() {
        vocabularies = shuffled;
        questionIndex = 0;
        isLoading = false;

        generateQuestion();
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Gagal mengambil kosakata dari server.';
        isLoading = false;
      });

      debugPrint('Kejar Kata error: $e');
    }
  }

  void generateQuestion() {
    if (vocabularies.isEmpty) {
      return;
    }

    if (questionIndex >= vocabularies.length) {
      vocabularies.shuffle();
      questionIndex = 0;
    }

    currentVocabulary =
        vocabularies[questionIndex];

    final correctAnswer =
        getTranslation(currentVocabulary!);

    final distractorVocabularies =
        vocabularies
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
        in distractorVocabularies) {
      final translation =
          getTranslation(vocabulary);

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
    if (isAnswerChecked) {
      return;
    }

    setState(() {
      selectedAnswer = answer;
    });
  }

  void checkAnswer() {
    if (selectedAnswer == null ||
        currentVocabulary == null) {
      return;
    }

    final correctAnswer =
        getTranslation(currentVocabulary!);

    setState(() {
      isAnswerChecked = true;
      isAnswerCorrect =
          selectedAnswer == correctAnswer;
    });
  }

  void nextQuestion() {
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

    final correctAnswer =
        getTranslation(currentVocabulary!);

    if (option == correctAnswer) {
      return const Color(0xFF356859);
    }

    if (option == selectedAnswer &&
        option != correctAnswer) {
      return const Color(0xFF8B3A3A);
    }

    return const Color(0xFF20272B);
  }

  Color getOptionTextColor(String option) {
    if (!isAnswerChecked &&
        selectedAnswer == option) {
      return const Color(0xFF272F33);
    }

    return Colors.white;
  }

  Widget buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFE7C249),
          ),

          SizedBox(height: 20),

          Text(
            'Menyiapkan Kejar Kata...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Mengambil kosakata dari server',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFE7C249),
              size: 70,
            ),

            const SizedBox(height: 20),

            Text(
              errorMessage ??
                  'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: loadVocabularies,
              child: const Text(
                'COBA LAGI',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOptionButton(
    String option,
  ) {
    final correctAnswer =
        currentVocabulary == null
            ? ''
            : getTranslation(
                currentVocabulary!,
              );

    IconData? statusIcon;

    if (isAnswerChecked) {
      if (option == correctAnswer) {
        statusIcon =
            Icons.check_circle_rounded;
      } else if (option ==
          selectedAnswer) {
        statusIcon =
            Icons.cancel_rounded;
      }
    }

    return GestureDetector(
      onTap: () {
        selectAnswer(option);
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: getOptionColor(option),
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: selectedAnswer == option
                ? const Color(0xFFE7C249)
                : const Color.fromARGB(
                    50,
                    255,
                    255,
                    255,
                  ),
            width:
                selectedAnswer == option
                    ? 2
                    : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color:
                      getOptionTextColor(
                    option,
                  ),
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            if (statusIcon != null)
              Icon(
                statusIcon,
                color: Colors.white,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildGame() {
    if (currentVocabulary == null) {
      return const Center(
        child: Text(
          'Kosakata tidak tersedia.',
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding:
          const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Text(
                'Bahasa: ${widget.selectedLanguage}',
                style:
                    const TextStyle(
                  color:
                      Colors.white54,
                  fontSize: 14,
                ),
              ),

              Text(
                'Soal ${questionIndex + 1}',
                style:
                    const TextStyle(
                  color:
                      Color(0xFFE7C249),
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Center(
            child: Icon(
              Icons.bolt_rounded,
              color:
                  Color(0xFFE7C249),
              size: 50,
            ),
          ),

          const SizedBox(height: 15),

          const Center(
            child: Text(
              'Apa terjemahan dari:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              currentVocabulary!
                  .indonesian,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 35),

          ...answerOptions.map(
            (option) {
              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child:
                    buildOptionButton(
                  option,
                ),
              );
            },
          ),

          const SizedBox(height: 15),

          if (isAnswerChecked) ...[
            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                16,
              ),
              decoration:
                  BoxDecoration(
                color: isAnswerCorrect ==
                        true
                    ? const Color(
                        0xFF356859)
                    : const Color(
                        0xFF8B3A3A),
                borderRadius:
                    BorderRadius
                        .circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    isAnswerCorrect ==
                            true
                        ? Icons
                            .check_circle_rounded
                        : Icons
                            .cancel_rounded,
                    color:
                        Colors.white,
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      isAnswerCorrect ==
                              true
                          ? 'Benar!'
                          : 'Belum tepat. Jawaban yang benar adalah ${getTranslation(currentVocabulary!)}.',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 15,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  isAnswerChecked
                      ? nextQuestion
                      : selectedAnswer !=
                              null
                          ? checkAnswer
                          : null,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    const Color(
                  0xFFE7C249,
                ),
                disabledBackgroundColor:
                    const Color(
                  0xFF3C4448,
                ),
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 16,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
              ),
              child: Text(
                isAnswerChecked
                    ? 'SOAL BERIKUTNYA'
                    : 'PERIKSA JAWABAN',
                style:
                    TextStyle(
                  color:
                      isAnswerChecked ||
                              selectedAnswer !=
                                  null
                          ? const Color(
                              0xFF272F33,
                            )
                          : Colors
                              .white54,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF272F33),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF272F33),
        elevation: 0,
        iconTheme:
            const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Kejar Kata',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? buildLoading()
            : errorMessage != null
                ? buildError()
                : buildGame(),
      ),
    );
  }
}