import 'package:flutter/material.dart';

import '../models/vocabulary.dart';
import '../services/api_service.dart';

class _MemoryCard {
  final int pairId;
  final String text;

  bool isFlipped;
  bool isMatched;

  _MemoryCard({
    required this.pairId,
    required this.text,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGamePage extends StatefulWidget {
  final String selectedLanguage;

  const MemoryGamePage({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<MemoryGamePage> createState() =>
      _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  List<_MemoryCard> cards = [];

  bool isLoading = true;
  bool isChecking = false;
  bool isFinished = false;

  String? errorMessage;

  int? firstCardIndex;

  int moves = 0;
  int matchedPairs = 0;
  int totalPairs = 0;

  @override
  void initState() {
    super.initState();

    loadGame();
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

  Future<void> loadGame() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      isFinished = false;

      moves = 0;
      matchedPairs = 0;

      firstCardIndex = null;
      cards = [];
    });

    try {
      final vocabularies =
          await ApiService.getVocabularies();

      if (!mounted) return;

      if (vocabularies.isEmpty) {
        throw Exception('Vocabulary kosong');
      }

      // Acak vocabulary dari backend
      final shuffled =
          List<Vocabulary>.from(vocabularies)
            ..shuffle();

      // Maksimal 10 vocabulary = 20 kartu
      final selected = shuffled.length > 10
          ? shuffled.sublist(0, 10)
          : shuffled;

      final List<_MemoryCard> newCards = [];

      for (int i = 0; i < selected.length; i++) {
        final vocabulary = selected[i];

        final translated =
            getTranslation(vocabulary).trim();

        if (translated.isEmpty) {
          continue;
        }

        // Kartu Indonesia
        newCards.add(
          _MemoryCard(
            pairId: vocabulary.id,
            text: vocabulary.indonesian,
          ),
        );

        // Kartu bahasa yang dipilih user
        newCards.add(
          _MemoryCard(
            pairId: vocabulary.id,
            text: translated,
          ),
        );
      }

      if (newCards.length < 4) {
        throw Exception(
          'Tidak cukup vocabulary untuk Memory Game',
        );
      }

      // Campur seluruh kartu
      newCards.shuffle();

      setState(() {
        cards = newCards;

        totalPairs = newCards.length ~/ 2;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Gagal mengambil vocabulary dari server.';

        isLoading = false;
      });

      debugPrint('Memory Game error: $e');
    }
  }

  Future<void> selectCard(int index) async {
    if (isChecking) return;

    final card = cards[index];

    if (card.isFlipped || card.isMatched) {
      return;
    }

    setState(() {
      card.isFlipped = true;
    });

    // Kartu pertama
    if (firstCardIndex == null) {
      firstCardIndex = index;
      return;
    }

    // Kartu kedua
    final int firstIndex = firstCardIndex!;

    if (firstIndex == index) return;

    setState(() {
      moves++;
      isChecking = true;
    });

    final firstCard = cards[firstIndex];
    final secondCard = cards[index];

    if (firstCard.pairId == secondCard.pairId) {
      // MATCH
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (!mounted) return;

      setState(() {
        firstCard.isMatched = true;
        secondCard.isMatched = true;

        matchedPairs++;

        firstCardIndex = null;
        isChecking = false;

        if (matchedPairs == totalPairs) {
          isFinished = true;
        }
      });
    } else {
      // SALAH - tunggu lalu tutup kembali
      await Future.delayed(
        const Duration(milliseconds: 850),
      );

      if (!mounted) return;

      setState(() {
        firstCard.isFlipped = false;
        secondCard.isFlipped = false;

        firstCardIndex = null;
        isChecking = false;
      });
    }
  }

  Widget buildCard(int index) {
    final card = cards[index];

    final bool showText =
        card.isFlipped || card.isMatched;

    Color cardColor = const Color(0xFF20272B);

    if (card.isMatched) {
      cardColor = const Color(0xFF356859);
    } else if (card.isFlipped) {
      cardColor = const Color(0xFFE7C249);
    }

    return GestureDetector(
      onTap: () => selectCard(index),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 250,
        ),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: card.isFlipped
                ? const Color(0xFFE7C249)
                : const Color.fromARGB(
                    40,
                    255,
                    255,
                    255,
                  ),
            width: 2,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: showText
                ? Text(
                    card.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: card.isFlipped &&
                              !card.isMatched
                          ? const Color(0xFF272F33)
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : const Icon(
                    Icons.question_mark_rounded,
                    color: Color(0xFFE7C249),
                    size: 28,
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildGame() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pairs',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),

                      Text(
                        '$matchedPairs / $totalPairs',
                        style: const TextStyle(
                          color: Color(0xFFE7C249),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Moves',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),

                      Text(
                        '$moves',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              LinearProgressIndicator(
                value: totalPairs == 0
                    ? 0
                    : matchedPairs / totalPairs,
                minHeight: 9,
                backgroundColor:
                    const Color(0xFF20272B),
                color: const Color(0xFFE7C249),
                borderRadius:
                    BorderRadius.circular(20),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: GridView.builder(
              itemCount: cards.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 9,
                mainAxisSpacing: 9,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) {
                return buildCard(index);
              },
            ),
          ),
        ),
      ],
    );
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
            'Preparing Memory Game...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Loading vocabulary from server',
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
                  'Something went wrong.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: loadGame,
              child: const Text('TRY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResult() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.psychology_rounded,
              color: Color(0xFFE7C249),
              size: 90,
            ),

            const SizedBox(height: 20),

            const Text(
              'Memory Complete!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              '$matchedPairs / $totalPairs pairs found',
              style: const TextStyle(
                color: Color(0xFFE7C249),
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Moves: $moves',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 35),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loadGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFE7C249),
                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
                child: const Text(
                  'PLAY AGAIN',
                  style: TextStyle(
                    color: Color(0xFF272F33),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'BACK TO PRACTICE',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
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
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Permainan Mengingat',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadGame,
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
                ? buildError()
                : isFinished
                    ? buildResult()
                    : buildGame(),
      ),
    );
  }
}