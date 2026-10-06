import 'dart:math';

import 'package:flutter/material.dart';

import '../models/vocabulary.dart';
import '../services/api_service.dart';

class WordHuntPage extends StatefulWidget {
  final String selectedLanguage;

  const WordHuntPage({
    super.key,
    required this.selectedLanguage,
  });

  @override
  State<WordHuntPage> createState() => _WordHuntPageState();
}

class _GridPosition {
  final int row;
  final int column;

  const _GridPosition({
    required this.row,
    required this.column,
  });

  @override
  bool operator ==(Object other) {
    return other is _GridPosition &&
        other.row == row &&
        other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);
}

class _PlacedWord {
  final Vocabulary vocabulary;
  final String word;
  final List<_GridPosition> positions;

  _PlacedWord({
    required this.vocabulary,
    required this.word,
    required this.positions,
  });
}

class _WordHuntPageState extends State<WordHuntPage> {
  static const int gridSize = 12;

  final Random random = Random();

  List<Vocabulary> vocabularies = [];
  List<List<String>> letterGrid = [];

  final List<_PlacedWord> placedWords = [];

  final Set<String> foundWords = {};
  final Set<_GridPosition> foundPositions = {};

  _GridPosition? firstSelectedPosition;

  bool isLoading = true;

  String? errorMessage;

  String feedback = 'Pilih huruf awal dan huruf akhir dari sebuah kata.';

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

  String cleanWord(String word) {
    return word
        .trim()
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .toUpperCase();
  }

  Future<void> loadVocabularies() async {
    setState(() {
      isLoading = true;
      errorMessage = null;

      firstSelectedPosition = null;

      foundWords.clear();
      foundPositions.clear();

      feedback =
          'Pilih huruf awal dan huruf akhir dari sebuah kata.';
    });

    try {
      final result = await ApiService.getVocabularies();

      if (!mounted) return;

      final shuffled = List<Vocabulary>.from(result)
        ..shuffle();

      final selected = shuffled.length > 8
          ? shuffled.sublist(0, 8)
          : shuffled;

      setState(() {
        vocabularies = selected;

        generateGrid();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage =
            'Gagal mengambil kosakata dari server.';

        isLoading = false;
      });

      debugPrint('Word Hunt error: $e');
    }
  }

  List<List<String>> createEmptyGrid() {
    return List.generate(
      gridSize,
      (_) => List.generate(
        gridSize,
        (_) => '',
      ),
    );
  }

  List<String> createFillerCharacters() {
    final List<String> characters = [];

    for (final vocabulary in vocabularies) {
      final word = cleanWord(
        getTranslation(vocabulary),
      );

      characters.addAll(
        word.split(''),
      );
    }

    if (characters.isEmpty) {
      characters.addAll(
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''),
      );
    }

