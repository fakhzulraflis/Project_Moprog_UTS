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
  List<Vocabulary> mistakeVocabularies = [];

  bool isLoading = true;

  String? errorMessage;

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
          .toList();

      setState(() {
        mistakeVocabularies = mistakes;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Gagal mengambil data kesalahan.';
        isLoading = false;
      });

      debugPrint(
        'Review Kesalahan error: $e',
      );
    }
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFE7C249),
      ),
    );
  }

  Widget buildEmpty() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFE7C249),
              size: 85,
            ),

            SizedBox(height: 20),

            Text(
              'Belum Ada Kesalahan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 10),

            Text(
              'Kosakata yang kamu jawab salah akan muncul di sini untuk dipelajari kembali.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPreview() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            'Bahasa: ${widget.selectedLanguage}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'Kosakata yang Perlu Diulang',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${mistakeVocabularies.length} kosakata perlu direview',
            style: const TextStyle(
              color: Color(0xFFE7C249),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.separated(
              itemCount:
                  mistakeVocabularies.length,
              separatorBuilder:
                  (context, index) {
                return const SizedBox(
                  height: 10,
                );
              },
              itemBuilder:
                  (context, index) {
                final vocabulary =
                    mistakeVocabularies[index];

                return Container(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFF20272B,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          vocabulary
                              .indonesian,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                      const Icon(
                        Icons
                            .arrow_forward_rounded,
                        color:
                            Colors.white38,
                      ),

                      const SizedBox(
                        width: 15,
                      ),

                      Expanded(
                        child: Text(
                          getTranslation(
                            vocabulary,
                          ),
                          textAlign:
                              TextAlign.right,
                          style:
                              const TextStyle(
                            color:
                                Color(
                              0xFFE7C249,
                            ),
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
          'Review Kesalahan',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadMistakes,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? buildLoading()
            : errorMessage != null
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
                    : buildPreview(),
      ),
    );
  }
}