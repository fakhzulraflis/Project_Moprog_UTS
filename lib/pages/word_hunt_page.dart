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

class _WordHuntPageState extends State<WordHuntPage> {
  static const int gridSize = 12;

  final Random random = Random();

  List<Vocabulary> vocabularies = [];

  List<List<String>> letterGrid = [];

  bool isLoading = true;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    loadVocabularies();
  }

  // Mengambil terjemahan sesuai bahasa yang dipilih user
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

  // Membersihkan kata sebelum dimasukkan ke grid
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

  // Membuat grid kosong
  List<List<String>> createEmptyGrid() {
    return List.generate(
      gridSize,
      (_) => List.generate(
        gridSize,
        (_) => '',
      ),
    );
  }

  // Membuat kumpulan karakter untuk mengisi kotak kosong
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

    // Fallback kalau tidak ada karakter
    if (characters.isEmpty) {
      characters.addAll(
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''),
      );
    }

    return characters;
  }

  // Membuat seluruh grid permainan
  void generateGrid() {
    final grid = createEmptyGrid();

    for (final vocabulary in vocabularies) {
      final word = cleanWord(
        getTranslation(vocabulary),
      );

      if (word.isEmpty || word.length > gridSize) {
        continue;
      }

      placeWord(grid, word);
    }

    fillEmptyCells(grid);

    letterGrid = grid;
  }

  // Mencoba memasukkan satu kata ke dalam grid
  void placeWord(
    List<List<String>> grid,
    String word,
  ) {
    // Arah:
    // horizontal
    // vertical
    // diagonal kanan bawah
    final directions = [
      [0, 1],
      [1, 0],
      [1, 1],
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

      // Pastikan kata tidak keluar grid
      if (endRow >= gridSize ||
          endColumn >= gridSize) {
        continue;
      }

      bool canPlace = true;

      for (int i = 0; i < word.length; i++) {
        final row =
            startRow + i * rowDirection;

        final column =
            startColumn + i * columnDirection;

        final existingCharacter =
            grid[row][column];

        final newCharacter = word[i];

        // Boleh menumpuk kalau hurufnya sama
        if (existingCharacter.isNotEmpty &&
            existingCharacter != newCharacter) {
          canPlace = false;
          break;
        }
      }

      if (!canPlace) {
        continue;
      }

      // Masukkan kata ke grid
      for (int i = 0; i < word.length; i++) {
        final row =
            startRow + i * rowDirection;

        final column =
            startColumn + i * columnDirection;

        grid[row][column] = word[i];
      }

      return;
    }

    debugPrint(
      'Tidak berhasil menempatkan kata: $word',
    );
  }

  // Mengisi kotak kosong dengan karakter acak
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

  // Membuat tampilan grid 12 x 12
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

          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF20272B),
              borderRadius:
                  BorderRadius.circular(5),
              border: Border.all(
                color: const Color.fromARGB(
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
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
      children: vocabularies.map((vocabulary) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF20272B),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Text(
            vocabulary.indonesian,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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
              onPressed: loadVocabularies,
              child: const Text('COBA LAGI'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGame() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
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

          const SizedBox(height: 8),

          const Text(
            'Temukan Kata!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Cari kosakata yang tersembunyi di dalam susunan huruf.',
            style: TextStyle(
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
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          buildTargetWords(),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              'Pemilihan kata akan ditambahkan selanjutnya.',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ),
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: const Text(
          'Perburuan Kata',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: loadVocabularies,
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