    return characters;
  }

  void generateGrid() {
    final grid = createEmptyGrid();

    placedWords.clear();

    for (final vocabulary in vocabularies) {
      final word = cleanWord(
        getTranslation(vocabulary),
      );

      if (word.isEmpty || word.length > gridSize) {
        continue;
      }

      placeWord(
        grid,
        word,
        vocabulary,
      );
    }

    fillEmptyCells(grid);

    letterGrid = grid;
  }

  bool placeWord(
    List<List<String>> grid,
    String word,
    Vocabulary vocabulary,
  ) {
    final directions = [
      [0, 1], // horizontal
      [1, 0], // vertikal
      [1, 1], // diagonal
    ];

    for (int attempt = 0; attempt < 100; attempt++) {
      final direction =
          directions[random.nextInt(directions.length)];

      final rowDirection = direction[0];
      final columnDirection = direction[1];

      final startRow = random.nextInt(gridSize);
      final startColumn = random.nextInt(gridSize);

      final endRow =
          startRow + (word.length - 1) * rowDirection;

      final endColumn =
          startColumn + (word.length - 1) * columnDirection;

      if (endRow >= gridSize ||
          endColumn >= gridSize) {
        continue;
      }

      bool canPlace = true;

      final List<_GridPosition> positions = [];

      for (int i = 0; i < word.length; i++) {
        final row =
            startRow + i * rowDirection;

        final column =
            startColumn + i * columnDirection;

        final existingCharacter =
            grid[row][column];

        final newCharacter = word[i];

        if (existingCharacter.isNotEmpty &&
            existingCharacter != newCharacter) {
          canPlace = false;
          break;
        }

        positions.add(
          _GridPosition(
            row: row,
            column: column,
          ),
        );
      }

      if (!canPlace) {
        continue;
      }

      for (int i = 0; i < word.length; i++) {
        final position = positions[i];

        grid[position.row][position.column] =
            word[i];
      }

      placedWords.add(
        _PlacedWord(
          vocabulary: vocabulary,
          word: word,
          positions: positions,
        ),
      );

      return true;
    }

    debugPrint(
      'Tidak berhasil menempatkan kata: $word',
    );

    return false;
  }

  void fillEmptyCells(
    List<List<String>> grid,
  ) {
    final fillerCharacters =
        createFillerCharacters();

    for (int row = 0;
        row < gridSize;
        row++) {
      for (int column = 0;
          column < gridSize;
          column++) {
        if (grid[row][column].isEmpty) {
          grid[row][column] =
              fillerCharacters[
                  random.nextInt(
                    fillerCharacters.length,
                  )
              ];
        }
      }
    }
  }

  void selectCell(int row, int column) {
    final selectedPosition = _GridPosition(
      row: row,
      column: column,
    );

    if (firstSelectedPosition == null) {
      setState(() {
        firstSelectedPosition =
            selectedPosition;

        feedback =
            'Sekarang pilih huruf terakhir dari kata tersebut.';
      });

      return;
    }

    final firstPosition =
        firstSelectedPosition!;

    final selectedPositions =
        getPositionsBetween(
      firstPosition,
      selectedPosition,
    );

    if (selectedPositions.isEmpty) {
      setState(() {
        firstSelectedPosition = null;

        feedback =
            'Pilih kata dalam garis lurus horizontal, vertikal, atau diagonal.';
      });

      return;
    }

    final selectedWord =
        selectedPositions.map((position) {
      return letterGrid[position.row]
          [position.column];
    }).join();

    final reversedWord =
        selectedWord.split('').reversed.join();

    _PlacedWord? matchedWord;

    for (final placedWord in placedWords) {
      if (foundWords.contains(
        placedWord.word,
      )) {
        continue;
      }

      if (placedWord.word == selectedWord ||
          placedWord.word == reversedWord) {
        matchedWord = placedWord;
        break;
      }
    }

    if (matchedWord != null) {
      setState(() {
        foundWords.add(
          matchedWord!.word,
        );

        foundPositions.addAll(
          matchedWord.positions,
        );

        firstSelectedPosition = null;

        feedback =
            'Benar! Kamu menemukan ${matchedWord.vocabulary.indonesian}.';
      });
    } else {
      setState(() {
        firstSelectedPosition = null;

        feedback =
            'Belum cocok. Coba cari kata yang lain!';
      });
    }
  }

  List<_GridPosition> getPositionsBetween(
    _GridPosition start,
    _GridPosition end,
  ) {
    final rowDifference =
        end.row - start.row;

    final columnDifference =
        end.column - start.column;

    int rowStep = 0;
    int columnStep = 0;

    if (rowDifference == 0 &&
        columnDifference != 0) {
      columnStep =
          columnDifference > 0 ? 1 : -1;
    } else if (columnDifference == 0 &&
        rowDifference != 0) {
      rowStep =
          rowDifference > 0 ? 1 : -1;
    } else if (rowDifference.abs() ==
        columnDifference.abs()) {
      rowStep =
          rowDifference > 0 ? 1 : -1;

      columnStep =
          columnDifference > 0 ? 1 : -1;
    } else {
      return [];
    }

    final length = max(
          rowDifference.abs(),
          columnDifference.abs(),
        ) +
        1;

    return List.generate(
      length,
      (index) {
        return _GridPosition(
          row: start.row +
              index * rowStep,
          column: start.column +
              index * columnStep,
        );
      },
    );
  }

  bool isFoundPosition(
    int row,
    int column,
  ) {
    return foundPositions.contains(
      _GridPosition(
        row: row,
        column: column,
      ),
    );
  }

  bool isFirstSelected(
    int row,
    int column,
  ) {
    return firstSelectedPosition ==
        _GridPosition(
          row: row,
          column: column,
        );
  }

  Widget buildLetterGrid() {
    if (letterGrid.isEmpty) {
      return const SizedBox();
    }

    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: gridSize * gridSize,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemBuilder: (context, index) {
          final row = index ~/ gridSize;
          final column = index % gridSize;

          final character =
              letterGrid[row][column];

          final found =
              isFoundPosition(
            row,
            column,
          );

          final selected =
              isFirstSelected(
            row,
            column,
          );

          Color cardColor =
              const Color(0xFF20272B);

          Color textColor =
              Colors.white;

          if (found) {
            cardColor =
                const Color(0xFF356859);
          } else if (selected) {
            cardColor =
                const Color(0xFFE7C249);

            textColor =
                const Color(0xFF272F33);
          }

          return GestureDetector(
            onTap: () {
              selectCell(
                row,
                column,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: 200,
              ),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(5),
                border: Border.all(
                  color: selected
                      ? const Color(
                          0xFFE7C249,
                        )
                      : const Color.fromARGB(
                          35,
                          255,
                          255,
                          255,
                        ),
                ),
              ),
              child: Center(
                child: Text(
                  character,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildTargetWords() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: placedWords.map((placedWord) {
        final found =
            foundWords.contains(
          placedWord.word,
        );

        return Container(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: found
                ? const Color(0xFF356859)
                : const Color(0xFF20272B),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              if (found) ...[
                const Icon(
                  Icons.check_rounded,
                  color: Colors.greenAccent,
                  size: 16,
                ),

                const SizedBox(width: 4),
              ],

              Text(
                placedWord
                    .vocabulary
                    .indonesian,
                style: TextStyle(
                  color: found
                      ? Colors.greenAccent
                      : Colors.white70,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.bold,
                  decoration: found
                      ? TextDecoration
                          .lineThrough
                      : null,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
            'Menyiapkan Perburuan Kata...',
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
              onPressed:
                  loadVocabularies,
              child: const Text(
                'COBA LAGI',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGame() {
    final totalWords =
        placedWords.length;

    final totalFound =
        foundWords.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
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
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),

              Text(
                '$totalFound / $totalWords',
                style:
                    const TextStyle(
                  color:
                      Color(0xFFE7C249),
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: totalWords == 0
                ? 0
                : totalFound /
                    totalWords,
            minHeight: 8,
            backgroundColor:
                const Color(0xFF20272B),
            color:
                const Color(0xFFE7C249),
            borderRadius:
                BorderRadius.circular(20),
          ),

          const SizedBox(height: 20),

          const Text(
            'Temukan Kata!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            feedback,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 22),

          buildLetterGrid(),

          const SizedBox(height: 25),

          const Text(
            'Kata yang dicari',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          buildTargetWords(),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Perburuan Kata',
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                loadVocabularies,
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
                : buildGame(),
      ),
    );
  }
}